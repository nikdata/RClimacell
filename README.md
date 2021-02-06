
# RClimacell <a href='https://nikdata.github.io/RClimacell/'><img src='man/figures/rclimacell-hex.png' align="right" width="150" height="150" />

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/figures/lifecycle-experimental.svg)
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
                      end_time = Sys.time() + lubridate::days(3))
#> # A tibble: 4 x 5
#>   start_time          temp_c temp_feel_c dewpoint humidity
#>   <dttm>               <dbl>       <dbl>    <dbl>    <dbl>
#> 1 2021-02-06 12:00:00  -8.7       -15.3    -12.0      84.4
#> 2 2021-02-07 12:00:00 -14.6       -20.9    -19.4      77.6
#> 3 2021-02-08 12:00:00  -6.81       -9.92    -8.67     88.2
#> 4 2021-02-09 12:00:00  -7.48      -15.3     -9.09     88.8
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
#> 1 2021-02-06 12:00:00       7.08     10.8            279.
#> 2 2021-02-07 12:00:00       6.45      8.92           287.
#> 3 2021-02-08 12:00:00       6.51      8.92           172.
#> 4 2021-02-09 12:00:00       9.24     12.5            335.
```

## Precipitation

``` r
library(RClimacell)
climacell_precip(api_key = Sys.getenv("CLIMACELL_API"),
                 lat = 41.878685,
                 long = -87.636011,
                 timestep = '1d',
                 start_time = Sys.time(),
                 end_time = Sys.time() + lubridate::days(3))
#> # A tibble: 5 x 13
#>   start_time          precipitation_i… precipitation_p… precipitation_t…
#>   <dttm>                         <dbl>            <dbl>            <dbl>
#> 1 2021-02-06 12:00:00           1.1                  90                2
#> 2 2021-02-07 12:00:00           0.372                20                2
#> 3 2021-02-08 12:00:00           0.197                25                2
#> 4 2021-02-09 12:00:00           0                     0                2
#> 5 2021-02-10 12:00:00           0.0663                0                2
#> # … with 9 more variables: precipitation_type_desc <chr>, visibility <dbl>,
#> #   pressure_surface_level <dbl>, pressure_sea_level <dbl>, cloud_cover <dbl>,
#> #   cloud_base <dbl>, cloud_ceiling <dbl>, weather_code <dbl>,
#> #   weather_desc <chr>
```

See the [vignette](https://nikdata.github.io/RClimacell/) for more
information.
