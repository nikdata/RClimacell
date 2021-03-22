#' Climacell Core Layer Data
#'
#' @description \code{climacell_core} returns a tibble that contains all of the Core Layer data from the Climacell version 4 API using the Timelines interface. The intent of this function is to retrieve all of the Core Layer data in a single API call. This is especially handy when using the free API as it limits the usage of the API based on hourly rate and daily usage.
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
#' @import utils
#' @import tidyselect
#'
#' @importFrom stringr str_detect
#' @importFrom magrittr `%>%`
#' @importFrom rlang .data
#' @importFrom tidyr fill pivot_wider
#'
#' @examples
#' \dontrun{
#' climacell_core(
#'   api_key = Sys.getenv('CLIMACELL_API'),
#'   lat = 0,
#'   long = 0,
#'   timestep = '1d',
#'   start_time = lubridate::now(),
#'   end_time = lubridate::now + lubridate::days(5))
#' }
#'

climacell_core <- function(api_key, lat, long, timestep, start_time=NULL, end_time=NULL) {

  # retrieve the appropriate dictionaries
  moon_dict <- dict_moonphase()
  precip_dict <- dict_preciptype()
  weather_dict <- dict_weathercode()

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

  # messsage for timestep other than 1D
  if(timestep != '1d') {
    message("Moonphase, Sunrise Time, and Sunset Times are only available if timestep is '1d'.")
  }

  # process for API retrieval

  latlong <- paste0(lat, ', ', long)

  # get results

  if(timestep != '1d') {
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
                     fields = 'precipitationIntensity',
                     fields = 'precipitationProbability',
                     fields = 'precipitationType',
                     fields = 'windSpeed',
                     fields = 'windDirection',
                     fields = 'windGust',
                     fields = 'visibility',
                     fields = 'pressureSurfaceLevel',
                     fields = 'pressureSeaLevel',
                     fields = 'cloudCover',
                     fields = 'cloudBase',
                     fields = 'cloudCeiling',
                     fields = 'solarGHI',
                     fields = 'weatherCode',
                     timesteps = timestep,
                     startTime = start_time,
                     endTime = end_time
        )
      )
    )
  } else {
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
                     fields = 'precipitationIntensity',
                     fields = 'precipitationProbability',
                     fields = 'precipitationType',
                     fields = 'windSpeed',
                     fields = 'windDirection',
                     fields = 'windGust',
                     fields = 'visibility',
                     fields = 'pressureSurfaceLevel',
                     fields = 'pressureSeaLevel',
                     fields = 'cloudCover',
                     fields = 'cloudBase',
                     fields = 'cloudCeiling',
                     fields = 'solarGHI',
                     fields = 'weatherCode',
                     fields = 'sunriseTime',
                     fields = 'sunsetTime',
                     fields = 'moonPhase',
                     timesteps = timestep,
                     startTime = start_time,
                     endTime = end_time
        )
      )
    )
  }

  tidy_result <- tibble::enframe(unlist(result))

  cln_result <- tidy_result %>%
    dplyr::mutate(
      name = gsub(pattern = 'data.timelines.', replacement = '', x = .data$name)
    ) %>%
    dplyr::filter(stringr::str_detect(pattern = 'intervals', string = .data$name))

  df_out <- cln_result %>%
    dplyr::mutate(
      start_time = ifelse(.data$name == 'intervals.startTime', .data$value, NA)
    ) %>%
    tidyr::fill(.data$start_time, .direction = 'down') %>%
    dplyr::filter(.data$name != 'intervals.startTime') %>%
    dplyr::mutate(
      var_name = gsub(pattern = 'intervals.values.', replacement = '', x = .data$name),
      var_name = dplyr::case_when(
        .data$var_name == 'temperature' ~ 'temp_c',
        .data$var_name == 'temperatureApparent' ~ 'temp_feel_c',
        .data$var_name == 'precipitationIntensity' ~ 'precipitation_intensity',
        .data$var_name == 'precipitationProbability' ~ 'precipitation_probability',
        .data$var_name == 'precipitationType' ~ 'precipitation_type_code',
        .data$var_name == 'dewPoint' ~ 'dewpoint',
        .data$var_name == 'windSpeed' ~ 'wind_speed',
        .data$var_name == 'windDirection' ~ 'wind_direction',
        .data$var_name == 'windGust' ~ 'wind_gust',
        .data$var_name == 'pressureSurfaceLevel' ~ 'pressure_surface_level',
        .data$var_name == 'pressureSeaLevel' ~ 'pressure_sea_level',
        .data$var_name == 'cloudCover' ~ 'cloud_cover',
        .data$var_name == 'solarGHI' ~ 'solar_ghi',
        .data$var_name == 'weatherCode' ~ 'weather_code',
        .data$var_name == 'cloudBase' ~ 'cloud_base',
        .data$var_name == 'cloudCeiling' ~ 'cloud_ceiling',
        .data$var_name == 'humidity' ~ 'humidity',
        .data$var_name == 'visibility' ~ 'visibility',
        .data$var_name == 'sunriseTime' ~ 'sunrise_time',
        .data$var_name == 'sunsetTime' ~ 'sunset_time',
        .data$var_name == 'moonPhase' ~ 'moon_phase_code'
      )
    ) %>%
    dplyr::filter(!is.na(.data$var_name)) %>%
    dplyr::select(-.data$name) %>%
    tidyr::pivot_wider(
      names_from = .data$var_name,
      values_from = .data$value
    )

  colchk_temp <- assertthat::has_name(df_out, 'temp_c')
  colchk_feel <- assertthat::has_name(df_out, 'temp_feel_c')
  colchk_precipint <- assertthat::has_name(df_out, 'precipitation_intensity')
  colchk_precipprob <- assertthat::has_name(df_out, 'precipitation_probability')
  colchk_preciptype <- assertthat::has_name(df_out, 'precipitation_type_code')
  colchk_dew <- assertthat::has_name(df_out, 'dewpoint')
  colchk_wind <- assertthat::has_name(df_out, 'wind_speed')
  colchk_winddir <- assertthat::has_name(df_out, 'wind_direction')
  colchk_windgust <- assertthat::has_name(df_out, 'wind_gust')
  colchk_prssurf <- assertthat::has_name(df_out, 'pressure_surface_level')
  colchk_prssea <- assertthat::has_name(df_out, 'pressure_sea_level')
  colchk_cldcvr <- assertthat::has_name(df_out, 'cloud_cover')
  colchk_solar <- assertthat::has_name(df_out, 'solar_ghi')
  colchk_weacode <- assertthat::has_name(df_out, 'weather_code')
  colchk_cldbse <- assertthat::has_name(df_out, 'cloud_base')
  colchk_cldceil <- assertthat::has_name(df_out, 'cloud_ceiling')
  colchk_humid <- assertthat::has_name(df_out, 'humidity')
  colchk_vis <- assertthat::has_name(df_out, 'visibility')
  colchk_moon <- assertthat::has_name(df_out, 'moon_phase_code')
  colchk_sunrise <- assertthat::has_name(df_out, 'sunrise_time')
  colchk_sunset <- assertthat::has_name(df_out, 'sunset_time')

  # if column does not exist, add

  if(colchk_temp == FALSE) {
    df_out <- df_out %>%
      tibble::add_column(temp_c = NA)
  }
  if(colchk_feel == FALSE) {
    df_out <- df_out %>%
      tibble::add_column(temp_feel_c = NA)
  }
  if(colchk_precipint == FALSE) {
    df_out <- df_out %>%
      tibble::add_column(precipitation_intensity = NA)
  }
  if(colchk_precipprob == FALSE) {
    df_out <- df_out %>%
      tibble::add_column(precipitation_probability = NA)
  }
  if(colchk_preciptype == FALSE) {
    df_out <- df_out %>%
      tibble::add_column(precipitation_type_code = NA)
  }
  if(colchk_dew == FALSE) {
    df_out <- df_out %>%
      tibble::add_column(dewpoint = NA)
  }
  if(colchk_wind == FALSE) {
    df_out <- df_out %>%
      tibble::add_column(wind_speed = NA)
  }
  if(colchk_winddir == FALSE) {
    df_out <- df_out %>%
      tibble::add_column(wind_direction = NA)
  }
  if(colchk_windgust == FALSE) {
    df_out <- df_out %>%
      tibble::add_column(wind_gust = NA)
  }
  if(colchk_prssurf == FALSE) {
    df_out <- df_out %>%
      tibble::add_column(pressure_surface_level = NA)
  }
  if(colchk_prssea == FALSE) {
    df_out <- df_out %>%
      tibble::add_column(pressure_sea_level = NA)
  }
  if(colchk_cldcvr == FALSE) {
    df_out <- df_out %>%
      tibble::add_column(cloud_cover = NA)
  }
  if(colchk_solar == FALSE) {
    df_out <- df_out %>%
      tibble::add_column(solar_ghi = NA)
  }
  if(colchk_weacode == FALSE) {
    df_out <- df_out %>%
      tibble::add_column(weather_code = NA)
  }
  if(colchk_cldbse == FALSE) {
    df_out <- df_out %>%
      tibble::add_column(cloud_base = NA)
  }
  if(colchk_cldceil == FALSE) {
    df_out <- df_out %>%
      tibble::add_column(cloud_ceiling = NA)
  }
  if(colchk_humid == FALSE) {
    df_out <- df_out %>%
      tibble::add_column(humidity = NA)
  }
  if(colchk_vis == FALSE) {
    df_out <- df_out %>%
      tibble::add_column(visibility = NA)
  }

  if(colchk_moon == FALSE) {
    df_out <- df_out %>%
      tibble::add_column(moon_phase_code = NA)
  }
  if(colchk_sunrise == FALSE) {
    df_out <- df_out %>%
      tibble::add_column(sunrise_time = NA)
  }
  if(colchk_sunset == FALSE) {
    df_out <- df_out %>%
      tibble::add_column(sunset_time = NA)
  }

  # encode each column correctly
  df_out_encoded <- df_out %>%
    dplyr::mutate(
      start_time = lubridate::ymd_hms(.data$start_time, tz = 'UTC'),
      sunrise_time = lubridate::ymd_hms(.data$sunrise_time, tz = 'UTC'),
      sunset_time = lubridate::ymd_hms(.data$sunset_time, tz = 'UTC')
    ) %>%
    dplyr::mutate(
      dplyr::across(where(is.character), .fns = as.numeric)
    )

  # add in the descriptions and rearrange
  df_final <- df_out_encoded %>%
    dplyr::left_join(precip_dict, by = 'precipitation_type_code') %>%
    dplyr::left_join(weather_dict, by = 'weather_code') %>%
    dplyr::select(.data$start_time,
                  .data$temp_c,
                  .data$temp_feel_c,
                  .data$weather_code,
                  .data$weather_desc,
                  .data$dewpoint,
                  .data$humidity,
                  .data$wind_speed,
                  .data$wind_direction,
                  .data$wind_gust,
                  .data$solar_ghi,
                  .data$precipitation_type_code,
                  .data$precipitation_type_desc,
                  .data$precipitation_probability,
                  .data$precipitation_intensity,
                  .data$cloud_cover,
                  .data$cloud_base,
                  .data$cloud_ceiling,
                  .data$visibility,
                  .data$pressure_surface_level,
                  .data$pressure_sea_level,
                  .data$sunrise_time,
                  .data$sunset_time,
                  .data$moon_phase_code
    )

  if(timestep == '1d') {
    df_final <- df_final %>%
      dplyr::left_join(moon_dict, by = 'moon_phase_code')
  } else {
    df_final <- df_final %>%
      dplyr::select(-.data$sunrise_time, -.data$sunset_time, -.data$moon_phase_code)
  }

  return(df_final)

}
