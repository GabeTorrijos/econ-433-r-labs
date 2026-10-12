rm(list=ls())   # Clear workspace
library(dplyr)  # Load required libraries
library(stargazer)
library(lfe)

# Load the main data
df <- read.csv("IPUMS_ACS_CA_2018_2023.csv")

# Deal with invalid values for INCWAGE
df$INCWAGE <- na_if(df$INCWAGE, 999999)
df$INCWAGE <- na_if(df$INCWAGE, 999998)

# Create a boolean variable indicating the person
# is female
df$FEMALE <- df$SEX==2

# Create a boolean variable indicating if the person
# is married
df$MARRIED <- df$MARST==1 | df$MARST==2

# Create a boolean variable indicating the person
# has 4+ years of college education
df$COLLEGE <- df$EDUC>=10

# Create booleans for race 
df$WHITE <- df$RACWHT==2
df$BLACK <- df$RACBLK==2
df$ASIAN <- df$RACASIAN==2
df$HISPANIC <- df$HISPAN>=1

# Create a squared age term
df$AGESQ <- df$AGE**2

# The data we want to run the regression on:
# employed people in 2018, with positive income
regdf <- df %>% filter(YEAR==2018 & INCWAGE>0 & EMPSTAT==1)

# Regress log(INCWAGE) on FEMALE
r1 <- felm(
  log(INCWAGE) ~ FEMALE, 
  data=regdf, 
  weights=regdf$PERWT
)

# Regress log(INCWAGE) on FEMALE, COLLEGE, MARRIED, AGE, AGESQ
r2 <- felm(
  log(INCWAGE) ~ FEMALE + COLLEGE + MARRIED + AGE + AGESQ, 
  data=regdf,
  weights=regdf$PERWT
)

# Regress log(INCWAGE) on FEMALE, COLLEGE, MARRIED, AGE, AGESQ
# and race (WHITE, BLACK, ASIAN, HISPANIC)
r3 <- felm(
  log(INCWAGE) ~ FEMALE + COLLEGE + MARRIED + AGE + AGESQ +
    WHITE + BLACK + ASIAN + HISPANIC, 
  data=regdf,
  weights=regdf$PERWT
)

# Regress log(INCWAGE) on FEMALE, COLLEGE, MARRIED, AGE, AGESQ,
# race, and OCC, IND, and COUNTYFIP (treat OCC, IND, and
# COUNTYFIP as large dummy variables)
r4 <- felm(
  log(INCWAGE) ~ FEMALE + COLLEGE + MARRIED + AGE + AGESQ + 
    WHITE + BLACK + ASIAN + HISPANIC | OCC + IND + COUNTYFIP,
  data=regdf,
  weights=regdf$PERWT
)

# Regress log(INCWAGE) on FEMALE, COLLEGE, MARRIED, AGE, AGESQ,
# race, OCC, IND, COUNTYFIP, and log(UHRSWORK)
r5 <- felm(
  log(INCWAGE) ~ FEMALE + COLLEGE + MARRIED + AGE + AGESQ +
    WHITE + BLACK + ASIAN + HISPANIC + log(UHRSWORK) | OCC + IND + COUNTYFIP,
  data=regdf,
  weights=regdf$PERWT
)

# Show the regression results
stargazer(r1, r2, r3, r4, r5, type="text")
