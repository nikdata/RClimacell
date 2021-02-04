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
)
