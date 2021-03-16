
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
functions within this package are tested against some of the [CORE data
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
#> 1 2021-03-16 11:00:00   2.22       -0.38     0.96     96  
#> 2 2021-03-17 11:00:00   3.27       -1.34     1.67     93.3
#> 3 2021-03-18 11:00:00   4.55        4.55     1.64     90.4
#> 4 2021-03-19 11:00:00   1.55       -3.44    -4.88     64.4
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
#> 1 2021-03-16 11:00:00       3.55      4.88           47.8
#> 2 2021-03-17 11:00:00      12.7      18.4            40.9
#> 3 2021-03-18 11:00:00      13.9      20.4            28.7
#> 4 2021-03-19 11:00:00       9.35     13.7            34.7
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
#> $ start_time                <dttm> 2021-03-16 21:19:00, 2021-03-16 22:19:00, 2…
#> $ precipitation_intensity   <dbl> 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.…
#> $ precipitation_probability <dbl> 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,…
#> $ precipitation_type_code   <dbl> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,…
#> $ precipitation_type_desc   <chr> "Rain", "Rain", "Rain", "Rain", "Rain", "Rai…
#> $ visibility                <dbl> 10.00, 14.03, 15.29, 15.89, 15.74, 15.49, 15…
#> $ pressure_surface_level    <dbl> 999.07, 999.39, 999.31, 999.93, 1001.00, 100…
#> $ pressure_sea_level        <dbl> 1019.01, 1017.95, 1017.84, 1018.43, 1019.53,…
#> $ cloud_cover               <dbl> 0.00, 100.00, 100.00, 100.00, 100.00, 100.00…
#> $ cloud_base                <dbl> NA, 0.28, 0.32, 0.38, 0.48, 0.49, 0.49, 0.36…
#> $ cloud_ceiling             <dbl> NA, 0.33, 0.37, 0.44, 0.45, 0.45, 0.45, 0.45…
#> $ solar_ghi                 <dbl> 415.38, 30.96, 15.12, 0.00, 0.00, 0.00, 0.00…
#> $ weather_code              <dbl> 1000, 1001, 1001, 1001, 1001, 1001, 1001, 10…
#> $ weather_desc              <chr> "Clear", "Cloudy", "Cloudy", "Cloudy", "Clou…
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
#> $ start_time             <dttm> 2021-03-16 11:00:00, 2021-03-17 11:00:00, 2021…
#> $ sunrise_time           <dttm> 2021-03-16 12:00:00, 2021-03-17 11:58:20, 2021…
#> $ sunset_time            <dttm> 2021-03-16 23:58:20, 2021-03-18 00:00:00, 2021…
#> $ moon_phase_code        <int> 1, 1, 1, 2, 2, 2
#> $ moon_phase_description <chr> "Waxing Crescent", "Waxing Crescent", "Waxing C…
```

See the [vignette](https://nikdata.github.io/RClimacell/) for more
information.
