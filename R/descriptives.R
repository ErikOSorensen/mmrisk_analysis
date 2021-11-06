big_histogram <- function(dframe, pframe, dies) {
  ds <-  dframe %>% full_join(dies, by = "dienumber") %>%
    left_join(pframe, by = "psid") %>% dplyr::select(-c(created_at, status))
  ds %>% group_by(treatment, dienumber, safe_amount) %>% 
    summarize(share = mean(choice_risk)) %>%
    arrange(treatment,dienumber,safe_amount) %>%
    mutate(safe_alternative = row_number(),
           die = dienumber + 1) %>%
    ggplot(aes(x=factor(safe_alternative), y=share)) + 
    geom_bar(stat="identity") + 
    facet_grid(treatment~die, scales="free_x") + 
    xlab("Safe alternative") + ylab("Share that chose the lottery") +
    theme_minimal()
}