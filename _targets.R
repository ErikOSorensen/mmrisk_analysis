library(targets)
library(stantargets)
library(here)


source(here::here("R","reading_data.R"), local=TRUE)
source(here::here("R","descriptives.R"), local=TRUE)
source(here::here("R","utility.R"), local=TRUE)
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
    stan_file,
    "plain.stan",
    format = "file"
  ),
  # DL NOW
  tar_target(
    dir_fit_dl_now,
    {
      out_dir <- file.path("stan_output", "fit_dl_now")
      dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
      out_dir
    }
  ),
  tar_target(
    fit_dl_now,
    {
      model <- cmdstanr::cmdstan_model(stan_file, cpp_options = list(stan_threads = TRUE))
      model$sample(
        data = dl_now,
        iter_warmup = 3000,
        iter_sampling = 3000,
        chains = 4,
        parallel_chains = 4,
        threads_per_chain = 1,
        output_dir = dir_fit_dl_now
      )
    }
  ),
  
  # DL SHORT
  tar_target(
    dir_fit_dl_short,
    {
      out_dir <- file.path("stan_output", "fit_dl_short")
      dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
      out_dir
    }
  ),
  tar_target(
    fit_dl_short,
    {
      model <- cmdstanr::cmdstan_model(stan_file, cpp_options = list(stan_threads = TRUE))
      model$sample(
        data = dl_short,
        iter_warmup = 3000,
        iter_sampling = 3000,
        chains = 4,
        parallel_chains = 4,
        threads_per_chain = 1,
        output_dir = dir_fit_dl_short
      )
    }
  ),
  
  # DL LONG
  tar_target(
    dir_fit_dl_long,
    {
      out_dir <- file.path("stan_output", "fit_dl_long")
      dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
      out_dir
    }
  ),
  tar_target(
    fit_dl_long,
    {
      model <- cmdstanr::cmdstan_model(stan_file, cpp_options = list(stan_threads = TRUE))
      model$sample(
        data = dl_long,
        iter_warmup = 3000,
        iter_sampling = 3000,
        chains = 4,
        parallel_chains = 4,
        threads_per_chain = 1,
        output_dir = dir_fit_dl_long
      )
    }
  ),
  
  # DL NEVER
  tar_target(
    dir_fit_dl_never,
    {
      out_dir <- file.path("stan_output", "fit_dl_never")
      dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
      out_dir
    }
  ),
  tar_target(
    fit_dl_never,
    {
      model <- cmdstanr::cmdstan_model(stan_file, cpp_options = list(stan_threads = TRUE))
      model$sample(
        data = dl_never,
        iter_warmup = 3000,
        iter_sampling = 3000,
        chains = 4,
        parallel_chains = 4,
        threads_per_chain = 1,
        output_dir = dir_fit_dl_never
      )
    }
  ),
  tar_target(fit_dl_now_summary, fit_dl_now$summary()),
  tar_target(fit_dl_short_summary, fit_dl_short$summary()),
  tar_target(fit_dl_long_summary, fit_dl_long$summary()),
  tar_target(fit_dl_never_summary, fit_dl_never$summary()),
  # Posterior draws (optional, but useful)
  tar_target(fit_dl_now_draws, fit_dl_now$draws(format = "df")),
  tar_target(fit_dl_short_draws, fit_dl_short$draws(format = "df")),
  tar_target(fit_dl_long_draws, fit_dl_long$draws(format = "df")),
  tar_target(fit_dl_never_draws, fit_dl_never$draws(format = "df"))
)
