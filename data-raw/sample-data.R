# import pipe
`%>%` <- magrittr::`%>%`

# define meta data
api <- Sys.getenv('CLIMACELL_API')
lat_val <- 41.878876
long_val <- -87.635918
st <- Sys.time() - lubridate::hours(5)

# Precipitation Dataset
precip_1m <- RClimacell::climacell_precip(api_key = api,
                                          timestep = '1m',
                                          lat = lat_val,
                                          long = long_val,
                                          start_time = st,
                                          end_time = NULL)

precip_1h <- RClimacell::climacell_precip(api_key = api,
                                          timestep = '1h',
                                          lat = lat_val,
                                          long = long_val,
                                          start_time = st,
                                          end_time = NULL)

precip_1d <- RClimacell::climacell_precip(api_key = api,
                                          timestep = '1d',
                                          lat = lat_val,
                                          long = long_val,
                                          start_time = st,
                                          end_time = NULL)

# Temperature Datasets

temperature_1m <- RClimacell::climacell_temperature(api_key = api,
                                                    timestep = '1m',
                                                    lat = lat_val,
                                                    long = long_val,
                                                    start_time = st,
                                                    end_time = NULL)

temperature_1h <- RClimacell::climacell_temperature(api_key = api,
                                                    timestep = '1h',
                                                    lat = lat_val,
                                                    long = long_val,
                                                    start_time = st,
                                                    end_time = NULL)

temperature_1d <- RClimacell::climacell_temperature(api_key = api,
                                                    timestep = '1d',
                                                    lat = lat_val,
                                                    long = long_val,
                                                    start_time = st,
                                                    end_time = NULL)

# Wind Dataset

wind_1m <- RClimacell::climacell_wind(api_key = api,
                                      timestep = '1m',
                                      lat = lat_val,
                                      long = long_val,
                                      start_time = st,
                                      end_time = NULL)

wind_1h <- RClimacell::climacell_wind(api_key = api,
                                      timestep = '1h',
                                      lat = lat_val,
                                      long = long_val,
                                      start_time = st,
                                      end_time = NULL)

wind_1d <- RClimacell::climacell_wind(api_key = api,
                                      timestep = '1d',
                                      lat = lat_val,
                                      long = long_val,
                                      start_time = st,
                                      end_time = NULL)

# Celestial Dataset

celestial_1d <- RClimacell::climacell_celestial(api_key = api,
                                                  timestep = '1d',
                                                  lat = lat_val,
                                                  long = long_val,
                                                  start_time = st,
                                                  end_time = NULL)

# Climacell Core
core_1m <- RClimacell::climacell_core(api_key = api,
                                                timestep = '1m',
                                                lat = lat_val,
                                                long = long_val,
                                                start_time = st,
                                                end_time = NULL)

# Climacell Core
core_1d <- RClimacell::climacell_core(api_key = api,
                                           timestep = '1d',
                                           lat = lat_val,
                                           long = long_val,
                                           start_time = st,
                                           end_time = NULL)

# write datasets out internally
usethis::use_data(precip_1m, precip_1h, precip_1d, temperature_1m, temperature_1h, temperature_1d, wind_1m, wind_1h, wind_1d, celestial_1d, core_1m, core_1d, internal = T, overwrite = T)

