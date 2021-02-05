#' Temperature Readings from Climacell
#'
#' @param api_key a 32 character string that represents the private API key for accessing the Climacell API. If missing, the function attempts to call on the environment variable called "CLIMACELL_API".
#' @param lat a numeric value (or a string that can be coerced to numeric) representing the latitude of the location
#' @param long a numeric value (or a string that can be coerced to numeric) representing the longitude of the location
#' @param timestep a 'step' value for the time. Valid values are (choose one): c('1d', '1h', '30m','15m','5m','1m','current')
#' @param start_time the start date and time of the query in \href{https://en.wikipedia.org/wiki/ISO_8601}{ISO8601} format. Must include timezone. Valid syntax: YYYY-MM-DDTHH:MM:SS-HH:MM. This value cannot be more than 6 hours prior to the current local time. This argument is OPTIONAL if timestep is 'current'.
#' @param end_time the end date and time of the query in \href{https://en.wikipedia.org/wiki/ISO_8601}{ISO8601} format. Must include timezone. Valid syntax: YYYY-MM-DDTHH:MM:SS-HH:MM. The maximum end date/time depends on the timestep value chosen. The Climacell API will only return the maximum allowable results if the end_time is beyond the API limits. This argument is OPTIONAL if you do not wish to 'narrow' your end results.
#'
#' @return a tibble
#' @export
#'
#' @import dplyr
#' @import tibble
#' @import httr
#'
#' @importFrom stringr str_detect
#' @importFrom magrittr `%>%`
#' @importFrom rlang .data
#'
#'
climacell_wind <- function(api_key, lat, long, timestep, start_time=NULL, end_time=NULL) {

  # check for missig key or empty environment variable
  if(missing(api_key) & Sys.getenv('CLIMACELL_API') == '') {
    stop("No API key provided. Please provide valid API key.")
  }

  # basic way of assigning enviornment variable that may not exist
  api_key <- Sys.getenv('CLIMACELL_API')

  # ensure API key is 32 characters long
  if(nchar(api_key) < 32) {
    stop('API Key length is shorter than 32 characters, please recheck')
  }

  if(missing(lat)) {
    stop("No latitude provided")
  }

  if(missing(long)) {
    stop("No longitude provided")
  }

  if(is.numeric(lat) == FALSE | is.na(as.numeric(lat))) {
    stop("Latitude must be a numeric value or a string that can be coerced to numeric.")
  }

  if(is.numeric(long) == FALSE | is.na(as.numeric(long))) {
    stop("Longitude must be a numeric value or a string that can be coerced to numeric.")
  }

  if(missing(timestep)) {
    stop("No timestep provided")
  }

  # a timestep of current cannot have start or end times
  if((timestep == 'current' & !is.null(start_time)) | timestep == 'current' & !is.null(end_time)) {
    message("Timestep of current does not require start or end times.")
    start_time = NULL
    end_time = NULL
  }

  if(!timestep %in% c('1d', '1h', '30m','15m','5m','1m','current')) {
    stop("Timestep value is incorrect. \nAcceptable values are (choose one only): c('current','1m','5m','15m','30m','1h','1d')")
  }

  if(timestep != 'current' & is.null(start_time)) {
    warning("No start time provided. Using current system time in UTC for start_time.")
    start_time <- parsedate::format_iso_8601(Sys.time())
  }

  if(timestep != 'current' & is.null(end_time)) {
    warning("No end time provided. End time will be adjusted for 1 day beyond the start_time.")
    end_time <- parsedate::format_iso_8601(start_time + lubridate::days(1))
  }

  # check to make sure timestamps will parse

  if(timestep != 'current'){
    if(is.na(parsedate::parse_iso_8601(start_time))) {
      stop("Start time value is not in ISO 8601 format!")
    }
  }

  if(timestep != 'current') {
    if(is.na(parsedate::parse_iso_8601(end_time))) {
      stop("End time value is not in ISO 8601 format!")
    }
  }

  # ensure formatting of all times is good (will convert valid times to UTC)
  start_time <- parsedate::format_iso_8601(parsedate::parse_date(start_time))
  end_time <- parsedate::format_iso_8601(parsedate::parse_date(end_time))

  # ensure that the start time is no more than 6 hours of the CURRENT system time (only needed if not using current)

  if(timestep != 'current') {
    current_systime_utc <- lubridate::with_tz(lubridate::now(), tzone = 'UTC')
    user_starttime_utc <- lubridate::ymd_hms(start_time)
    user_endtime_utc <- lubridate::ymd_hms(end_time)

    diff_hour_check <- round(as.double(difftime(time1 = current_systime_utc, time2 = user_starttime_utc, units = 'hours')),1)

    if(diff_hour_check > 6.0) {
      stop("The Climacell Free API does not enable users to retrieve data that is older than 6 hours!")
    }

    future_time_chek_hrs <- round(as.double(difftime(time1 = user_endtime_utc, time2 = current_systime_utc, units = 'hours')),1)
    future_time_chek_days <- round(as.double(difftime(time1 = user_endtime_utc, time2 = current_systime_utc, units = 'days')),1)

    if(timestep == '1d' & future_time_chek_days > 15.0) {
      warning("Climacell Free API only allows for upto 15 days into the future!\nReadjusting end time to no more than 15 days from start time.")
      end_time <- parsedate::parse_iso_8601(start_time) + lubridate::days(15)
      end_time <- parsedate::format_iso_8601(end_time)
    }

    if(timestep == '1h' & future_time_chek_hrs > 108.0) {
      warning("Climacell Free API only allows for upto 108 hours into the future!\nReadjusting end time to no more than 108 hours from start time.")
      end_time <- parsedate::parse_iso_8601(start_time) + lubridate::hours(108)
      end_time <- parsedate::format_iso_8601(end_time)
    }

    if(timestep %in% c('1m','5m','15m','30m') & future_time_chek_hrs >= 6.0) {
      warning("Climacell Free API only allows for upto 6 hours into the future!\nReadjusting end time to no more than 6 hours from start time.")
      end_time <- parsedate::parse_iso_8601(start_time) + lubridate::hours(6)
      end_time <- parsedate::format_iso_8601(end_time)
    }
  }

  # get the end result

  latlong <- paste0(lat, ', ', long)

  result <- httr::content(
    httr::GET(
      url = 'https://data.climacell.co/v4/timelines',
      httr::add_headers('apikey'= api_key),
      httr::add_headers('content-type:' = 'application/json'),
      query = list(location = latlong,
                   fields = 'windSpeed',
                   fields = 'windDirection',
                   fields = 'windGust',
                   timesteps=timestep,
                   startTime = start_time,
                   endTime = end_time
      )
    )
  )

  tidy_result <- tibble::enframe(unlist(result))

  cln_result <- tidy_result %>%
    dplyr::mutate(
      name = gsub(pattern = 'data.timelines.', replacement = '', x = .data$name)
    ) %>%
    dplyr::filter(stringr::str_detect(pattern = 'intervals', string = .data$name))

  cln_out <- tibble::tibble(
    start_time = cln_result %>%
      dplyr::filter(stringr::str_detect(pattern = 'startTime', string = .data$name)) %>%
      dplyr::select(.data$value) %>%
      dplyr::pull(),
    wind_speed = cln_result %>%
      dplyr::filter(stringr::str_detect(pattern = 'intervals.values.windSpeed', string = .data$name)) %>%
      dplyr::select(.data$value) %>%
      dplyr::pull(),
    wind_gust = cln_result %>%
      dplyr::filter(stringr::str_detect(pattern = 'intervals.values.windGust', string = .data$name)) %>%
      dplyr::select(.data$value) %>%
      dplyr::pull(),
    wind_direction = cln_result %>%
      dplyr::filter(stringr::str_detect(pattern = 'intervals.values.windDirection', string = .data$name)) %>%
      dplyr::select(.data$value) %>%
      dplyr::pull()
  )

  # change data types
  cln_out <- cln_out %>%
    mutate(
      start_time = lubridate::ymd_hms(.data$start_time, tz = 'UTC'),
      wind_speed = as.numeric(.data$wind_speed),
      wind_gust = as.numeric(.data$wind_gust),
      wind_direction = as.numeric(.data$wind_direction)
    )

  return(cln_out)

}
