
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

### Temperature

``` r
library(RClimacell)
climacell_temperature(api_key = Sys.getenv("CLIMACELL_API"),
                      lat = 41.878685,
                      long = -87.636011,
                      timestep = '1d',
                      start_time = Sys.time(),
                      end_time = Sys.time() + lubridate::days(3))
#> # A tibble: 4 x 5
#>   start_time          temp_c temp_feel_c dewpoint humidity
#>   <dttm>               <dbl>       <dbl>    <dbl>    <dbl>
#> 1 2021-02-23 12:00:00   8.89        6.13     3.26     78.0
#> 2 2021-02-24 12:00:00   4.45        4.45     1.98     93.8
#> 3 2021-02-25 12:00:00   2.49       -1.63    -2.25     94.0
#> 4 2021-02-26 12:00:00   3.21        0.04    -1.11     96.2
```

### Wind

``` r
library(RClimacell)
climacell_wind(api_key = Sys.getenv("CLIMACELL_API"),
               lat = 41.878685,
               long = -87.636011,
               timestep = '1d',
               start_time = Sys.time(),
               end_time = Sys.time() + lubridate::days(3))
#> # A tibble: 4 x 4
#>   start_time          wind_speed wind_gust wind_direction
#>   <dttm>                   <dbl>     <dbl>          <dbl>
#> 1 2021-02-23 12:00:00       9.69     14.0            230.
#> 2 2021-02-24 12:00:00       8.82     12.0            287.
#> 3 2021-02-25 12:00:00       5.62      7.21           247.
#> 4 2021-02-26 12:00:00       4.13      6.07           171.
```

## Precipitation

``` r
library(RClimacell)
df_precip <- climacell_precip(api_key = Sys.getenv("CLIMACELL_API"),
                 lat = 41.878685,
                 long = -87.636011,
                 timestep = '1h',
                 start_time = Sys.time(),
                 end_time = Sys.time() + lubridate::days(3))

dplyr::glimpse(df_precip)
#> Rows: 100
#> Columns: 13
#> $ start_time                <dttm> 2021-02-23 20:27:00, 2021-02-23 21:27:00, …
#> $ precipitation_intensity   <dbl> 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0…
#> $ precipitation_probability <dbl> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0…
#> $ precipitation_type_code   <dbl> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1…
#> $ precipitation_type_desc   <chr> "Rain", "Rain", "Rain", "Rain", "Rain", "Ra…
#> $ visibility                <dbl> 11.60, 16.00, 16.00, 15.91, 15.89, 16.00, 1…
#> $ pressure_surface_level    <dbl> 991.49, 991.74, 992.15, 991.91, 992.11, 991…
#> $ pressure_sea_level        <dbl> 1010.95, 1010.30, 1010.77, 1010.52, 1010.80…
#> $ cloud_cover               <dbl> 26.32, 82.85, 62.92, 35.64, 5.57, 49.73, 10…
#> $ cloud_base                <dbl> NA, 4.89, 3.80, 4.31, NA, NA, 0.44, 1.41, 8…
#> $ cloud_ceiling             <dbl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, 7.2…
#> $ weather_code              <dbl> 1100, 1001, 1102, 1100, 1000, 1101, 1001, 1…
#> $ weather_desc              <chr> "Mostly Clear", "Cloudy", "Mostly Cloudy", …
```

See the [vignette](https://nikdata.github.io/RClimacell/) for more
information.
