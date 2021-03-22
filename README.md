
# RClimacell <a href='https://nikdata.github.io/RClimacell/'><img src='man/figures/rclimacell-hex.png' align="right" width="150" height="150" />

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/figures/lifecycle-experimental.svg)
[![License:
MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![GitHub
commit](https://img.shields.io/github/last-commit/nikdata/RClimacell)](https://github.com/nikdata/RClimacell/commit/main)
[![R-CMD-check](https://github.com/nikdata/RClimacell/workflows/R-CMD-check/badge.svg)](https://github.com/nikdata/RClimacell/actions)
[![CRAN
status](https://www.r-pkg.org/badges/version/RClimacell)](https://CRAN.R-project.org/package=RClimacell)
<!-- badges: end -->

The {RClimacell} package is an **unofficial** R package that enables
basic interaction with [Climacell’s](https://www.climacell.co) API using
the [Timeline
Interface](https://docs.climacell.co/reference/timeline-overview). The
functions within this package are tested against some of the [Core data
layers](https://docs.climacell.co/reference/data-layers-core).

Please note that using the functions within this package **require** a
valid API key.

More information about the Climacell API can be found on their
[docs](https://docs.climacell.co/reference/api-overview) page.

### Lubridate Issue

As of 24 Feb, there is a [known
issue](https://github.com/tidyverse/lubridate/issues/928) with using the
package {lubridate} and it seems to be affecting macOS users. The ‘fix’
has been to add the following line to the .Renviron file or the
.Rprofile (I applied the code into the .Renviron file and it worked):

``` r
TZDIR="/Library/Frameworks/R.framework/Resources/share/zoneinfo/"
```

{lubridate} version 1.7.10 fixes this issue and is available on CRAN.

## Installation

CRAN version can be installed as follows:

``` r
install.packages('RClimacell')
```

You can install the development version from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("nikdata/RClimacell")
```

## Usage

Not every variable in each of the functions will have a value. Missing
values are denoted by NA and indicate that the API did not return a
value for the specific date/time and function call.

### Temperature

``` r
library(RClimacell)
climacell_temperature(api_key = Sys.getenv("CLIMACELL_API"),
                      lat = 41.878685,
                      long = -87.636011,
                      timestep = '1d',
                      start_time = lubridate::now(),
                      end_time = lubridate::now() + lubridate::days(3))
#> # A tibble: 4 x 5
#>   start_time          temp_c temp_feel_c dewpoint humidity
#>   <dttm>               <dbl>       <dbl>    <dbl>    <dbl>
#> 1 2021-03-22 11:00:00  18.3        18.2      5.88     62.1
#> 2 2021-03-23 11:00:00  14.1        14.1     10.5      97.0
#> 3 2021-03-24 11:00:00  14.2        14.2     10.1      97.3
#> 4 2021-03-25 11:00:00   7.26        7.26     4.94     92.3
```

### Wind

``` r
library(RClimacell)
climacell_wind(api_key = Sys.getenv("CLIMACELL_API"),
               lat = 41.878685,
               long = -87.636011,
               timestep = '1d',
               start_time = lubridate::now(),
               end_time = lubridate::now() + lubridate::days(3))
#> # A tibble: 4 x 4
#>   start_time          wind_speed wind_gust wind_direction
#>   <dttm>                   <dbl>     <dbl>          <dbl>
#> 1 2021-03-22 11:00:00       6.46      9.12          190. 
#> 2 2021-03-23 11:00:00       9.77     13.9           143. 
#> 3 2021-03-24 11:00:00      10.7      15.4           225. 
#> 4 2021-03-25 11:00:00       6.77      9.31           95.1
```

### Precipitation

``` r
library(RClimacell)
df_precip <- climacell_precip(api_key = Sys.getenv("CLIMACELL_API"),
                 lat = 41.878685,
                 long = -87.636011,
                 timestep = '1h',
                 start_time = lubridate::now(),
                 end_time = lubridate::now() + lubridate::days(3))

dplyr::glimpse(df_precip)
#> Rows: 73
#> Columns: 14
#> $ start_time                <dttm> 2021-03-22 22:00:00, 2021-03-22 23:00:00, 2…
#> $ precipitation_intensity   <dbl> 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.00…
#> $ precipitation_probability <dbl> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,…
#> $ precipitation_type_code   <dbl> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,…
#> $ precipitation_type_desc   <chr> "Rain", "Rain", "Rain", "Rain", "Rain", "Rai…
#> $ visibility                <dbl> 10.00, 16.00, 16.00, 16.00, 16.00, 16.00, 16…
#> $ pressure_surface_level    <dbl> 997.45, 996.97, 997.25, 997.07, 997.85, 998.…
#> $ pressure_sea_level        <dbl> 1015.03, 1015.30, 1015.48, 1015.25, 1016.09,…
#> $ cloud_cover               <dbl> 21.43, 82.86, 100.00, 100.00, 100.00, 100.00…
#> $ cloud_base                <dbl> NA, 7.36, 1.03, 0.74, 0.57, 7.77, 6.67, 6.67…
#> $ cloud_ceiling             <dbl> NA, NA, 9.58, 9.19, 8.64, 7.64, 6.66, 6.53, …
#> $ solar_ghi                 <dbl> 247.85, 139.36, 0.00, 0.00, 0.00, 0.00, 0.00…
#> $ weather_code              <dbl> 1100, 1001, 1001, 1001, 1001, 1001, 1001, 10…
#> $ weather_desc              <chr> "Mostly Clear", "Cloudy", "Cloudy", "Cloudy"…
```

### Celestial (sunset time, sunrise time, and moon phase)

``` r
library(RClimacell)
df_celestial <- climacell_celestial(api_key = Sys.getenv("CLIMACELL_API"),
                 lat = 41.878685,
                 long = -87.636011,
                 timestep = '1d',
                 start_time = lubridate::now(),
                 end_time = lubridate::now() + lubridate::days(5))

dplyr::glimpse(df_celestial)
#> Rows: 6
#> Columns: 5
#> $ start_time             <dttm> 2021-03-22 11:00:00, 2021-03-23 11:00:00, 2021…
#> $ sunrise_time           <dttm> 2021-03-22 11:50:00, 2021-03-23 11:48:20, 2021…
#> $ sunset_time            <dttm> 2021-03-23 00:05:00, 2021-03-24 00:06:40, 2021…
#> $ moon_phase_code        <int> 2, 2, 2, 2, 3, 4
#> $ moon_phase_description <chr> "First Quarter", "First Quarter", "First Quarte…
```

### Climacell Core (all Core Layer data)

This function aims to retrieve all of the Core Layer data using the
Timeline Interface. All of the data are retrieved in a single API call.
Note that if the timestep is not ‘1d’, then the moon phase, sunrise
time, and sunset times will not be available

``` r
library(RClimacell)
df_core <- climacell_core(api_key = Sys.getenv("CLIMACELL_API"),
                 lat = 41.878685,
                 long = -87.636011,
                 timestep = '1m',
                 start_time = lubridate::now(),
                 end_time = lubridate::now() + lubridate::hours(3))
#> Moonphase, Sunrise Time, and Sunset Times are only available if timestep is '1d'.

dplyr::glimpse(df_core)
#> Rows: 181
#> Columns: 21
#> $ start_time                <dttm> 2021-03-22 22:00:00, 2021-03-22 22:01:00, 2…
#> $ temp_c                    <dbl> 16.11, 16.11, 16.11, 16.11, 16.11, 16.11, 16…
#> $ temp_feel_c               <dbl> 17.81, 17.82, 17.83, 17.83, 17.84, 17.85, 17…
#> $ weather_code              <dbl> 1100, 1100, 1100, 1100, 1100, 1100, 1100, 11…
#> $ weather_desc              <chr> "Mostly Clear", "Mostly Clear", "Mostly Clea…
#> $ dewpoint                  <dbl> 4.08, 4.08, 4.08, 4.08, 4.08, 4.08, 4.09, 4.…
#> $ humidity                  <dbl> 45.00, 45.00, 45.00, 45.00, 45.00, 45.00, 45…
#> $ wind_speed                <dbl> 0.89, 0.89, 0.89, 0.89, 0.89, 0.89, 0.89, 0.…
#> $ wind_direction            <dbl> 106, 106, 106, 106, 106, 106, 106, 106, 106,…
#> $ wind_gust                 <dbl> 1.78, 1.78, 1.78, 1.78, 1.78, 1.78, 1.79, 1.…
#> $ solar_ghi                 <dbl> 247.85, 246.04, 244.23, 242.42, 240.62, 238.…
#> $ precipitation_type_code   <dbl> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,…
#> $ precipitation_type_desc   <chr> "Rain", "Rain", "Rain", "Rain", "Rain", "Rai…
#> $ precipitation_probability <dbl> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,…
#> $ precipitation_intensity   <dbl> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,…
#> $ cloud_cover               <dbl> 21.43, 21.43, 21.43, 21.43, 21.43, 21.43, 21…
#> $ cloud_base                <dbl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, …
#> $ cloud_ceiling             <dbl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, …
#> $ visibility                <dbl> 10.00, 10.00, 10.00, 10.00, 10.00, 10.00, 10…
#> $ pressure_surface_level    <dbl> 997.45, 997.44, 997.43, 997.42, 997.41, 997.…
#> $ pressure_sea_level        <dbl> 1015.03, 1015.03, 1015.03, 1015.03, 1015.03,…
```

``` r
library(RClimacell)
df_core2 <- climacell_core(api_key = Sys.getenv("CLIMACELL_API"),
                 lat = 41.878685,
                 long = -87.636011,
                 timestep = '1d',
                 start_time = lubridate::now(),
                 end_time = lubridate::now() + lubridate::days(5))

dplyr::glimpse(df_core2)
#> Rows: 6
#> Columns: 25
#> $ start_time                <dttm> 2021-03-22 11:00:00, 2021-03-23 11:00:00, 2…
#> $ temp_c                    <dbl> 18.22, 14.07, 14.18, 7.26, 2.57, 3.00
#> $ temp_feel_c               <dbl> 18.22, 14.07, 14.18, 7.26, -0.81, -0.95
#> $ weather_code              <dbl> 1102, 4200, 4000, 5001, 5001, 5100
#> $ weather_desc              <chr> "Mostly Cloudy", "Light Rain", "Drizzle", "F…
#> $ dewpoint                  <dbl> 5.88, 10.49, 10.07, 4.94, -1.81, 2.25
#> $ humidity                  <dbl> 62.11, 96.98, 97.27, 92.32, 74.93, 90.36
#> $ wind_speed                <dbl> 6.46, 9.77, 10.72, 9.75, 7.94, 4.69
#> $ wind_direction            <dbl> 187.73, 142.57, 224.78, 61.08, 148.06, 98.70
#> $ wind_gust                 <dbl> 9.12, 13.92, 15.36, 12.24, 9.84, 5.95
#> $ solar_ghi                 <dbl> 513.56, 540.69, 552.39, 557.51, 651.40, 137.…
#> $ precipitation_type_code   <dbl> 1, 1, 1, 2, 2, 2
#> $ precipitation_type_desc   <chr> "Rain", "Rain", "Rain", "Snow", "Snow", "Sno…
#> $ precipitation_probability <dbl> 0, 75, 25, 55, 20, 30
#> $ precipitation_intensity   <dbl> 0.0000, 2.7397, 0.3605, 0.4792, 0.0222, 0.57…
#> $ cloud_cover               <dbl> 100, 100, 100, 100, 100, 100
#> $ cloud_base                <dbl> 7.77, 2.68, 5.70, 5.86, 1.09, 2.18
#> $ cloud_ceiling             <dbl> 9.58, 8.31, 7.31, 8.26, 1.26, 3.35
#> $ visibility                <dbl> 16.00, 16.00, 16.00, 24.14, 24.14, 24.14
#> $ pressure_surface_level    <dbl> 999.40, 996.42, 990.88, 992.93, 1001.49, 999…
#> $ pressure_sea_level        <dbl> 1014.74, 1003.36, 1003.40, 1011.24, 1015.15,…
#> $ sunrise_time              <dttm> 2021-03-22 11:50:00, 2021-03-23 11:48:20, 20…
#> $ sunset_time               <dttm> 2021-03-23 00:05:00, 2021-03-24 00:06:40, 20…
#> $ moon_phase_code           <dbl> 2, 2, 2, 2, 3, 4
#> $ moon_phase_description    <chr> "First Quarter", "First Quarter", "First Qua…
```

See the [vignette](https://nikdata.github.io/RClimacell/) for more
information.
