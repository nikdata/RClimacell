# Resubmission

This is a resubmission. In this version, I have:

* Added single quotes around the term 'Climacell' in the DESCRIPTION as it refers to an organization & API name

* Added URL to 'Climacell' API in DESCRIPTION file.

* Changed URL for experimental badge used in README (corrected in earlier submission).

* Fixed spelling of 'timeline' to 'time line'


## Test environments
* local OS X install, R 4.0.3
* win-builder (devel and release)

## R CMD check results - local install

There were no ERRORs, WARNINGs, or NOTEs on local install

## R CMD check results - win-builder (devl & release)

There were no ERRORs or WARNINGs.

There was 1 NOTE:

* New submission

## COMMENTS FROM Uwe Ligges

> Thanks, we see:
> 
>    Found the following (possibly) invalid URLs:
>      URL: https://www.tidyverse.org/lifecycle/#experimental (moved to 
> https://lifecycle.r-lib.org/articles/stages.html)
>        From: README.md
>        Status: 200
>        Message: OK
> 
> Please change http --> https, add trailing slashes, or follow moved 
> content as appropriate.
> 
> Please fix and resubmit.
> 
> Best,
> Uwe Ligges

My Resolution: I replaced the URL above to https://lifecycle.r-lib.org/articles/figures/lifecycle-experimental.svg

## COMMENTS FROM Julia Haider

> Thanks,
> 
> Please always write package names, software names and API (application 
> programming interface) names in single quotes in title and description. 
> e.g: --> 'Climacell'
> 
> Please add a web reference for the API in the form <https:.....> to the 
> description of the DESCRIPTION file with no space after 'https:' and 
> angle brackets for auto-linking.
> 
> Please fix and resubmit.
> 
> Best,
> Julia Haider

My Resolution: I have added the appropriate single quotes around the term Climacell and added the URL to the Climacell API.
