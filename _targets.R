library(targets)
library(tarchetypes)
library(stantargets)
library(here)
library(bootstrap)
library(gt)
library(visNetwork)
source(here::here("R","reading_data.R"), local=TRUE)
source(here::here("R","descriptives.R"), local=TRUE)
source(here::here("R","utility.R"), local=TRUE)
# Set target-specific options such as packages.
tar_option_set(packages = c("tidyverse","dataverse","here", "rstan", 
                            "fastDummies", "bootstrap", "gt"))

DATAVERSE_SERVER = "dataverse.harvard.edu"

tar_option_set(seed = 912324641)

# End this file with a list of target objects.

list(
  tar_target(
    answers_file,
    dataverse::get_file_by_id(5373857, server = DATAVERSE_SERVER) |> writeBin_return_name(here::here("data_raw","answers.csv")),
    format = "file"
  ),
  tar_target(
    answers,
    read_answers(answers_file)
  ),
  tar_target(
    decisions_file,
    dataverse::get_file_by_id(5373859, server = DATAVERSE_SERVER) |> writeBin_return_name(here::here("data_raw","decisions.csv")),
    format = "file"
  ),
  tar_target(
    decisions,
    read_decisions(decisions_file)
  ),
  tar_target(
    players_file,
    dataverse::get_file_by_id(5373858, server = DATAVERSE_SERVER) |> writeBin_return_name(here::here("data_raw","players.csv")),
    format = "file"
  ),
  tar_target(ssb, read_ssb("20190714-Table10211.csv")),
  tar_target(
    players,
    read_players(players_file)
  ),
  tar_target(players_complete, players %>% dplyr::filter(status %in% c(50,110))),
  tar_target(answers_complete, players_complete %>% dplyr::select(psid) %>% left_join(answers)),
  tar_target(decisions_complete, players_complete %>% dplyr::select(psid) %>% left_join(decisions)),
  tar_target(answersd, answersdf(answers_complete)),
  tar_target(average_risk_taking_on_background,
             average_risk_taking_on_background_list(decisions_complete, players_complete, answersd)),
  tar_target(big_histogram_gg, big_histogram(decisions_complete, players_complete, dies)),
  tar_target(representativeness_of_sample, representativeness_of_sample_list(answersd, ssb)),
  tar_target(descriptives_on_sample, descriptives_on_sample_df(answersd)),
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
        iter_warmup = 6000,
        iter_sampling = 6000,
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
        iter_warmup = 6000,
        iter_sampling = 6000,
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
        iter_warmup = 6000,
        iter_sampling = 6000,
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
        iter_warmup = 6000,
        iter_sampling = 6000,
        chains = 4,
        parallel_chains = 4,
        threads_per_chain = 1,
        output_dir = dir_fit_dl_never
      )
    }
  ),
  # Posterior draws (optional, but useful)
  tar_target(fit_dl_now_draws, fit_dl_now$draws(format = "df")),
  tar_target(fit_dl_short_draws, fit_dl_short$draws(format = "df")),
  tar_target(fit_dl_long_draws, fit_dl_long$draws(format = "df")),
  tar_target(fit_dl_never_draws, fit_dl_never$draws(format = "df")),
  tar_target(fit_dl_now_sum, fit_dl_now$summary(variables = hyper_params_name)),
  tar_target(fit_dl_short_sum, fit_dl_short$summary(variables = hyper_params_name)),
  tar_target(fit_dl_long_sum, fit_dl_long$summary(variables = hyper_params_name)),
  tar_target(fit_dl_never_sum, fit_dl_never$summary(variables = hyper_params_name)),
  tar_render(Descriptives_statistics, "Descriptive_statistics.Rmd"),
  tar_render(Results, "Results.Rmd"),
  tar_render(Traceplots, "Traceplots.Rmd"),
  tar_render(Chainsummaries, "Chainsummaries.Rmd"),
  tar_target(hyper_params_name, c("alpha_mu","alpha_sigma",
                                                "beta_mu","beta_sigma",
                                                "lambda_mu","lambda_sigma",
                                                "rho_mu","rho_sigma")),
  tar_target(prior_densities, prior_densities_df(hyper_params_name)),
  tar_target(posterior_draws, hyper_params_df(hyper_params_name, 
                                              fit_dl_now_draws,
                                              fit_dl_short_draws,
                                              fit_dl_long_draws,
                                              fit_dl_never_draws))
)
