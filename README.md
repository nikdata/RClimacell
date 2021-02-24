
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

A fix is on the way for {lubridate}, but, as of 24 Feb, was not on CRAN.

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
#> 1 2021-02-24 12:00:00   7           7        4.01     95.0
#> 2 2021-02-25 12:00:00   2.36       -1.8     -1.97     93.5
#> 3 2021-02-26 12:00:00   3.14       -0.68     0.97     92.3
#> 4 2021-02-27 12:00:00   3.06       -1.39     1.36     92.9
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
#> 1 2021-02-24 12:00:00       5        12.1            325.
#> 2 2021-02-25 12:00:00       5.07      6.5            241.
#> 3 2021-02-26 12:00:00       9.25     12.3            171.
#> 4 2021-02-27 12:00:00       6.95      9.15           240.
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
#> Rows: 73
#> Columns: 13
#> $ start_time                <dttm> 2021-02-24 15:49:00, 2021-02-24 16:49:00, …
#> $ precipitation_intensity   <dbl> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0…
#> $ precipitation_probability <dbl> 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 4.1, 5.0, 0.9…
#> $ precipitation_type_code   <dbl> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1…
#> $ precipitation_type_desc   <chr> "Rain", "Rain", "Rain", "Rain", "Rain", "Ra…
#> $ visibility                <dbl> 10.00, 16.00, 16.00, 16.00, 16.00, 16.00, 1…
#> $ pressure_surface_level    <dbl> 987.67, 989.15, 990.92, 993.04, 993.00, 994…
#> $ pressure_sea_level        <dbl> 1008.48, 1008.34, 1009.70, 1011.81, 1011.82…
#> $ cloud_cover               <dbl> 0.00, 0.00, 4.25, 81.08, 90.11, 76.76, 95.2…
#> $ cloud_base                <dbl> NA, NA, NA, 0.65, 0.84, 0.85, 0.65, 1.19, 0…
#> $ cloud_ceiling             <dbl> NA, NA, NA, 0.62, 1.00, NA, 0.61, NA, NA, N…
#> $ weather_code              <dbl> 1000, 1000, 1000, 1001, 1001, 1001, 1001, 1…
#> $ weather_desc              <chr> "Clear", "Clear", "Clear", "Cloudy", "Cloud…
```

See the [vignette](https://nikdata.github.io/RClimacell/) for more
information.
