# Data for "Risk taking on behalf of others: Does the timing of uncertainty revelation matter?" by Alexander W. Cappelen, Erik Ø. Sørensen, Bertil Tungodden and Xiaogeng Xu

There are three data files. 

## players.csv
This file keeps a master list of all participants that logged on.

- psid: unique identifier of individuals.
- treatment: string to identify which treatment they were in. Takes the values
  - now: immediate (online) revelation of outcomes.
  - week: participants are informed a week after participation.
  - month: participants are informed a month after participation.
  - never: participants are *not* informed about the outcome.
  - [empty]: participants did not complete, and are not recorded with a treatment.
- status: Indicates how far participants got in the experiment. The status codes are:
    - 10: Consent form.
    - 20: Instructions.
    - 30: Decisions.
    - 40: Non-incentivized questions.
    - 50: Feedback message. They saw the message, but didn't click the link to go back to the survey provider.
    - 100: Endpoint for those that did not consent to take part.
    - 110: Exited back to survey provider.
- created_at: time stamp (UTC).

## decisions.csv
This file is one row per decision per individual.

- psid: unique identifier of individuals.
- dienumber: Which of the 10 dice does this decision refer to?
  - 0: The outcomes on the die-faces are  (0,0,0,0,0,240)
  - 1: The outcomes on the die-faces are  (0,0,0,0,240,240)
  - 2: The outcomes on the die-faces are  (0,0,0,0,120,120)
  - 3: The outcomes on the die-faces are  (120,120,120,120,240,240)
  - 4: The outcomes on the die-faces are  (60,60,60,60,120,120)
  - 5: The outcomes on the die-faces are  (80,80,80,80,200,200)
  - 6: The outcomes on the die-faces are  (180,180,180,180,240,240)
  - 7: The outcomes on the die-faces are  (0,0,0,240,240,240)
  - 8: The outcomes on the die-faces are  (0,0,240,240,240,240)
  - 9: The outcomes on the die-faces are  (0,240,240,240,240,240)
- safe_amount: Safe outcome if participants chose not to throw dice.
- choice_risk: Indicator that takes value 1 if participant chose to throw die with this die and safe amount, 0 if not.
- updated_at: time stamp (UTC). Note that a series of choices are recorded at the same time (same die).

## answers.csv
This file is one row per non-incentivized question per individual.

- psid: unique identifier of individuals.
- item: Which question does this refer to? String, takes on values "answerX" for X in 1 to 8. See list below of which questions this refers to.
- answer: String response. For the most part numeric values, but not entirely.

### Which items in "answers.csv" corresponds to which questions, and coding

- answer1: "In general, on a scale of 1 to 7, how willing are you to take risks on your own behalf?" Extreme and average values indicated:
  - 1: Unwilling to take risks.
  - 4: Quite average
  - 7: Very willing to take risks.
- answer2: "What do you think the average participant in this survey answers about their own willingness to take risks (on the same 1-7 scale)?" Coded as answer1.
- answer3: "In general, on a scale of 1 to 7, how willing are you to contribute to good initiatives if you can not expect anything in return?" Extreme and average values indicated:
  - 1: Unwilling to contribute
  - 4: Quite average
  - 7: Very willing to contribute
- answer4: "What would you say best describes how you experienced making decisions on behalf of others in this survey?" They must choose one of:
  - 1: Hopeful
  - 2: Excited
  - 3: Worried
  - 4: Anxious
  - 5: Neither of the above
- answer5: "What is your gender?"
  - 1: Male
  - 2: Female
- answer6: "How old are you?" String response
- answer7: "What is your highest level of education?"
  - 1: Junior high school (*ungdomsskole*)
  - 2: High school (*Videregående*)
  - 3: Technical vocational school or similar (*Teknisk fagskole eller liknende*)
  - 4: College/university (*Høyskole/universitet*)
- answer8: "Do you have children?"
  - 1: Yes
  - 2: No
  