library(targets)
# This is an example _targets.R file. Every
# {targets} pipeline needs one.
# Use tar_script() to create _targets.R and tar_edit()
# to open it again for editing.
# Then, run tar_make() to run the pipeline
# and tar_read(summary) to view the results.

# Define custom functions and other global objects.
# This is where you write source(\"R/functions.R\")
# if you keep your functions in external scripts.

source(here::here("R","reading_data.R"))

# Set target-specific options such as packages.
tar_option_set(packages = c("tidyverse","dataverse"))

Sys.setenv("DATAVERSE_SERVER" = "dataverse.harvard.edu")
DATA_DOI <- "10.7910/DVN/YCRFK1"

# End this file with a list of target objects.

writeBin_return_name <- function(obj, fname) {
  writeBin(obj, fname)
  fname
}

list(
  tar_target(answers_raw, 
             get_file_by_name("answers.tab", DATA_DOI) |> writeBin_return_name(here::here("data_raw","answers.csv")),
             format = "file"
  ),
  tar_target(decisions_raw,
             get_file_by_name("decisions.tab", DATA_DOI) |> writeBin_return_name(here::here("data_raw","decisions.csv")),
             format = "file"
  ),
  tar_target(players_raw, 
             get_file_by_name("players.tab", DATA_DOI) |> writeBin_return_name(here::here("data_raw","players.csv")),
             format = "file"
  ),
  tar_target(readme_data_raw,
             get_file_by_name("README.md", DATA_DOI ) |> writeBin_return_name(here::here("data_raw","README.md")),
             format = "file"
  ),
  tar_target(answers, read_answers(answers_raw)),
  tar_target(decisions, read_decisions(decisions_raw)),
  tar_target(players, read_players(players_raw))
)
