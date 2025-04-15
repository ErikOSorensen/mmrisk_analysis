library(targets)
library(stantargets)
library(future)
library(future.callr)
plan(multicore, workers = 32)  # or up to 8–12 if you want


source(here::here("R","reading_data.R"), local=TRUE)
source(here::here("R","descriptives.R"), local=TRUE)
source(here::here("R","utility.R"), local=TRUE)
options(mc.cores = parallel::detectCores())
options(warn=-1, message =-1)
# Set target-specific options such as packages.
tar_option_set(packages = c("tidyverse","dataverse","here", "rstan"))

DATAVERSE_SERVER = "dataverse.harvard.edu"
DATA_DOI <- "10.7910/DVN/YCRFK1"

# End this file with a list of target objects.

list(
  tar_target(
    answers_file,
    dataverse::get_file_by_id(5373857, server = DATAVERSE_SERVER) |> writeBin_return_name(here::here("data_raw","answers.csv")),
    format = "file"
  ),
  tar_target(
    answers,
    readr::read_csv(answers_file)
  ),
  tar_target(
    decisions_file,
    dataverse::get_file_by_id(5373859, server = DATAVERSE_SERVER) |> writeBin_return_name(here::here("data_raw","decisions.csv")),
    format = "file"
  ),
  tar_target(
    decisions,
    readr::read_csv(decisions_file)
  ),
  tar_target(
    players_file,
    dataverse::get_file_by_id(5373858, server = DATAVERSE_SERVER) |> writeBin_return_name(here::here("data_raw","players.csv")),
    format = "file"
  ),
  tar_target(
    players,
    readr::read_csv(players_file)
  ),
  tar_target(players_complete, players %>% dplyr::filter(status %in% c(50,110))),
  tar_target(answers_complete, players_complete %>% dplyr::select(psid) %>% left_join(answers)),
  tar_target(decisions_complete, players_complete %>% dplyr::select(psid) %>% left_join(decisions)),
  tar_target(big_histogram_gg, big_histogram(decisions_complete, players_complete, dies)),
  tar_target(big_histogram_pdf, 
             save_plot_and_return_path(big_histogram_gg,
                                       here::here("graphs","big_histogram.pdf"),
                                       width = 24,
                                       height = 16),
             format = "file"),
  tar_target(dl_now, preparing_estimation_data(decisions_complete, players_complete, dies, "now")),
  tar_target(dl_short, preparing_estimation_data(decisions_complete, players_complete, dies, "short")),
  tar_target(dl_long, preparing_estimation_data(decisions_complete, players_complete, dies, "long")),
  tar_target(dl_never, preparing_estimation_data(decisions_complete, players_complete, dies, "never")),
  tar_target(
    stan_model_plain,
    cmdstanr::cmdstan_model("plain.stan", cpp_options = list(stan_threads = TRUE))
  ),
  tar_target(
    fit_dl_now,
    stan_model_plain$sample(
      data = dl_now,
      iter_warmup = 3000,
      iter_sampling = 3000,
      chains = 4,
      parallel_chains = 4,
      threads_per_chain = 1
    )
  ),
  tar_target(
    fit_dl_short,
    stan_model_plain$sample(
      data = dl_short,
      iter_warmup = 3000,
      iter_sampling = 3000,
      chains = 4,
      parallel_chains = 4,
      threads_per_chain = 1
    )
  ),
  tar_target(
    fit_dl_long,
    stan_model_plain$sample(
      data = dl_long,
      iter_warmup = 3000,
      iter_sampling = 3000,
      chains = 4,
      parallel_chains = 4,
      threads_per_chain = 1
    )
  ),
  tar_target(
    fit_dl_never,
    stan_model_plain$sample(
      data = dl_never,
      iter_warmup = 3000,
      iter_sampling = 3000,
      chains = 4,
      parallel_chains = 4,
      threads_per_chain = 1
    )
  )
)
  