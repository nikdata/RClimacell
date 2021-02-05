
<!-- README.md is generated from README.Rmd. Please edit that file -->

# RClimacell

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
[![License:
MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![GitHub
commit](https://img.shields.io/github/last-commit/nikdata/RClimacell)](https://github.com/nikdata/RClimacell/commit/main)
[![R-CMD-check](https://github.com/nikdata/RClimacell/workflows/R-CMD-check/badge.svg)](https://github.com/nikdata/RClimacell/actions)
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
                      end_time = Sys.time() + lubridate::days(7))
#> # A tibble: 8 x 5
#>   start_time          temp_c temp_feel_c dewpoint humidity
#>   <dttm>               <dbl>       <dbl>    <dbl>    <dbl>
#> 1 2021-02-05 12:00:00  -8.84       -18.0    -13.2     76  
#> 2 2021-02-06 12:00:00 -10.4        -16.7    -14.8     79.3
#> 3 2021-02-07 12:00:00 -13.9        -18.2    -17.9     76.4
#> 4 2021-02-08 12:00:00 -11.2        -15      -12.6     96.6
#> 5 2021-02-09 12:00:00 -15.0        -22.6    -17.6     96.9
#> 6 2021-02-10 12:00:00 -14.7        -20.2    -16.4     94.0
#> 7 2021-02-11 12:00:00 -13.2        -21.1    -13.6     96.2
#> 8 2021-02-12 12:00:00 -22.0        -32.9    -24.3     87.2
```

### Wind

``` r
library(RClimacell)
climacell_wind(api_key = Sys.getenv("CLIMACELL_API"),
                      lat = 41.878685,
                      long = -87.636011,
                      timestep = '1d',
                      start_time = Sys.time(),
                      end_time = Sys.time() + lubridate::days(7))
#> # A tibble: 8 x 4
#>   start_time          wind_speed wind_gust wind_direction
#>   <dttm>                   <dbl>     <dbl>          <dbl>
#> 1 2021-02-05 12:00:00       8.61     17.1            248.
#> 2 2021-02-06 12:00:00       7.01      9.83           274.
#> 3 2021-02-07 12:00:00       6.57      8.97           301.
#> 4 2021-02-08 12:00:00       5.56     11.5            263.
#> 5 2021-02-09 12:00:00       5.23     11.1            304 
#> 6 2021-02-10 12:00:00       4.47      8.44           317.
#> 7 2021-02-11 12:00:00       5.73     10.8            338.
#> 8 2021-02-12 12:00:00       5.74     10.9            333.
```

See the vignette for more information.
