save_plot_and_return_path <- function(obj,
                                      fname,
                                      width = 16,
                                      height = 10) {
  ggsave(fname,
         plot = obj,
         width = width,
         height = height,
         units = "cm")
  fname
}


writeBin_return_name <- function(obj, fname) {
  if (!file.exists(fname) || !identical(readBin(fname, what = "raw", n = length(obj)), obj)) {
    writeBin(obj, fname)
  }
  fname
}