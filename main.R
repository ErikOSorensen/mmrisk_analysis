renv::restore()
# Load pipeline definitions
source("_targets.R")

# Parallel backend
library(future)
plan("multisession")
# Run pipeline
#tar_destroy(destroy="all")
tar_make_future(c("fit_dl_now", "fit_dl_short", "fit_dl_long","fit_dl_never"), workers = 32, callr_function = NULL)
tar_make()

