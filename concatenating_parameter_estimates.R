library(rstan)
library(tidyverse)
library(glue)

# Concatenating 

dl1 <- list()
load("data/fit_short.Rdata")
for (i in 1:492) {
  an <- glue('alpha[{i}]')
  bn <- glue('beta[{i}]')
  rn <- glue('rho[{i}]')
  ln <- glue('lambda[{i}]')
  tdf <- rstan::extract(fit_short, pars=c(an,bn,rn,ln))
  tdf$treatment = "short"
  tdf$id = i
  dl1[[i]] <- tdf
}
d1 <- bind_rows(dl1)
rm(fit_short,dl1)

dl2 <- list()
load("data/fit_now.Rdata")
for (i in 1:494) {
  an <- glue('alpha[{i}]')
  bn <- glue('beta[{i}]')
  rn <- glue('rho[{i}]')
  ln <- glue('lambda[{i}]')
  tdf <- rstan::extract(fit_now, pars=c(an,bn,rn,ln))
  tdf <- as_tibble(tdf)
  colnames(tdf) <- c("alpha","beta","rho","lambda")
  tdf$treatment = "now"
  tdf$id = i
  dl2[[i]] <- tdf
}
d2 <- bind_rows(dl2)
rm(fit_short,dl2)

dl3 <- list()
load("data/fit_long.Rdata")
for (i in 1:529) {
  an <- glue('alpha[{i}]')
  bn <- glue('beta[{i}]')
  rn <- glue('rho[{i}]')
  ln <- glue('lambda[{i}]')
  tdf <- rstan::extract(fit_long, pars=c(an,bn,rn,ln))
  tdf <- as_tibble(tdf)
  colnames(tdf) <- c("alpha","beta","rho","lambda")
  tdf$treatment = "long"
  tdf$id = i
  dl3[[i]] <- tdf
}
d3 <- bind_rows(dl3)
rm(fit_long,dl3)

dl4 <- list()
load("data/fit_never.Rdata")
for (i in 1:492) {
  an <- glue('alpha[{i}]')
  bn <- glue('beta[{i}]')
  rn <- glue('rho[{i}]')
  ln <- glue('lambda[{i}]')
  tdf <- rstan::extract(fit_never, pars=c(an,bn,rn,ln))
  tdf <- as_tibble(tdf)
  colnames(tdf) <- c("alpha","beta","rho","lambda")
  tdf$treatment = "never"
  tdf$id = i
  dl4[[i]] <- tdf
}
d4 <- bind_rows(dl4)
rm(fit_never,dl4)

all_params <- bind_rows(list(d1,d2,d3,d4))




