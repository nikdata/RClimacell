#' Wind Readings from Climacell
#'
#' \code{climacell_wind} returns a tibble that consists of wind related variables (returned values are in metric units) using the Climacell API. These variables consist of wind speed, wind gust, and wind direction.
#'
#' @description This function will make a call to the Climacell API and retrieve wind related variables.
#'
#' @param api_key character string representing the private API key. Provided by user or loaded automatically from environment variable (environment variable must be called "CLIMACELL_API").
#' @param lat a numeric value (or a string that can be coerced to numeric) representing the latitude of the location.
#' @param long a numeric value (or a string that can be coerced to numeric) representing the longitude of the location.
#' @param timestep a 'step' value for the time. Choose one of the following valid values: c('1d', '1h', '30m','15m','5m','1m','current').
#' @param start_time the start time of the query. This input must be a character string that can be parsed into a data/time or a date/time value. If the input does not contain a timezone, the value will be assumed to be in UTC. It is recommended that the \code{lubridate::now()} function or \code{Sys.time()} be used to define the start_time. For this function, the start_time cannot be less than 6 hours from the current time.
#' @param end_time the end time of the query. This input must be a character string that can be parsed into a data/time or a date/time value. If the input does not contain a timezone, the value will be assumed to be in UTC. OPTIONAL if timestep is 'current' or if the user desires to get the maximum results possible (depends on the timestep chosen).
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
#' @examples
#' \dontrun{
#' climacell_wind(
#'   api_key = Sys.getenv('CLIMACELL_API'),
#'   lat = 0,
#'   long = 0,
#'   timestep = 'current')
#' }
#'
climacell_wind <- function(api_key, lat, long, timestep, start_time=NULL, end_time=NULL) {

  # check for missing key or empty environment variable
  if(missing(api_key) & Sys.getenv('CLIMACELL_API') == '') {
    stop("No API key provided nor default CLIMACELL_API environment variable found.\nPlease provide valid API key.")
  }

  # basic way of assigning environment variable
  # if no api key found, "" is entered into variable and then a 32 character check is performed
  api_key <- Sys.getenv('CLIMACELL_API')

  # ensure API key is 32 characters long (assumption that the API key is this long)
  # could not find confirmation of this
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
    message("Timestep of 'current' cannot have start or end times.")
    start_time = NULL
    end_time = NULL
  }

  # timestep can only have certain values
  if(!timestep %in% c('1d', '1h', '30m','15m','5m','1m','current')) {
    stop("Timestep value is incorrect. \nAcceptable values are (choose one only): c('current','1m','5m','15m','30m','1h','1d')")
  }

  if(timestep != 'current' & is.null(start_time)) {
    message("No start time provided. Using current system time in UTC for start_time.")
    start_time <- lubridate::format_ISO8601(lubridate::with_tz(time = Sys.time(), tzone = 'UTC'), usetz = T)
  } else {
    # if user has already provided a start_time parameter value
    start_time <- lubridate::with_tz(time = start_time, tzone = 'UTC')
    start_time <- lubridate::format_ISO8601(x = start_time, usetz = T)
  }

  if(timestep %in% c('1m','5m', '15m','30m') & is.null(end_time)) {
    message("No end time provided. End time will be adjusted for 6 hours from current system time!")
    end_time <- lubridate::with_tz(time = Sys.time() + lubridate::dhours(6), tzone = 'UTC')
    end_time <- lubridate::format_ISO8601(x = end_time, usetz = T)
  } else if (timestep == '1h' & is.null(end_time)) {
    message("No end time provided. End time will be adjusted for 108 hours from current system time!")
    end_time <- lubridate::with_tz(time = Sys.time() + lubridate::dhours(108), tzone = 'UTC')
    end_time <- lubridate::format_ISO8601(x = end_time, usetz = T)
  } else if (timestep == '1d' & is.null(end_time)) {
    message("No end time provided. End time will be adjusted for 15 days from current system time!")
    end_time <- lubridate::with_tz(time = Sys.time() + lubridate::ddays(15), tzone = 'UTC')
    end_time <- lubridate::format_ISO8601(x = end_time, usetz = T)
  } else {
    end_time <- lubridate::with_tz(time = end_time, tzone = 'UTC')
    end_time <- lubridate::format_ISO8601(x = end_time, usetz = T)
  }

  # make sure start time is before end time
  if(start_time > end_time) {
    stop("Start time cannot be later than the end time!")
  }

  # error handling of the start & end times based on timestep used

  # timesteps 1m, 15m, 30m only allow 6 hours max into future from current actual time
  # timstep 1h allows for only 108 hours max into future from current actual time
  # timestep 1d allows for only 15 days max into future from current actual time

  # establish current time and the user times all in UTC
  current_time <- lubridate::with_tz(lubridate::now(), tzone = 'UTC')
  user_st_utc <- lubridate::ymd_hms(start_time)
  user_et_utc <- lubridate::ymd_hms(end_time)

  # define the maximum allowable time based on timestep
  if(timestep %in% c('1m','15m','30m')) {
    max_time_utc <- current_time + lubridate::dhours(6)
  } else if(timestep %in% c('1h')) {
    max_time_utc <- current_time + lubridate::dhours(108)
  } else if(timestep %in% c('1d')) {
    max_time_utc <- current_time + lubridate::ddays(15)
  }

  # if timestep is 1m, 15m, 30m, 1h then make sure start time is not 6 hours prior to current time

  # st_cur_chk: difference between the current system time and user start time
  # (< -6 means user start time is more than 6 hours prior to current system time)
  st_cur_chk <- lubridate::time_length(lubridate::interval(start = current_time, end = user_st_utc), unit = 'hours')

  if(st_cur_chk < -6.0) {
    message('Start time is more than 6 hours prior to the current system time!')
    message('Start time has been readjusted to be no more than 6 hours prior to current system time.')
    start_time <- lubridate::with_tz(lubridate::now() - lubridate::dhours(6), tzone = 'UTC')
    start_time <- lubridate::format_ISO8601(x = start_time, usetz = T)
  }


  # determine difference in time between the start time and the maximum allowable time
  # st_max_chk: difference between the maximum limit time and the user start time (if <1, <15, or < 30 (depending on timestep), there is a problem)
  st_max_chk <- lubridate::time_length(lubridate::interval(start = user_st_utc, end = max_time_utc), unit = 'minutes')

  if(timestep == '1m' & st_max_chk < 1.0) {
    stop("Start time cannot be less than 1 minute from maximum allowable time for this timestep!")
  } else if(timestep == '15m' & st_max_chk < 15.0) {
    stop("Start time cannot be less than 15 minutes from maximum allowable time for this timestep!")
  } else if(timestep == '30m' & st_max_chk < 30.0) {
    stop("Start time cannot be less than 30 minutes from maximum allowable time for this timestep!")
  } else if(timestep == '1h' & st_max_chk < 60.0) {
    stop("Start time cannot be less than 1 hour from maximum allowable time for this timestep!")
  } else if(timestep == '1d' & st_max_chk < 1440.0) {
    stop("Start time cannot be less than 24 hours from maximum allowable time for this timestep!")
  }

  # determine difference in time between end time and maximum allowable time
  # et_max_chk: difference between maximum limit time and user end time (if < 0, user end time is more than limit)
  et_max_chk <- lubridate::time_length(lubridate::interval(start = user_et_utc, end = max_time_utc), unit = 'hours')

  if(et_max_chk < 0) {
    if(timestep %in% c('1m','15m','30m')) {
      message('End time is more than 6 hours ahead of the current system time!')
      message('End time has been readjusted to be no more than 6 hours ahead of current system time.')
      end_time <- lubridate::with_tz(lubridate::now() + lubridate::dhours(6), tzone = 'UTC')
      end_time <- lubridate::format_ISO8601(x = end_time, usetz = T)
    } else if(timestep == '1h') {
      message('End time is more than 108 hours ahead of the current system time!')
      message('End time has been readjusted to be no more than 108 hours ahead of current system time.')
      end_time <- lubridate::with_tz(lubridate::now() + lubridate::dhours(108), tzone = 'UTC')
      end_time <- lubridate::format_ISO8601(x = end_time, usetz = T)
    } else if(timestep == '1d') {
      message('End time is more than 15 days ahead of the current system time!')
      message('End time has been readjusted to be no more than 15 days ahead of current system time.')
      end_time <- lubridate::with_tz(lubridate::now() + lubridate::dhours(15), tzone = 'UTC')
      end_time <- lubridate::format_ISO8601(x = end_time, usetz = T)
    }
  }

  # need to make sure there is adequate difference between start & end times provided by user

  et_st_chk <- lubridate::time_length(lubridate::interval(start = user_st_utc, end = user_et_utc), unit = 'minutes')

  if(timestep == '1m' & et_st_chk < 1.0) {
    stop('Difference between start time and end time cannot be less than 1 minute!')
  } else if(timestep == '15m' & et_st_chk < 15.0) {
    stop('Difference between start time and end time cannot be less than 15 minutes!')
  } else if(timestep == '30m' & et_st_chk < 30.0) {
    stop('Difference between start time and end time cannot be less than 30 minutes!')
  } else if(timestep == '1h' & et_st_chk < 60.0) {
    stop('Difference between start time and end time cannot be less than 60 minutes!')
  } else if(timestep == '1d' & et_st_chk < 1440.0) {
    stop('Difference between start time and end time cannot be less than 24 hours!')
  }

  # process for API retrieval

  latlong <- paste0(lat, ', ', long)

  # get results
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

  # wind direction does not always appear in the results (especially when wind speed is 0)

  wind_direction_results <- cln_result %>%
    dplyr::filter(stringr::str_detect(pattern = 'startTime', string = .data$name) | stringr::str_detect(pattern = 'windDirection', string = .data$name))

  df_wind_direction <- wind_direction_results %>%
    dplyr::left_join(
      wind_direction_results %>%
        dplyr::filter(stringr::str_detect(pattern = 'startTime', string = .data$name)) %>%
        dplyr::mutate(index = dplyr::row_number()),
      by = c('name','value')
    ) %>%
    dplyr::mutate(
      name = gsub(pattern = 'intervals.', replacement = '', x = .data$name),
      name = gsub(pattern = 'values.', replacement = '', x = .data$name),
      name = gsub(pattern = 'startTime', replacement = 'start_time', x = .data$name),
      name = gsub(pattern = 'windDirection', replacement = 'wind_direction', x = .data$name)
    ) %>%
    tidyr::fill(.data$index, .direction = 'down') %>%
    tidyr::pivot_wider(
      names_from = .data$name,
      values_from = .data$value
    ) %>%
    dplyr::select(-.data$index)

  # check to make sure that columns wind_direction are present
  winddir_chk <- assertthat::has_name(df_wind_direction, 'wind_direction')

  # if any column is missing, add it to df_wind_direction
  if(winddir_chk == FALSE) {
    df_wind_direction <- df_wind_direction %>%
      tibble::add_column(wind_direction = NA)
  }

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
      dplyr::pull()
  )

  cln_combo <- cln_out %>%
    dplyr::left_join(df_wind_direction, by = c('start_time'))

  # change data types
  cln_combo <- cln_combo %>%
    dplyr::mutate(
      start_time = lubridate::ymd_hms(.data$start_time, tz = 'UTC'),
      wind_speed = as.numeric(.data$wind_speed),
      wind_gust = as.numeric(.data$wind_gust),
      wind_direction = as.numeric(.data$wind_direction)
    )

  return(cln_combo)

}
