#' Precipitation Readings from Climacell
#'
#' \code{climacell_precip} returns a tibble that consists of precipitation related variables (returned values are in metric units) using the Climacell API. These variables consist of precipitation intensity, precipitation probability, precipitation description, visibility, surface & sea level pressure, cloud cover & ceiling, and a weather description.
#'
#' @description This function will make a call to the Climacell API and retrieve precipitation related (including cloud cover & pressure) values.
#'
#' @param api_key character string representing the private API key. Provided by user or loaded automatically from environment variable (environment variable must be called "CLIMACELL_API")
#' @param lat a numeric value (or a string that can be coerced to numeric) representing the latitude of the location
#' @param long a numeric value (or a string that can be coerced to numeric) representing the longitude of the location
#' @param timestep a 'step' value for the time. Choose one of the following valid values: c('1d', '1h', '30m','15m','5m','1m','current')
#' @param start_time the start date and time of the query in \href{https://en.wikipedia.org/wiki/ISO_8601}{ISO8601} format. This value cannot be more than 6 hours prior to the current local time. OPTIONAL if timestep is 'current'.
#' @param end_time the end date and time of the query in \href{https://en.wikipedia.org/wiki/ISO_8601}{ISO8601} format. The maximum end date/time depends on the timestep value chosen (see vignette for more information). OPTIONAL if timestep is 'current' or you wish to get the maximum results possible.
#'
#' @return a tibble
#' @export
#'
#' @import dplyr
#' @import tibble
#' @import httr
#' @import parsedate
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

  # check for missig key or empty environment variable
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
    } else {
      start_time <- parsedate::format_iso_8601(start_time)
    }
  }

  if(timestep != 'current') {
    if(is.na(parsedate::parse_iso_8601(end_time))) {
      stop("End time value is not in ISO 8601 format!")
    } else {
      end_time <- parsedate::format_iso_8601(end_time)
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
      httr::add_headers('apikey'= '804rce5PoZ1HGkPEO6VFIfGGXl9RASEa'),
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

  # let's get the cloud cover data out first (if any)
  # cloud cover varies big time.
  my_results <- cln_result %>%
    dplyr::filter(stringr::str_detect(pattern = 'startTime', string = .data$name) | stringr::str_detect(pattern = 'cloud', string = .data$name))

  # my_results %>%
  #   dplyr::filter(stringr::str_detect(pattern = 'startTime', string = .data$name)) %>%
  #   dplyr::mutate(index = dplyr::row_number())

  df_cloud <- my_results %>%
    dplyr::left_join(
      my_results %>%
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

  # now let's focus on the other stuff that is not related to cloud cover
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
    visibility = cln_result %>%
      dplyr::filter(stringr::str_detect(pattern = 'intervals.values.visibility', string = .data$name)) %>%
      dplyr::select(.data$value) %>%
      dplyr::pull(),
    pressure_surface_level = cln_result %>%
      dplyr::filter(stringr::str_detect(pattern = 'intervals.values.pressureSurfaceLevel', string = .data$name)) %>%
      dplyr::select(.data$value) %>%
      dplyr::pull(),
    pressure_sea_level = cln_result %>%
      dplyr::filter(stringr::str_detect(pattern = 'intervals.values.pressureSeaLevel', string = .data$name)) %>%
      dplyr::select(.data$value) %>%
      dplyr::pull(),
    # cloud_cover = cln_result %>%
    #   dplyr::filter(stringr::str_detect(pattern = 'intervals.values.cloudCover', string = .data$name)) %>%
    #   dplyr::select(.data$value) %>%
    #   dplyr::pull(),
    # cloud_base = cln_result %>%
    #   dplyr::filter(stringr::str_detect(pattern = 'intervals.values.cloudBase', string = .data$name)) %>%
    #   dplyr::select(.data$value) %>%
    #   dplyr::pull(),
    # cloud_ceiling = cln_result %>%
    #   dplyr::filter(stringr::str_detect(pattern = 'intervals.values.cloudCeiling', string = .data$name)) %>%
    #   dplyr::select(.data$value) %>%
    #   dplyr::pull(),
    weather_code = cln_result %>%
      dplyr::filter(stringr::str_detect(pattern = 'intervals.values.weatherCode', string = .data$name)) %>%
      dplyr::select(.data$value) %>%
      dplyr::pull()
  )

  # combine the two (cloud cover) and the cln_out together

  cln_combo <- cln_out %>%
    dplyr::left_join(df_cloud, by = c('start_time'))

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
                  .data$weather_code,
                  .data$weather_desc)

  return(cln_combo)
}
