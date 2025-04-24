read_players <- function(fname) {
  read_csv(fname) %>%
    mutate( psid = as.integer(psid),
            treatment = as.factor(treatment),
            status = as.integer(status),
            treatment = fct_recode(treatment,
                                   "now" = "now",
                                   "short" = "week",
                                   "long" = "month",
                                   "never" = "never"),
            treatment = fct_relevel(treatment, c("now","short", "long", "never")))
}

read_decisions <- function(fname) {
  read_csv(fname) %>%
    mutate( psid = as.integer(psid),
            dienumber = as.integer(dienumber),
            safe_amount = as.integer(safe_amount),
            choice_risk = as.integer(choice_risk))
}

read_answers <- function(fname) {
  read_csv(fname, guess_max = Inf) %>%
    mutate( answer = ifelse(answer=="Trettiåtte", "38", answer), # transliteration
            answer = ifelse(answer=="Femtifire", "54", answer),  # transliteration
            answer = ifelse(answer=="1960", "59", answer),       # Birth year
            answer = ifelse(answer=="2ò", "20", answer),         # Keyboard error
            answer = ifelse(answer=="525", "52", answer),        # Keyboard error
            answer = ifelse(answer=="w5", "30", answer),         # Keyboard error (25 or 35 - take avg)
            answer = as.integer(answer),
            item = as.factor(item),
            q = fct_recode(item,
                           "risk_own" = "answer1",
                           "risk_others" = "answer2",
                           "good_works" = "answer3",
                           "emotion" = "answer4",
                           "gender" = "answer5",
                           "age" = "answer6",
                           "education" = "answer7",
                           "a_parent" = "answer8")) %>%
    select(-item) %>%
    spread( key = q , value=answer) %>%
    mutate(edu = fct_recode( factor(education, ordered=FALSE),
                             "Middle school" = "1",
                             "High school" = "2",
                             "Short tertiary, e.g. technical college" = "3",
                             "University level" = "4"),
           sex = fct_recode( factor(gender),
                             "Male" = "1",
                             "Female" = "2"),
           female = (gender==2),
           affect = fct_recode( factor(emotion),
                                "hopeful" = "1",
                                "excited" = "2",
                                "worried" = "3",
                                "anxious" = "4",
                                "none of the above" = "5"),
           parent = (a_parent==1))
}

## Meaning of constants in raw data
# The dies used in the experiment are characterized as such: 
dies <- tibble::tribble(
  ~dienumber, ~y1, ~y2, ~p2,
  0, 0, 240, 1/6,
  1, 0, 240, 2/6,
  2, 0, 120, 2/6,
  3, 120, 240, 2/6,
  4, 60, 120, 2/6,
  5, 80, 200, 2/6,
  6, 180,240, 2/6,
  7, 0, 240, 3/6,
  8, 0, 240, 4/6,
  9, 0, 240, 5/6
)

# Preparing the list necessary for the rstan processing:
preparing_estimation_data <- function(dframe, pframe, dies, treatment) {
  ds <- dframe %>% 
    full_join(dies, by="dienumber") %>%
    left_join(pframe, by="psid") %>% 
    dplyr::select(-c(created_at, status))
  df_treatment <- ds %>% 
    dplyr::filter(treatment==treatment) %>% 
    mutate(id = as.numeric(as.factor(psid))) %>%
    arrange(id,dienumber,safe_amount)
  dl_treatment <- list( N = length(table(df_treatment$id)),
                  D = nrow(df_treatment),
                  ll = df_treatment$id,
                  y = df_treatment$choice_risk,
                  p2 = df_treatment$p2,
                  y1 = df_treatment$y1,
                  y2 = df_treatment$y2,
                  s = df_treatment$safe_amount)
  dl_treatment
}


# Labelling and ordering non-incentivized variables
answersdf <- function(answers_complete) {
  answers_complete %>% 
  mutate(edu = fct_recode( factor(education,ordered=FALSE),
                           "Middle school" = "1",
                           "High school" = "2",
                           "Short tertiary, e.g. technical college" = "3",
                           "University level" = "4"
  ),
  sex = fct_recode( factor(gender),
                    "Male" = "1",
                    "Female" = "2"),
  female = (gender==2),
  affect = fct_recode( factor(emotion),
                       "hopeful" = "1",
                       "excited" = "2",
                       "worried" = "3",
                       "anxious" = "4",
                       "none of the above" = "5"),
  parent = (a_parent==1)
  )
}

read_ssb <- function(fname) {
  ssb <-read_csv2(here::here("external_data", fname),
                  locale = locale(encoding = "latin1"),
                  skip=2) |> 
    mutate(age =parse_number(alder),
           gender = 1*(`kjønn`=="Menn") + 2*(`kjønn`=="Kvinner")) |>
    filter(age>17) |> 
    mutate(ageg = cut(age, breaks=c(18,20,30,40,50,60,70,80,110), 
                      right=FALSE, ordered_result = TRUE)) |>
    select(-c(`kjønn`,"alder")) |>
    mutate(gender = factor(gender,
                           levels = c(1, 2),
                           labels = c("Male", "Female")))
  
  ssb
}
