## Test environments
* local OS X install, R 4.0.3
* win-builder (devel and release)

## R CMD check results - local install

There were no ERRORs, WARNINGs, or NOTEs on local install

## R CMD check results - win-builder (devl & release)

There were no ERRORs or WARNINGs.

There were 2 NOTES:

* New submission
* Mis-spelled words: Climacell, Timeline

Climacell is the name of the company that provides the actual API. Timeline is part of their service name called Timeline Interface. Both words are not mis-spellings.

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
