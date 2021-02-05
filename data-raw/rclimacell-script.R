library(httr)
library(dplyr)

`%>%` <- magrittr::`%>%`


result <- httr::content(
  httr::GET(
    url = 'https://data.climacell.co/v4/timelines',
    httr::add_headers('apikey'= '804rce5PoZ1HGkPEO6VFIfGGXl9RASEa'),
    httr::add_headers('content-type:' = 'application/json'),
    query = list(location = '41.71530861778755, -93.61438914464473',
                 fields = 'temperature',
                 fields = 'temperatureApparent',
                 fields = 'dewPoint',
                 fields = 'humidity',
                 timesteps='1m',
                 startTime = '2021-02-04T20:35:00Z'
                 #endTime = '2021-02-10T20:00:00-06:00'
                 )
  )
)

# View(tibble::tibble(as.data.frame(result)))

# test cases


# climacell_temperature(lat = 41.71530861778755, long = -93.61438914464473, timestep = '1m', end_time = '2021-03-01T06:00:00-06:00')
#
#
# climacell_temperature(lat = '41.71530861778755', long = -93.61438914464473, timestep = '1d', start_time = '2021-02-04T15:20:00-06:00', end_time = '2021-02-08T08:00:00-06:00')

tmp <- tibble::enframe(unlist(result))

tmp2 <- tmp %>%
  dplyr::mutate(
    name = gsub(pattern = 'data.timelines.', replacement = '', x = name),
    name = gsub(pattern = 'temperatureApparent', replacement = 'realFeel', x = name)
  ) %>%
  dplyr::filter(stringr::str_detect(pattern = 'intervals', string = name))

tibble::tibble(
  start_time = tmp2 %>% dplyr::filter(stringr::str_detect(pattern = 'startTime', string = name)) %>% dplyr::select(value) %>% dplyr::pull(),
  temp_c = tmp2 %>% dplyr::filter(stringr::str_detect(pattern = 'intervals.values.temperature', string = name)) %>% dplyr::select(value) %>% dplyr::pull(),
  temp_feel_c = tmp2 %>% dplyr::filter(stringr::str_detect(pattern = 'intervals.values.realFeel', string = name)) %>% dplyr::select(value) %>% dplyr::pull(),
  dewpoint = tmp2 %>% dplyr::filter(stringr::str_detect(pattern = 'intervals.values.dewPoint', string = name)) %>% dplyr::select(value) %>% dplyr::pull(),
  humidity = tmp2 %>% dplyr::filter(stringr::str_detect(pattern = 'intervals.values.humidity', string = name)) %>% dplyr::select(value) %>% dplyr::pull()
  )


httr::http_error(
    httr::GET(
      url = 'https://data.climacell.co/v4/timelines',
      add_headers('apikey'= '804rce5PoZ1HGkPEO6VFIfGGXl9RASEa'),
      add_headers('content-type:' = 'application/json'),
      query = list(location = '41.71530861778755, -93.61438914464473',
                   fields = 'temperature',
                   timesteps='MMM'
                   # startTime = '2021-02-03T20:00:00-06:00',
                   # endTime = '2021-02-04T20:00:00-06:00'
      )
    )
  )



result2 <- httr::content(
  httr::GET(
    url = 'https://data.climacell.co/v4/timelines',
    httr::add_headers('apikey'= '804rce5PoZ1HGkPEO6VFIfGGXl9RASEa'),
    httr::add_headers('content-type:' = 'application/json'),
    query = list(location = '41.71530861778755, -93.61438914464473',
                 fields = 'windSpeed',
                 fields = 'windDirection',
                 fields = 'windGust',
                 timesteps='1d',
                 startTime = parsedate::format_iso_8601(Sys.time()),
                 endTime = parsedate::format_iso_8601(Sys.Date() + lubridate::days(5))
    )
  )
)


tidyresult2 <- tibble::enframe(unlist(result2)) %>%
  dplyr::mutate(
    name = gsub(pattern = 'data.timelines.', replacement = '', x = name)
  ) %>%
  dplyr::filter(stringr::str_detect(pattern = 'intervals', string = name))

tibble::tibble(
  start_time = tidyresult2 %>% dplyr::filter(stringr::str_detect(pattern = 'startTime', string = name)) %>% dplyr::select(value) %>% dplyr::pull(),
  wind_speed = tidyresult2 %>% dplyr::filter(stringr::str_detect(pattern = 'intervals.values.windSpeed', string = name)) %>% dplyr::select(value) %>% dplyr::pull(),
  wind_gust = tidyresult2 %>% dplyr::filter(stringr::str_detect(pattern = 'intervals.values.windGust', string = name)) %>% dplyr::select(value) %>% dplyr::pull(),
  wind_direction = tidyresult2 %>% dplyr::filter(stringr::str_detect(pattern = 'intervals.values.windDirection', string = name)) %>% dplyr::select(value) %>% dplyr::pull()
)


results3 <- httr::content(
  httr::GET(
    url = 'https://data.climacell.co/v4/timelines',
    httr::add_headers('apikey'= '804rce5PoZ1HGkPEO6VFIfGGXl9RASEa'),
    httr::add_headers('content-type:' = 'application/json'),
    query = list(location = '41.71530861778755, -93.61438914464473',
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
                 timesteps='1d',
                 startTime = parsedate::format_iso_8601(Sys.time()),
                 endTime = parsedate::format_iso_8601(Sys.Date() + lubridate::days(5))
    )
  )
)

tidyresult3 <- tibble::enframe(unlist(results3)) %>%
  dplyr::mutate(
    name = gsub(pattern = 'data.timelines.', replacement = '', x = name)
  ) %>%
  dplyr::filter(stringr::str_detect(pattern = 'intervals', string = name))

cln3 <- tibble::tibble(
  start_time = tidyresult3 %>%
    dplyr::filter(stringr::str_detect(pattern = 'startTime', string = name)) %>%
    dplyr::select(value) %>%
    dplyr::pull(),
  precipitation_intensity = tidyresult3 %>%
    dplyr::filter(stringr::str_detect(pattern = 'intervals.values.precipitationIntensity', string = name)) %>%
    dplyr::select(value) %>%
    dplyr::pull(),
  precipitation_probability = tidyresult3 %>%
    dplyr::filter(stringr::str_detect(pattern = 'intervals.values.precipitationProbability', string = name)) %>%
    dplyr::select(value) %>%
    dplyr::pull(),
  precipitation_type_code = tidyresult3 %>%
    dplyr::filter(stringr::str_detect(pattern = 'intervals.values.precipitationType', string = name)) %>%
    dplyr::select(value) %>%
    dplyr::pull(),
  visibility = tidyresult3 %>%
    dplyr::filter(stringr::str_detect(pattern = 'intervals.values.visibility', string = name)) %>%
    dplyr::select(value) %>%
    dplyr::pull(),
  pressure_surface_level = tidyresult3 %>%
    dplyr::filter(stringr::str_detect(pattern = 'intervals.values.pressureSurfaceLevel', string = name)) %>%
    dplyr::select(value) %>%
    dplyr::pull(),
  pressure_sea_level = tidyresult3 %>%
    dplyr::filter(stringr::str_detect(pattern = 'intervals.values.pressureSeaLevel', string = name)) %>%
    dplyr::select(value) %>%
    dplyr::pull(),
  cloud_cover = tidyresult3 %>%
    dplyr::filter(stringr::str_detect(pattern = 'intervals.values.cloudCover', string = name)) %>%
    dplyr::select(value) %>%
    dplyr::pull(),
  cloud_base = tidyresult3 %>%
    dplyr::filter(stringr::str_detect(pattern = 'intervals.values.cloudBase', string = name)) %>%
    dplyr::select(value) %>%
    dplyr::pull(),
  cloud_ceiling = tidyresult3 %>%
    dplyr::filter(stringr::str_detect(pattern = 'intervals.values.cloudCeiling', string = name)) %>%
    dplyr::select(value) %>%
    dplyr::pull(),
  weather_code = tidyresult3 %>%
    dplyr::filter(stringr::str_detect(pattern = 'intervals.values.weatherCode', string = name)) %>%
    dplyr::select(value) %>%
    dplyr::pull()
)

cln3 %>%
  dplyr::mutate(
    start_time = lubridate::ymd_hms(start_time, tz = 'UTC'),
    precipitation_intensity = as.numeric(precipitation_intensity),
    precipitation_probability = as.numeric(precipitation_probability),
    precipitation_type_code = as.integer(precipitation_type_code),
    visibility = as.numeric(visibility),
    pressure_surface_level = as.numeric(pressure_surface_level),
    pressure_sea_level = as.numeric(pressure_sea_level),
    cloud_cover = as.numeric(cloud_cover),
    cloud_base = as.numeric(cloud_base),
    cloud_ceiling = as.numeric(cloud_ceiling),
    weather_code = as.integer(weather_code)
  ) %>%
  dplyr::left_join(precip_type_dict, by = c('precipitation_type_code' = 'precipitation_type_code')) %>%
  dplyr::left_join(weather_code_dict, by = c('weather_code' = 'weather_code')) %>%
  dplyr::glimpse()




# TEST CASES
# scenario 1: missing start_time; end time is beyond 6 hours into future because to timestep of 1m
RClimacell::climacell_temperature(lat = 41.71530861778755,
                                  long = -93.61438914464473,
                                  timestep = '1m',
                                  end_time = '2021-03-01T06:00:00-06:00')

# scenario 2: missing start_time; end time is beyond 15 days into future because to timestep of 1d
RClimacell::climacell_temperature(lat = 41.71530861778755,
                                  long = -93.61438914464473,
                                  timestep = '1d',
                                  end_time = '2021-03-01T06:00:00-06:00')

# scenario 3: start_time given, no end time. timestep is current.
RClimacell::climacell_temperature(lat = 41.71530861778755,
                                  long = -93.61438914464473,
                                  timestep = 'current',
                                  start_time = '2021-03-01T06:00:00-06:00')

# scenario 4: no start_time given, end time. timestep is current.
RClimacell::climacell_temperature(lat = 41.71530861778755,
                                  long = -93.61438914464473,
                                  timestep = 'current',
                                  end_time = '2021-03-01T06:00:00-06:00')

# scenario 5: start_time given, end time given. timestep is 1d. end time is beyond 15 day limit
RClimacell::climacell_temperature(lat = 41.71530861778755,
                                  long = -93.61438914464473,
                                  timestep = '1d',
                                  start_time = '2021-02-04T20:00:00-06:00',
                                  end_time = '2021-03-01T06:00:00-06:00')

# scenario 6: start_time given, end time given. timestep is 1d. start time syntax is wrong
RClimacell::climacell_temperature(lat = 41.71530861778755,
                                  long = -93.61438914464473,
                                  timestep = '1d',
                                  start_time = '2021-02-04',
                                  end_time = '2021-02-10T06:00:00-06:00')

# scenario 7: all correct
RClimacell::climacell_temperature(lat = 41.71530861778755,
                                  long = -93.61438914464473,
                                  timestep = '1d',
                                  start_time = Sys.time(),
                                  end_time = Sys.time() + lubridate::days(7)) %>%
  dplyr::glimpse()

# scenario 8: all correct wind
RClimacell::climacell_wind(lat = 41.71530861778755,
                                  long = -93.61438914464473,
                                  timestep = '1d',
                                  start_time = Sys.time(),
                                  end_time = Sys.time() + lubridate::days(7)) %>%
  dplyr::glimpse()

# scenario 9: all correct precip
RClimacell::climacell_precip(lat = 41.71530861778755,
                           long = -93.61438914464473,
                           timestep = '1d',
                           start_time = Sys.time(),
                           end_time = Sys.time() + lubridate::days(7)) %>%
  dplyr::glimpse()
