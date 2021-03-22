#' Moonphase Dictionary
#'
#' @description this is a helper function that returns the moon phase tibble containing the moon phase codes (which are returned by Climacell API) and their appropriate description.
#'
#' @return a tibble
#'
dict_moonphase <- function() {

  moon_phase_dict <- tibble::tibble(moon_phase_code = as.integer(seq(0,7,1)),
                                    moon_phase_description = c('New','Waxing Crescent',
                                                               'First Quarter','Waxing Gibbous','Full',
                                                               'Waning Gibbous','Third Quarter','Waning Crescent')
                                    )

  return(moon_phase_dict)

}

#' Precipitation Type Dictionary
#'
#' @description this is a helper function that returns the precipitation type tibble containing the precipitation type codes (which are returned by Climacell API) and their appropriate description.
#'
#' @return a tibble
#'

dict_preciptype <- function() {

  precip_type_dict <- tibble::tibble(precipitation_type_code = c(0,1,2,3,4),
                                     precipitation_type_desc = c(NA,'Rain', 'Snow', 'Freezing Rain', 'Ice'))

  return(precip_type_dict)
}

#' Weather Dictionary
#'
#' @description this is a helper function that returns the weather code tibble containing the weather codes (which are returned by Climacell API) and their appropriate description.
#'
#' @return a tibble
#'

dict_weathercode <- function() {

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

  return(weather_code_dict)
}
