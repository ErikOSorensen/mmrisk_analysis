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


representativeness_of_sample_list <- function(answersd, ssb) {
  pyramid_ssb <- ssb |> group_by(gender, ageg) |> 
    summarize(n = sum(`Personer 2019`)) |> mutate(ntot = sum(n),
                                                  share = n/ntot, 
                                                  group = "Population") |>
    select(ageg,group,gender,share) |>
    spread(key=gender, value=share) |> 
    rename(pMale = Male,
           pFemale=Female) |> select(c(ageg,pMale,pFemale)) 
  
  total_ssb <- ssb |> group_by(gender) |> 
    summarize(n = sum(`Personer 2019`)) |> mutate(ntot = sum(n),
                                                  share = n/ntot,
                                                  ageg = "Total") |>
    select(c(ageg,gender,share)) |>
    pivot_wider(id_cols=ageg, values_from = share, names_from = gender, names_prefix = "p")
  
  pyramid_norstat <- answersd |> select(age,gender) |>
    mutate(ageg = cut(age, breaks=c(18,20,30,40,50,60,70,80,110), 
                      right=FALSE, ordered_result = TRUE)) |>
    filter(!is.na(gender)) |>
    filter(!is.na(age)) |>
    group_by(gender, ageg) |> 
    summarize(n = n()) |> mutate(ntot = sum(n),
                                 share = n/ntot) |>
    select(ageg,gender,share) |>
    spread(key=gender, value=share) |> 
    rename(nMale = `1`,
           nFemale = `2`) 
  
  total_norstat <- answersd |> group_by(gender) |> 
    summarize(n = n()) |>
    filter(!is.na(gender)) |>
    mutate(share = n/sum(n),
           ageg = "Total") |> 
    dplyr::select(-n) |>
    select(c(ageg,gender,share)) |>
    pivot_wider(id_cols=ageg, values_from = share, names_from = gender, names_prefix = "n") |>
    rename(nMale = n1, nFemale=n2) 
  
  panelA <- pyramid_ssb |> left_join(pyramid_norstat) |>
    dplyr::select(c(ageg, nMale, pMale, nFemale, pFemale)) |>
    gt::gt() |> fmt_number(decimals=3) |>
    tab_spanner(label="Male", columns=2:3) |>
    tab_spanner(label="Female", columns=4:5) |>
    cols_label(ageg="",nMale="Sample",pMale="Population",nFemale="Sample",pFemale="Population")
  
  panelB <- total_ssb |> left_join(total_norstat) |>
    dplyr::select(c(ageg, nMale, pMale, nFemale, pFemale)) |>
    gt::gt() |> fmt_number(decimals=3) |>
    tab_spanner(label="Male", columns=2:3) |>
    tab_spanner(label="Female", columns=4:5) |>
    cols_label(ageg="",nMale="Sample",pMale="Population",nFemale="Sample",pFemale="Population")
  
  list("panelA"=panelA, "panelB"=panelB)
}


descriptives_on_sample_df <- function(answersd) {
  se <- function(x) {
    sd(x, na.rm=TRUE)/sqrt(length(x[!is.na(x)]))
  }
  sesd <- function(x) {
    jackknife(x, sd, na.rm=TRUE)$jack.se
  }
  answersd %>%
    select( c(age,female,parent,risk_own,risk_others,good_works,edu,affect)) %>%
    dummy_cols(select_columns=c("edu","affect")) %>%
    select(-c(edu,affect)) %>%
    gather(key="key") %>%
    group_by(key) %>% 
    summarize(meanX = mean(value, na.rm=TRUE), seX = se(value),
              sdX = sd(value, na.rm=TRUE), sesdX = sesd(value)) 
}

hyper_params_df <- function(names, now, short, long, never) {
  now_l <- now |> dplyr::select(all_of(names)) |> mutate(treatment="Now")
  short_l <- short |> dplyr::select(all_of(names)) |> mutate(treatment="Short")
  long_l <- long |> dplyr::select(all_of(names)) |> mutate(treatment="Long")
  never_l <- never |> dplyr::select(all_of(names)) |> mutate(treatment="Never")
  hyper_parameters <- list(now_l, short_l, long_l, never_l) |> 
    bind_rows() |>
    mutate(treatment = factor(treatment, levels=c("Now","Short","Long","Never"))) |>
    pivot_longer(cols=all_of(names)) |> 
    mutate(name=factor(name, levels=names))
  hyper_parameters
}


prior_densities_df <- function(names) {
  x_vals <- seq(-4, 4, length.out = 1000)
  dhalfcauchy <- function(x, location = 0, scale = 1) {
    ifelse(x >= location, 
           2 * dcauchy(x, location = location, scale = scale),
           0)
  }
  prior_density_df <- expand.grid(
    value = x_vals,
    treatment = factor(c("Now", "Short","Long","Never", levels=c("Now","Short","Long","Never"))),
    name = names
  ) %>%
    mutate(
      density = case_when(
        name == "alpha_mu"  ~ dnorm(value, mean = 0, sd = 1),
        name == "alpha_sigma" ~ dhalfcauchy(value, 0, 1),
        name == "beta_mu"  ~ dnorm(value, mean = 0, sd = 1),
        name == "beta_sigma" ~ dhalfcauchy(value, 0, 1),
        name == "rho_mu"  ~ dnorm(value, mean = 0, sd = 1),
        name == "rho_sigma" ~ dhalfcauchy(value, 0, 1),
        name == "lambda_mu"  ~ dnorm(value, mean = -2, sd = 1),
        name == "lambda_sigma" ~ dhalfcauchy(value, 0, 1),
        TRUE ~ NA_real_
      )
    )
  prior_density_df
}