library(httr)
library(dplyr)


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





httr::content(
  httr::GET(
    url = 'https://data.climacell.co/v4/timelines',
    httr::add_headers('apikey'= '804rce5PoZ1HGkPEO6VFIfGGXl9RASEa'),
    httr::add_headers('content-type:' = 'application/json'),
    query = list(location = '41.71530861778755, -93.61438914464473',
                 fields = 'temperature',
                 fields = 'temperatureApparent',
                 fields = 'dewPoint',
                 fields = 'humidity',
                 timesteps='1d',
                 startTime = parsedate::format_iso_8601(Sys.time()),
                 endTime = parsedate::format_iso_8601(Sys.Date() + lubridate::days(3))
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
                                  end_time = Sys.time() + lubridate::days(7))

# scenario 8: all correct wind
RClimacell::climacell_wind(lat = 41.71530861778755,
                                  long = -93.61438914464473,
                                  timestep = '1d',
                                  start_time = Sys.time(),
                                  end_time = Sys.time() + lubridate::days(7))
