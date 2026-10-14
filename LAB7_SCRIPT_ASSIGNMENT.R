rm(list=ls()) #Clean the workspace

#Load in required libraries
library(dplyr)
library(ggplot2)
library(lfe)
library(stargazer)

#Load the main data
df <- read.csv("lab07_assignment_data.csv")

#Assign NA for invalid values of HHINCOME
df$HHINCOME[df$HHINCOME ==9999999] <- NA

#Create new variables
df$OWNHOME <- df$OWNERSHP == 1
df$COLLEGE <- df$EDUC >= 10
df$MALE <- df$SEX ==1
df$AGESQ <- df$AGE * df$AGE
df$MARRIED <- df$MARST %in% c(1, 2)

#Build the summary table by weighted homeownership rate by age of household head
own_by_age <- df %>%
  group_by(AGE) %>%
  summarize(OWNRATE = weighted.mean(OWNHOME, HHWT))

ggplot(own_by_age, aes(x = AGE, y = OWNRATE)) +
  geom_line() +
  labs(title = "Homeownership Rate by Age of Household Head: California 2019", x = "Age", y = "Homeownership Rate")

#Filter households with positive incomes
regdf <- df %>% filter(HHINCOME > 0)

#Regression 1
r1 <- felm(OWNHOME ~ log(HHINCOME), data = regdf, weights = regdf$HHWT)

#Regression 2
r2 <- felm(OWNHOME ~ log(HHINCOME) + AGE + AGESQ + MALE + COLLEGE + MARRIED + as.factor(RACHSING), data=regdf, weights = regdf$HHWT)

#Regression 3
r3 <- felm(OWNHOME ~ log(HHINCOME) + AGE + AGESQ + MALE + COLLEGE + MARRIED + as.factor(RACHSING) | COUNTYFIP + IND + OCC, data = regdf, weights = regdf$HHWT)

#Make a stargazer table
stargazer(r1, r2, r3, type = "text")