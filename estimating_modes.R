library("tidyverse")
library("modeest")
all_params <- readRDS("data/all_params.rds")

params <- all_params %>% pivot_longer(cols=c("alpha","beta","rho","lambda"), 
                                      names_to = "parameter", 
                                      values_to = "y")
rm(all_params)

mode_params <- params %>% 
  group_by(treatment, id, parameter) %>%
  summarize(param_mode = mlv(y, method="meanshift"))
saveRDS(mode_params, file="data/all_modes.rds")