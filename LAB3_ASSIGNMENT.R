# Clear the workspace
rm(list=ls())

# Load the packages
library(dplyr)

# Load the data from csv file
df <- read.csv("IPUMS_ACS2023_CA_1.csv")

# Replace invalid values of INCWAGE with NA
df$INCWAGE <- na_if(df$INCWAGE, 999999)
df$INCWAGE <- na_if(df$INCWAGE, 999998)

# Create a boolean variable for whether the person is employed
df$EMPLOYED <- df$EMPSTAT==1

# Calculate total population by county
pop_by_county <- df %>%
  group_by(COUNTYFIP) %>%
  summarize(
    TOTAL_POP = sum(PERWT, na.rm=TRUE)
  )

# Calculate employment rate by county
emprate_by_county <- df %>%
  group_by(COUNTYFIP) %>%
  summarize(
    EMPLOYMENT_RATE = weighted.mean(EMPLOYED, PERWT, na.rm=TRUE)
  )

# Calculate average income of employed individuals, by county
inc_by_county <- df %>%
  filter(EMPSTAT==1) %>%
  group_by(COUNTYFIP) %>%
  summarize(
    AVG_INCOME = weighted.mean(INCWAGE, PERWT, na.rm=TRUE)
  )

# Calculate average income of employed individuals, by county and sex
inc_by_county_sex <- df %>%
  filter(EMPSTAT==1) %>%
  group_by(COUNTYFIP, SEX) %>%
  summarize(
    AVG_INCOME = weighted.mean(INCWAGE, PERWT, na.rm=TRUE)
  )