#' Get Temperature Readings from Climacell
#'
#' @description \code{climacell_temperature} will call the Climacell API and return temperature related attributes such as temperature, temperatureApparent (i.e., wind chill or real feel temperature), dew point, and humidity. All values are in metric and the timestamps returned by the API are always in UTC. These are not converted to the local machine's timezone.
#'
#'
#' @param api_key a 32 character string that represents the private API key for accessing the Climacell API
#' @param lat a numeric value representing the latitude of the location
#' @param long a numeric value representing the longitude of the location
#' @param timestep a 'step' value for the time. Valid values are (choose one): c('1d', '1h', '30m','15m','5m','1m','current')
#' @param start_time the start date and time of the query. Must include timezone. Valid syntax: YYYY-MM-DDTHH:MM:SS-HH:MM. This value cannot be more than 6 hours prior to the current local time. This argument is OPTIONAL if timestep is 'current'.
#' @param end_time the end date and time of the query. Must include timezone. Valid syntax: YYYY-MM-DDTHH:MM:SS-HH:MM. The maximum end date/time depends on the timestep value chosen. The Climacell API will only return the maximum allowable results if the end_time is beyond the API limits. This argument is OPTIONAL if you do not wish to 'narrow' your end results.
#'
#' @return a tibble with the variables temperature, wind chill (or real feel temperature), dewpoint, and humidity
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
climacell_temperature <- function(api_key, lat, long, timestep, start_time=NULL, end_time=NULL) {

  if(missing(api_key) & Sys.getenv('CLIMACELL_API') == '') {
    stop("No API key provided. Please provide valid API key.")
  }

  api_key <- Sys.getenv('CLIMACELL_API')

  if(nchar(api_key) < 32) {
    stop('API Key length is shorter than 32 characters, please recheck')
  }

  if(missing(lat)) {
    stop("No latitude provided")
  }

  if(missing(long)) {
    stop("No longitude provided")
  }

  if(is.numeric(lat) == FALSE) {
    stop("Latitude must be a numeric value.")
  }

  if(is.numeric(long) == FALSE) {
    stop("Longitude must be a numeric value.")
  }

  if(missing(timestep)) {
    stop("No timestep provided")
  }

  if((timestep == 'current' & !is.null(start_time)) | timestep == 'current' & !is.null(end_time)) {
    message("Timestep of current does not require start or end times. Your system local time will be used instead.")
  }

  if(!timestep %in% c('1d', '1h', '30m','15m','5m','1m','current')) {
    stop("Timestep value is incorrect. \nAcceptable values are (choose one only): c('current','1m','5m','15m','30m','1h','1d')")
  }

  if(is.null(start_time)) {
    message("No start time provided. Using current system time!")
    start_time <- Sys.time()
  }

  if(timestep != 'current' & is.null(end_time)) {
    stop("No end time provided. End time is only optional if timestep is set to 'current'.")
  }

  # ensure that the start time is no more than 6 hours of the CURRENT system time

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
    warning("Climacell Free API only allows for upto 15 days into the future!")
  }

  if(timestep == '1h' & future_time_chek_hrs > 108.0) {
    warning("Climacell Free API only allows for upto 108 hours into the future!")
  }

  if(timestep %in% c('1m','5m','15m','30m') & future_time_chek_hrs >= 6.0) {
    warning("Climacell Free API only allows for upto 6 hours into the future!")
  }


  # get the end result

  latlong <- paste0(lat, ', ', long)

  result <- httr::content(
    httr::GET(
      url = 'https://data.climacell.co/v4/timelines',
      httr::add_headers('apikey'= api_key),
      httr::add_headers('content-type:' = 'application/json'),
      query = list(location = latlong,
                   fields = 'temperature',
                   fields = 'temperatureApparent',
                   fields = 'dewPoint',
                   fields = 'humidity',
                   timesteps=timestep,
                   startTime = start_time,
                   endTime = end_time
      )
    )
  )

  tidy_result <- tibble::enframe(unlist(result))

  cln_result <- tidy_result %>%
    dplyr::mutate(
      name = gsub(pattern = 'data.timelines.', replacement = '', x = .data$name),
      name = gsub(pattern = 'temperatureApparent', replacement = 'realFeel', x = .data$name)
    ) %>%
    dplyr::filter(stringr::str_detect(pattern = 'intervals', string = .data$name))

  cln_out <- tibble::tibble(
    start_time = cln_result %>%
      dplyr::filter(stringr::str_detect(pattern = 'startTime', string = .data$name)) %>%
      dplyr::select(.data$value) %>%
      dplyr::pull(),
    temp_c = cln_result %>%
      dplyr::filter(stringr::str_detect(pattern = 'intervals.values.temperature', string = .data$name)) %>%
      dplyr::select(.data$value) %>%
      dplyr::pull(),
    temp_feel_c = cln_result %>%
      dplyr::filter(stringr::str_detect(pattern = 'intervals.values.realFeel', string = .data$name)) %>%
      dplyr::select(.data$value) %>%
      dplyr::pull(),
    dewpoint = cln_result %>%
      dplyr::filter(stringr::str_detect(pattern = 'intervals.values.dewPoint', string = .data$name)) %>%
      dplyr::select(.data$value) %>%
      dplyr::pull(),
    humidity = cln_result %>%
      dplyr::filter(stringr::str_detect(pattern = 'intervals.values.humidity', string = .data$name)) %>%
      dplyr::select(.data$value) %>%
      dplyr::pull()
  )

  return(cln_out)

}
