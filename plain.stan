// This file is an attempt to define an unrestricted heterogeneity model of 
// data from a single treatment of mmrisk. 

functions {
  real w_prelec(real p, real a, real b) {
    return exp( -b * pow( -log(p), a) );
  }
  real rdu(real y1, real y2, real p, real a, real b, real r) {
    real pi;
    pi = w_prelec(p, a, b);
    return (1-pi)*pow(y1, r) + pi*pow(y2, r);
  }
  real ce_rdu(real y1, real y2, real p, real a, real b, real r) {
    return pow( rdu(y1, y2, p, a, b, r), pow(r, -1));
  }
}

data {
  int<lower=0> D;               // Number of decisions
  int<lower=0> N;               // Number of individuals
  int<lower=0,upper=1> y[D];
  int<lower=1,upper=N> ll[D];
  vector<lower=0>[D] p2;          // Probability of good outcome
  vector<lower=0>[D] y1;          // Income in bad draw
  vector<lower=0>[D] y2;          // Income in good draw
  vector<lower=0>[D]  s;           // Safe amount
}

parameters {
  vector<lower=0>[N] alpha;
  vector<lower=0>[N] beta;
  vector<lower=0>[N] rho;
  vector<lower=0>[N] lambda;
  real alpha_mu;
  real<lower=0> alpha_sigma;
  real beta_mu;
  real<lower=0> beta_sigma;
  real rho_mu;
  real<lower=0> rho_sigma;
  real lambda_mu;
  real<lower=0> lambda_sigma;
}

transformed parameters {
  vector<lower=0>[D] ce;
  for (d in 1:D)
    ce[d] = ce_rdu( y1[d], y2[d], p2[d], alpha[ll[d]], beta[ll[d]], rho[ll[d]]); 
}

model {
  // Meta-priors:
  alpha_mu ~ normal(0, 1);
  alpha_sigma ~ cauchy(0, 1);
  beta_mu ~ normal(0, 1);
  beta_sigma ~ cauchy(0, 1);
  rho_mu ~ normal(0, 1);
  rho_sigma ~ cauchy(0, 1);
  lambda_mu ~ normal(-2, 1);
  lambda_sigma ~ cauchy(0, 1);

  // On each individual:
  for (n in 1:N) {
    alpha[n]  ~ lognormal(alpha_mu, alpha_sigma);
    beta[n]   ~ lognormal(beta_mu, beta_sigma);
    rho[n]    ~ lognormal(rho_mu, rho_sigma);
    lambda[n] ~ lognormal(lambda_mu, lambda_sigma);
  }
  
  // For each decision
  for (d in 1:D) {
    y[d] ~ bernoulli_logit(lambda[ll[d]]*(ce[d] - s[d]));
  }
}
