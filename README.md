
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

The {RClimacell} package is an unofficial R package that enables basic
interaction with [Climacell’s](https://www.climacell.co) API. The
functions within this package are tested against the [CORE data
layers](https://docs.climacell.co/reference/data-layers-core). Using the
functions within this package require a valid API key.

**WIP**

This package is still under development. Please use with caution.
Functions have not been fully tested.

**THIS IS NOT AN OFFICIAL CLIMACELL PACKAGE!**

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
#> # A tibble: 8 x 6
#>   start_time          temp_c temp_feel_c dewpoint humidity humidty
#>   <dttm>               <dbl>       <dbl>    <dbl> <chr>      <dbl>
#> 1 2021-02-04 12:00:00   0.98       -4.75     0.31 95.94       95.9
#> 2 2021-02-05 12:00:00 -10.3       -20.4    -14.1  78.55       78.6
#> 3 2021-02-06 12:00:00 -10.0       -16.9    -14.6  82.76       82.8
#> 4 2021-02-07 12:00:00 -13.2       -17.2    -20.1  76.37       76.4
#> 5 2021-02-08 12:00:00 -13.2       -13.6    -13.5  96.86       96.9
#> 6 2021-02-09 12:00:00 -15.4       -21.7    -17.8  91.6        91.6
#> 7 2021-02-10 12:00:00 -14.1       -21.2    -14.8  96.74       96.7
#> 8 2021-02-11 12:00:00 -18.9       -28.4    -21.4  92.36       92.4
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
#> 1 2021-02-04 12:00:00      11.8      21.5            177.
#> 2 2021-02-05 12:00:00      11.8      21.5            262.
#> 3 2021-02-06 12:00:00       6.68      9.15           268.
#> 4 2021-02-07 12:00:00       6.35      8.65           290.
#> 5 2021-02-08 12:00:00       4.82      9.93           264.
#> 6 2021-02-09 12:00:00       4.82      9.95           315.
#> 7 2021-02-10 12:00:00       3.9       9.13           313.
#> 8 2021-02-11 12:00:00       5.68      8.24           294.
```

## CAUTION

-   The free API has a limit of 1000 calls per day for CORE data layers
-   The free API has a limit of 100 calls per day for PREMIUM data
    layers (out of scope for this package at this time)

## Limitations

-   Does not allow for PUT requests
-   I don’t have the funds to get a more premium API account enabling
    for richer weather data. Therefore, I am limiting this package (for
    now) to the CORE data layers and focusing on GET.
-   PUT is only needed if you want to modify the settings on your
    Climacell API account from what I can gather.
