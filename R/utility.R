writeBin_return_name <- function(obj, fname) {
  if (!file.exists(fname) || !identical(readBin(fname, what = "raw", n = length(obj)), obj)) {
    writeBin(obj, fname)
  }
  fname
}