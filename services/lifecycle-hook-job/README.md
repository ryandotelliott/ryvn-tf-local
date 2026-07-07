# lifecycle-hook-job

Minimal lifecycle hook job image for Ryvn local fixtures.

The container prints the `SUCCESS` environment variable and exits with status 0
when it is `true`, `TRUE`, `1`, `yes`, or `YES`. Any other value exits with
status 1.
