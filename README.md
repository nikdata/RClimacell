
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
#> 1 2021-02-26 12:00:00   4.58        4.25     2.13     88.0
#> 2 2021-02-27 12:00:00   8.79        8.79     2.33     96.2
#> 3 2021-02-28 12:00:00   8.87        8.87     6.16     97.8
#> 4 2021-03-01 12:00:00   0.82       -5.74    -4.97     86.2
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
#> 1 2021-02-26 12:00:00       6.53      9.23           185.
#> 2 2021-02-27 12:00:00       6.53      9.23           179.
#> 3 2021-02-28 12:00:00       8.55     11.6            260.
#> 4 2021-03-01 12:00:00       9.31     13.2            281.
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
#> Columns: 13
#> $ start_time                <dttm> 2021-02-26 19:33:00, 2021-02-26 20:33:00, …
#> $ precipitation_intensity   <dbl> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0…
#> $ precipitation_probability <dbl> 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 5.5, 12.…
#> $ precipitation_type_code   <dbl> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1…
#> $ precipitation_type_desc   <chr> "Rain", "Rain", "Rain", "Rain", "Rain", "Ra…
#> $ visibility                <dbl> 10.00, 16.00, 16.00, 16.00, 16.00, 16.00, 1…
#> $ pressure_surface_level    <dbl> 999.40, 998.43, 997.61, 997.11, 996.58, 995…
#> $ pressure_sea_level        <dbl> 1020.59, 1016.96, 1016.25, 1015.72, 1015.11…
#> $ cloud_cover               <dbl> 0.00, 2.65, 55.75, 100.00, 100.00, 100.00, …
#> $ cloud_base                <dbl> NA, NA, 4.14, 3.58, 3.07, 2.68, 2.59, 1.88,…
#> $ cloud_ceiling             <dbl> NA, NA, NA, NA, 2.89, 2.89, 2.46, 1.85, 2.0…
#> $ weather_code              <dbl> 1000, 1000, 1101, 1001, 1001, 1001, 1001, 1…
#> $ weather_desc              <chr> "Clear", "Clear", "Partly Cloudy", "Cloudy"…
```

See the [vignette](https://nikdata.github.io/RClimacell/) for more
information.
