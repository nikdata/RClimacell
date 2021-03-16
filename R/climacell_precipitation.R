#' Precipitation Readings from Climacell
#'
#' \code{climacell_precip} returns a tibble that consists of precipitation related variables (returned values are in metric units) using the Climacell API. These variables consist of precipitation intensity, precipitation probability, precipitation description, visibility, surface & sea level pressure, cloud cover & ceiling, and a weather description.
#'
#' @description This function will make a call to the Climacell API and retrieve precipitation related (including cloud cover & pressure) values.
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
#' climacell_precip(
#'   api_key = Sys.getenv('CLIMACELL_API'),
#'   lat = 0,
#'   long = 0,
#'   timestep = 'current')
#' }
#'
climacell_precip <- function(api_key, lat, long, timestep, start_time=NULL, end_time=NULL) {

  # define table for precipitation_type codes
  precip_type_dict <- tibble::tibble(precipitation_type_code = c(0,1,2,3,4),
                                     precipitation_type_desc = c(NA,'Rain', 'Snow', 'Freezing Rain', 'Ice'))

  # define table for weather_code codes
  weather_code_dict <- tibble::tibble(weather_code = c(   0L, 1000L, 1001L,
                                                          1100L, 1101L, 1102L,
                                                          2000L, 2100L, 3000L,
                                                          3001L, 3002L, 4000L,
                                                          4001L, 4200L, 4201L,
                                                          5000L, 5001L, 5100L,
                                                          5101L, 6000L, 6001L,
                                                          6200L, 6201L, 7000L,
                                                          7101L, 7102L, 8000),
                                      weather_desc = c('Unknown', 'Clear', 'Cloudy',
                                                       'Mostly Clear', 'Partly Cloudy', 'Mostly Cloudy',
                                                       'Fog', 'Light Fog', 'Light Wind',
                                                       'Wind', 'Strong Wind', 'Drizzle',
                                                       'Rain', 'Light Rain', 'Heavy Rain',
                                                       'Snow', 'Flurries', 'Light Snow',
                                                       'Heavy Snow', 'Freezing Drizzle', 'Freezing Rain',
                                                       'Light Freezing Rain', 'Heavy Freezing Rain', 'Ice Pellets',
                                                       'Heavy Ice Pellets', 'Light Ice Pellets', 'Thunderstorm')
  )

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
                   fields = 'precipitationIntensity',
                   fields = 'precipitationProbability',
                   fields = 'precipitationType',
                   fields = 'visibility',
                   fields = 'pressureSurfaceLevel',
                   fields = 'pressureSeaLevel',
                   fields = 'cloudCover',
                   fields = 'cloudBase',
                   fields = 'cloudCeiling',
                   fields = 'solarGHI',
                   fields = 'weatherCode',
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

  # visbility values are not returned for all dates
  visibility_results <- cln_result %>%
    dplyr::filter(stringr::str_detect(pattern = 'startTime', string = .data$name) | stringr::str_detect(pattern = 'visibility', string = .data$name))

  df_visibility <- visibility_results %>%
    dplyr::left_join(
      visibility_results %>%
        dplyr::filter(stringr::str_detect(pattern = 'startTime', string = .data$name)) %>%
        dplyr::mutate(index = dplyr::row_number()),
      by = c('name','value')
    ) %>%
    dplyr::mutate(
      name = gsub(pattern = 'intervals.', replacement = '', x = .data$name),
      name = gsub(pattern = 'values.', replacement = '', x = .data$name),
      name = gsub(pattern = 'startTime', replacement = 'start_time', x = .data$name),
      name = gsub(pattern = 'visibility', replacement = 'visibility', x = .data$name)
    ) %>%
    tidyr::fill(.data$index, .direction = 'down') %>%
    tidyr::pivot_wider(
      names_from = .data$name,
      values_from = .data$value
    ) %>%
    dplyr::select(-.data$index)

  # let's get the cloud cover data out first (if any)
  # cloud cover varies big time.
  cloud_results <- cln_result %>%
    dplyr::filter(stringr::str_detect(pattern = 'startTime', string = .data$name) | stringr::str_detect(pattern = 'cloud', string = .data$name))

  df_cloud <- cloud_results %>%
    dplyr::left_join(
      cloud_results %>%
        dplyr::filter(stringr::str_detect(pattern = 'startTime', string = .data$name)) %>%
        dplyr::mutate(index = dplyr::row_number()),
      by = c('name','value')
    ) %>%
    dplyr::mutate(
      name = gsub(pattern = 'intervals.', replacement = '', x = .data$name),
      name = gsub(pattern = 'values.', replacement = '', x = .data$name),
      name = gsub(pattern = 'startTime', replacement = 'start_time', x = .data$name),
      name = gsub(pattern = 'cloudCover', replacement = 'cloud_cover', x = .data$name),
      name = gsub(pattern = 'cloudBase', replacement = 'cloud_base', x = .data$name),
      name = gsub(pattern = 'cloudCeiling', replacement = 'cloud_ceiling', x = .data$name)
    ) %>%
    tidyr::fill(.data$index, .direction = 'down') %>%
    tidyr::pivot_wider(
      names_from = .data$name,
      values_from = .data$value
    ) %>%
    dplyr::select(-.data$index)

  # check to make sure that columns cloud_base and cloud_ceiling are present
  cb_chk <- assertthat::has_name(df_cloud, 'cloud_base')
  cc_chk <- assertthat::has_name(df_cloud, 'cloud_ceiling')

  # if any column is missing, add it to df_cloud
  if(cb_chk == FALSE) {
    df_cloud <- df_cloud %>%
      tibble::add_column(cloud_base = NA)
  }

  if(cc_chk == FALSE) {
    df_cloud <- df_cloud %>%
      tibble::add_column(cloud_ceiling = NA)
  }

  # now do the same with pressure levels

  prs_results <- cln_result %>%
    dplyr::filter(stringr::str_detect(pattern = 'startTime', string = .data$name) | stringr::str_detect(pattern = 'pressure', string = .data$name))

  df_pressure <- prs_results %>%
    dplyr::left_join(
      prs_results %>%
        dplyr::filter(stringr::str_detect(pattern = 'startTime', string = .data$name)) %>%
        dplyr::mutate(index = dplyr::row_number()),
      by = c('name','value')
    ) %>%
    dplyr::mutate(
      name = gsub(pattern = 'intervals.', replacement = '', x = .data$name),
      name = gsub(pattern = 'values.', replacement = '', x = .data$name),
      name = gsub(pattern = 'startTime', replacement = 'start_time', x = .data$name),
      name = gsub(pattern = 'pressureSurfaceLevel', replacement = 'pressure_surface_level', x = .data$name),
      name = gsub(pattern = 'pressureSeaLevel', replacement = 'pressure_sea_level', x = .data$name)
    ) %>%
    tidyr::fill(.data$index, .direction = 'down') %>%
    tidyr::pivot_wider(
      names_from = .data$name,
      values_from = .data$value
    ) %>%
    dplyr::select(-.data$index)

  # check to make sure that columns cloud_base and cloud_ceiling are present
  psurf_chk <- assertthat::has_name(df_pressure, 'pressure_surface_level')
  psea_chk <- assertthat::has_name(df_pressure, 'pressure_sea_level')

  # if any column is missing, add it to df_cloud
  if(psurf_chk == FALSE) {
    df_pressure <- df_pressure %>%
      tibble::add_column(pressure_surface_level = NA)
  }

  if(psea_chk == FALSE) {
    df_pressure <- df_pressure %>%
      tibble::add_column(pressure_sea_level = NA)
  }

  # now let's focus on the other stuff that is not related to cloud cover or pressure level
  cln_out <- tibble::tibble(
    start_time = cln_result %>%
      dplyr::filter(stringr::str_detect(pattern = 'startTime', string = .data$name)) %>%
      dplyr::select(.data$value) %>%
      dplyr::pull(),
    precipitation_intensity = cln_result %>%
      dplyr::filter(stringr::str_detect(pattern = 'intervals.values.precipitationIntensity', string = .data$name)) %>%
      dplyr::select(.data$value) %>%
      dplyr::pull(),
    precipitation_probability = cln_result %>%
      dplyr::filter(stringr::str_detect(pattern = 'intervals.values.precipitationProbability', string = .data$name)) %>%
      dplyr::select(.data$value) %>%
      dplyr::pull(),
    precipitation_type_code = cln_result %>%
      dplyr::filter(stringr::str_detect(pattern = 'intervals.values.precipitationType', string = .data$name)) %>%
      dplyr::select(.data$value) %>%
      dplyr::pull(),
    solar_ghi = cln_result %>%
      dplyr::filter(stringr::str_detect(pattern = 'intervals.values.solarGHI', string = .data$name)) %>%
      dplyr::select(.data$value) %>%
      dplyr::pull(),
    weather_code = cln_result %>%
      dplyr::filter(stringr::str_detect(pattern = 'intervals.values.weatherCode', string = .data$name)) %>%
      dplyr::select(.data$value) %>%
      dplyr::pull()
  )

  # combine the two (cloud cover) and the cln_out together

  cln_combo <- cln_out %>%
    dplyr::left_join(df_cloud, by = c('start_time')) %>%
    dplyr::left_join(df_visibility, by = c('start_time')) %>%
    dplyr::left_join(df_pressure, by = c('start_time'))

  # change data types
  cln_combo <- cln_combo %>%
    dplyr::mutate(
      start_time = lubridate::ymd_hms(.data$start_time, tz = 'UTC'),
      precipitation_intensity = as.numeric(.data$precipitation_intensity),
      precipitation_probability = as.numeric(.data$precipitation_probability),
      precipitation_type_code = as.integer(.data$precipitation_type_code),
      visibility = as.numeric(.data$visibility),
      pressure_surface_level = as.numeric(.data$pressure_surface_level),
      pressure_sea_level = as.numeric(.data$pressure_sea_level),
      cloud_cover = as.numeric(.data$cloud_cover),
      cloud_base = as.numeric(.data$cloud_base),
      cloud_ceiling = as.numeric(.data$cloud_ceiling),
      solar_ghi = as.numeric(.data$solar_ghi),
      weather_code = as.integer(.data$weather_code)
    )

  # combine the dictionary values and rearrange columns
  cln_combo <- cln_combo %>%
    dplyr::left_join(precip_type_dict, by = c('precipitation_type_code' = 'precipitation_type_code')) %>%
    dplyr::left_join(weather_code_dict, by = c('weather_code' = 'weather_code')) %>%
    dplyr::select(.data$start_time,
                  .data$precipitation_intensity,
                  .data$precipitation_probability,
                  .data$precipitation_type_code,
                  .data$precipitation_type_desc,
                  .data$visibility,
                  .data$pressure_surface_level,
                  .data$pressure_sea_level,
                  .data$cloud_cover,
                  .data$cloud_base,
                  .data$cloud_ceiling,
                  .data$solar_ghi,
                  .data$weather_code,
                  .data$weather_desc)

  return(cln_combo)
}
