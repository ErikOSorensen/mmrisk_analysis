renv::restore()
# Load pipeline definitions
source("_targets.R")

# Optional: full reset (uncomment if needed)


# Parallel backend
library(future)
plan(multicore)
# Run pipeline
#tar_destroy(destroy="all")
tar_make_future(workers = 30, callr_function = NULL)
