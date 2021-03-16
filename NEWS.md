# RClimacell (development version)

* added new function `climacell_celestial()` that retrieves the sunrise and sunset times along with the moon phase
* removed the need to use the package {parsedate} and removed {parsedate} from dependency list
* input dates no longer have to be in ISO8601 format (recommended to use the {lubridate} package or `Sys.time()` when entering date-time stamps)
* drastically improved error handling for dates/times provided by user
* updated vignettes

# RClimacell 0.1.3

* fixed a bug where the user user provided API key was not used

# RClimacell 0.1.2

* Climacell API does not return results unless non-zero values are present for pressure; added extra steps to account for this.

# RClimacell 0.1.1

* fixed a bug where the `climacell_precip()` function would not return results for the correct lat/long and `timestep` argument.
* fixed a coding error where the start and end times were not parameterized prior to calling the API.
* improved the way cloud cover results are handled when using the `climacell_precip()` function.

# RClimacell 0.1.0

* Initial release
* Added a `NEWS.md` file to track changes to the package.

