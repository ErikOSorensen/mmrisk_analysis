library(tidyverse)

mode_params <- readRDS("data/all_modes.rds") %>%
  mutate(treatmentf = factor(treatment, levels=c("now","short","long","never")),
         parameterf = factor(parameter, levels=c("alpha","beta","rho","lambda")))

mode_params %>% filter(parameter %in% c("rho","lambda")) %>% 
  ggplot(aes(x=param_mode, 
             y=(..count..)/tapply(..count..,..PANEL..,sum)[..PANEL..])) + 
  geom_histogram() + 
  theme_minimal() + 
  labs(x = "Mode at the individual level",
       y = "Fraction") +
  facet_grid(treatmentf ~ parameterf, scales="free_x")
ggsave("graphs/rho_lambda.pdf", width = 16, height = 10, units = "cm")

mode_params %>% filter(parameter %in% c("alpha","beta")) %>% 
  ggplot(aes(x=param_mode, 
             y=(..count..)/tapply(..count..,..PANEL..,sum)[..PANEL..])) + 
  geom_histogram() + 
  theme_minimal() + 
  labs(x = "Mode at the individual level",
       y = "Fraction") +
  facet_grid(treatmentf ~ parameterf, scales="free_x")
ggsave("graphs/alpha_beta.pdf", width = 16, height = 10, units = "cm")

mode_params %>% group_by(parameterf, treatmentf) %>%
  summarize(meanparam = mean(param_mode))

