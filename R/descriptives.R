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

average_risk_taking_on_background_list <- function(decisions_complete, players_complete, answersd) {
  avgchoices <- decisions_complete |> 
    group_by(psid) |>
    summarize(avgchoice = mean(choice_risk)) |> 
    left_join(answersd) |>
    left_join(players_complete) |>
    mutate( edu = fct_relevel(as_factor(edu),"Middle school"),
            affect = fct_relevel(as_factor(affect), "none of the above"),
            gender = fct_relevel(as_factor(sex), "Male"))
  r1 <- avgchoices %>% lm(avgchoice ~ treatment, data = .)
  r2 <- avgchoices %>% lm(avgchoice ~ treatment + age + gender + parent + 
                            edu + risk_own + risk_others + good_works +affect, data=.)
  r3 <- avgchoices %>% filter(treatment=="now") %>% 
    lm(avgchoice ~  age + gender + parent + 
         edu + risk_own + risk_others + good_works +affect, data=.)
  r4 <- avgchoices %>% filter(treatment=="short") %>% 
    lm(avgchoice ~ age + gender + parent + 
         edu + risk_own + risk_others + good_works +affect, data=.)
  r5 <- avgchoices %>% filter(treatment=="long") %>% 
    lm(avgchoice ~ age + gender + parent + 
         edu + risk_own + risk_others + good_works +affect, data=.)
  r6 <- avgchoices %>% filter(treatment=="never") %>% 
    lm(avgchoice ~ age + gender + parent + 
         edu + risk_own + risk_others + good_works +affect, data=.)
  list(r1,r2,r3,r4,r5,r6)
}