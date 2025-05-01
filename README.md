# Risk taking on behalf of others: Does the timing of uncertainty revelation matter?" 

    - Alexander W. Cappelen (NHH)
    - Erik Ø. Sørensen (NHH)
    - Bertil Tungodden (NHH)
    - Xiaogeng Xu (Hanken School of Economics)


- [1. Data availability and Provenance](#1-data-availability-and-provenance)
  - [1.1 Dataset list](#11-dataset-list)
- [2. Computation requirements](#2-computation-requirements)
  - [2.1 Software requirements](#21-software-requirements)
  - [2.2 Controlled randomness](#22-controlled-randomness)
  - [2.3 Memory, runtime, and storage](#23-memory-runtime-and-storage)
- [3. Instructions to replicators](#3-instructions-to-replicators)
- [4. List of tables and programs](#4-list-of-tables-and-programs)
- [5. References](#5-references)



## 1. Data availability and Provenance

The data collected for this study are in the public domain and available (with detailed documentation) from Harvard Dataverse:

- Cappelen, Alexander W.; Sørensen, Erik Ø.; Tungodden, Bertil; Xu, Xiaogeng,
  2021, "Replication Data for: Risk taking on behalf of others: Does the timing
  of uncertainty revelation matter?", https://doi.org/10.7910/DVN/YCRFK1,
  Harvard Dataverse, V1, UNF:6:sCMtQj9J2avn/5NgCFS3vg== [fileUNF]

The code for running the online experiment and collecting this data is available at Zenodo,

- Sørensen, E. Ø., & Xu, X. (2025). MMRISK instrument (submission). Zenodo. [![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.15297374.svg)](https://doi.org/10.5281/zenodo.15297374)


For comparison of our data to the population, we also use reference numbers on the Norwegian population. We provide this data in the replication package.

- Statistics Norway (2019), "10211: Alders- og kjønnsfordeling i hele befolkningen 1846 - 2025", 
  [Statistics Norway, Table 10211](https://www.ssb.no/statbank/table/10211/), downloaded  2019-07-14.

### 1.1 Dataset list


## 2. Computation requirements

### 2.1 Software requirements

The main software required is R (v 4.5) and Stan (v 2.36). 


### 2.2 Controlled randomness

The random seed is set in `_targets.R`, line 16.

### 2.3 Memory, runtime, and storage

The machine runs on VMware Virtual Platform, on a 32-Core AMD EPYC 7543P, with Ubuntu 20.04.6 LTS (Focal Fossa), 5.15.0-130-generic Kernel with 192GB memory available.
Saving all stan outputs, about 35 GB memory is needed. As written, the program takes advantage of up to 16 cores, and then it runs for about 35 hours.

## 3. Instructions to replicators

## 4. List of tables and programs

| Display item | Filename   | Vignette | Chunk-name |
|--------------|------------|----------|------------|
| Table 1      | Design parameters, no data  | NA      | NA     |
| Table 2    |  attrition.tex | Descriptive_statistics.Rmd         |   Attrition         |
| Table 3a |   representativeness_of_sampleA.tex  | Descriptive_statistics.Rmd         |   Representativeness of sample         |
| Table 3b |   representativeness_of_sampleB.tex  | Descriptive_statistics.Rmd         |   Representativeness of sample         |
| Table 4      | descriptives_on_sample.tex | Descriptive_statistics.Rmd    | Descriptives on sample  | 
| Table 5     |   average_risk_taking_on_background.tex  | Results.Rmd     |  Regressions of average risk taking |
| Figure 1     | Design illustration, no data | NA | NA |
| Figure 2     | Design illustration, no data | NA | NA |
| Figure 3     | big_histogram.pdf  |  Descriptive_statistics.Rmd     | Distribution of choices  | 
| Figure 4     | avgchoice_by_treatment.pdf  | Descriptive_statistics.Rmd      | Graph of average outcomes    |
| Figure 5     | posteriors_AB.pdf    | Results.Rmd  | Posterior alpha and beta dists    |
| Figure 6     | weighting_functions.pdf | Results.Rmd | Weighting functions  |
| Figure 7     | posteriors_RL.pdf |  Results.Rmd   | Posterior lambda and rho dists     |
| Figure A1    | Traceplot_now.pdf  | Traceplots.Rmd | Traceplot: Treatment Now |
| Figure A2    | Traceplot_short.pdf  | Traceplots.Rmd | Traceplot: Treatment Short |
| Figure A3    | Traceplot_long.pdf  | Traceplots.Rmd | Traceplot: Treatment Long |
| Figure A4    | Traceplot_never.pdf  | Traceplots.Rmd | Traceplot: Treatment Never |

