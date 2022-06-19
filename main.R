# This file will read the target specifications in _targets.R and 
# generate all displays for the paper and the appendix -- and all
# referenced numbers in the "vignette" directory. 
source("_targets.R")


# If you have local cached objects (from running tar_make() previously),
# uncomment the following line to delete the cache and calculate everything from 
# scratch
# tar_destroy()


# Set the number of workers to a number not larger than the number of threads
# your computer can comfortably run in parallel.
tar_make_future(workers = 30)