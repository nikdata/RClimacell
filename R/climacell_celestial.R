#' Sunrise, Sunset, and Moon Phase Readings from Climacell
#'
#' \code{climacell_celestial} returns a tibble that consists of sunrise/sunset times along with the moon phase (code & description).
#'
#' @description This function will make a call to the Climacell API and retrieve sunrise, sunset times and moon phase variables.
#'
#' @param api_key character string representing the private API key. Provided by user or loaded automatically from environment variable (environment variable must be called "CLIMACELL_API").
#' @param lat a numeric value (or a string that can be coerced to numeric) representing the latitude of the location.
#' @param long a numeric value (or a string that can be coerced to numeric) representing the longitude of the location.
#' @param timestep a 'step' value for the time. For the \code{climacell_celestial} function, the only acceptable value (per the limitations of the Climacell API) is '1d'.
#' @param start_time the start time of the query. This input must be a character string that can be parsed into a data/time or a date/time value. If the input does not contain a timezone, the value will be assumed to be in UTC. It is recommended that the \code{lubridate::now()} function or \code{Sys.time()} be used to define the start_time. For this function, the start_time cannot be less than 6 hours from the current time.
#' @param end_time the end time of the query. This input must be a character string that can be parsed into a data/time or a date/time value. If the input does not contain a timezone, the value will be assumed to be in UTC. For this function, the end_time cannot be greater than 15 days from the current date/time.
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
#' climacell_celestial(
#'   api_key = Sys.getenv('CLIMACELL_API'),
#'   lat = 0,
#'   long = 0,
#'   timestep = '1d',
#'   start_time = lubridate::now(),
#'   end_time = lubridate::now() + lubridate::days(5))
#' }
climacell_celestial <- function(api_key, lat, long, timestep = '1d', start_time=NULL, end_time=NULL) {

  current_time <- lubridate::with_tz(Sys.time(), tzone = 'UTC')
  current_time <- lubridate::format_ISO8601(x = current_time, usetz = T)

  moon_phase_dict <- tibble::tibble(moon_phase_code = as.integer(seq(0,7,1)),
                                    moon_phase_description = c('New','Waxing Crescent','First Quarter','Waxing Gibbous','Full','Waning Gibbous','Third Quarter','Waning Crescent'))

  # check for missing key or empty environment variable
  if(missing(api_key) & Sys.getenv('CLIMACELL_API') == '') {
    stop("No API key provided nor default CLIMACELL_API environment variable found.\nPlease provide valid API key.")
  }

  # basic way of assigning environment variable that may not exist
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

  if(missing(timestep) | is.null(timestep)) {
    message("No timestep provided. Setting to '1d'!")
    timestep <- '1d'
  } else if(timestep != '1d') {
    message("Timestep must be '1d' only. Setting to '1d'!")
    timestep <- '1d'
  }

  # this code block will probably not trigger, but just in case.
  if(!timestep %in% c('1d')) {
    message("Sunrise, Sunset, and Moon Phase can only be retrieved if timestep is '1d'.")
    message("Adjusting timestep value to be '1d'.")
    timestep <- '1d'
  }

  if(timestep == '1d' & is.null(start_time)) {
    message("No start time provided. Using current system time in UTC for start_time.")
    start_time <- lubridate::format_ISO8601(lubridate::with_tz(time = Sys.time(), tzone = 'UTC'), usetz = T)
  } else {
    # if user has already provided a start_time parameter value
    start_time <- lubridate::with_tz(time = start_time, tzone = 'UTC')
    start_time <- lubridate::format_ISO8601(x = start_time, usetz = T)
  }

  if (timestep == '1d' & is.null(end_time)) {
    message("No end time provided. End time will be adjusted for 15 days from current system time!")
    end_time <- lubridate::with_tz(time = Sys.time() + lubridate::days(15), tzone = 'UTC')
    end_time <- lubridate::format_ISO8601(x = end_time, usetz = T)
  } else {
    end_time <- lubridate::with_tz(time = end_time, tzone = 'UTC')
    end_time <- lubridate::format_ISO8601(x = end_time, usetz = T)
  }

  # make sure start time is before end time
  if(start_time > end_time) {
    stop("Start time cannot be later than the end time!")
  }

  # error handling for timestep 1d allows for only 15 days max into future from current actual time

  current_time <- lubridate::with_tz(lubridate::now(), tzone = 'UTC')

  user_st_utc <- lubridate::ymd_hms(start_time)
  user_et_utc <- lubridate::ymd_hms(end_time)

  # define the minimum allowable time based on timestep
  min_time_utc <- current_time

  # define the maximum allowable time based on timestep
  max_time_utc <- current_time + lubridate::ddays(15)

  # start time cannot be more than 6 hours before from current actual time
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

  if(st_max_chk < 1440.0) {
    stop("Start time cannot be less than 24 hours from maximum allowable time for this timestep!")
  }

  # determine difference in time between end time and maximum allowable time
  # et_max_chk: difference between maximum limit time and user end time (if < 0, user end time is more than limit)
  et_max_chk <- lubridate::time_length(lubridate::interval(start = user_et_utc, end = max_time_utc), unit = 'hours')

  if(et_max_chk < 0) {
    message('End time is more than 15 days ahead of the current system time!')
    message('End time has been readjusted to be no more than 15 days ahead of current system time.')
    end_time <- lubridate::with_tz(lubridate::now() + lubridate::dhours(15), tzone = 'UTC')
    end_time <- lubridate::format_ISO8601(x = end_time, usetz = T)
  }

  # need to make sure there is adequate difference between start & end times provided by user

  et_st_chk <- lubridate::time_length(lubridate::interval(start = user_st_utc, end = user_et_utc), unit = 'minutes')

  if(et_st_chk < 1440.0) {
    stop('Difference between start time and end time cannot be less than 24 hours!')
  }

  # process for API retrieval
  latlong <- paste0(lat, ', ', long)

  # reference note (14 Mar 2021): the sunrise, sunset, and moonphase fields were not working till I added in the temperature field (any other field would work I suspect). I added it in, but don't use it and was able to get values for the celestial related fields - prior to this, I was getting NULL values.

  # get results
  result <- httr::content(
    httr::GET(
      url = 'https://data.climacell.co/v4/timelines',
      httr::add_headers('apikey'= api_key),
      httr::add_headers('content-type:' = 'application/json'),
      query = list(location = latlong,
                   fields = 'sunriseTime',
                   fields = 'sunsetTime',
                   fields = 'moonPhase',
                   fields = 'temperature',
                   timesteps = timestep,
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
    sunrise_time = cln_result %>%
      dplyr::filter(stringr::str_detect(pattern = 'intervals.values.sunriseTime', string = .data$name)) %>%
      dplyr::select(.data$value) %>%
      dplyr::pull(),
    sunset_time = cln_result %>%
      dplyr::filter(stringr::str_detect(pattern = 'intervals.values.sunsetTime', string = .data$name)) %>%
      dplyr::select(.data$value) %>%
      dplyr::pull(),
    moon_phase_code = cln_result %>%
      dplyr::filter(stringr::str_detect(pattern = 'intervals.values.moonPhase', string = .data$name)) %>%
      dplyr::select(.data$value) %>%
      dplyr::pull()
  )

  # format & join with moon phase dictionary
  final <- cln_out %>%
    dplyr::mutate(
      start_time = lubridate::ymd_hms(.data$start_time, tz = 'UTC'),
      sunrise_time = lubridate::ymd_hms(.data$sunrise_time, tz = 'UTC'),
      sunset_time = lubridate::ymd_hms(.data$sunset_time, tz = 'UTC'),
      moon_phase_code = as.integer(.data$moon_phase_code)
    ) %>%
    dplyr::left_join(moon_phase_dict, by = c('moon_phase_code' = 'moon_phase_code'))

  return(final)

}
