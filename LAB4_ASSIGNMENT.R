rm(list=ls()) #Clear the workspace

library(dplyr) #Load in the packages

df <- read.csv("IPUMS_ACS_CA_2018_2023.csv") #Read the combined dataset csv

# Calculate total population by county/year
county_pop <- df %>%
  group_by(COUNTYFIP, YEAR) %>% 
  summarize(
    POPULATION = sum(PERWT, na.rm=TRUE)
  )

# Convert invalid EMPSTAT code to NA
df$EMPSTAT <- na_if(df$EMPSTAT, 0)

# Create EMPLOYED boolean variable
df$EMPLOYED <- df$EMPSTAT==1

# Calculate the rate grouped by county and year
county_emp <- df %>%
  group_by(COUNTYFIP, YEAR) %>%
  summarize(
    EMPLOYMENT_RATE = weighted.mean(EMPLOYED, PERWT, na.rm=TRUE)
  )

# Define COLLEGE
df$COLLEGE <- df$EDUC>=10

# Find the percent of people aged 25+ with 4+ years of college by county and year.
county_educ <- df %>%
  filter(AGE>=25) %>%
  group_by(COUNTYFIP, YEAR) %>% 
  summarize(
    PCT_COLLEGE = weighted.mean(COLLEGE, PERWT, na.rm=TRUE)
  )

# Handle invalid INCWAGE codes
df$INCWAGE <- na_if(df$INCWAGE, 999999)
df$INCWAGE <- na_if(df$INCWAGE, 999998)

# Calculate average income of employed individuals by county and year
county_inc <- df %>%
  filter(EMPSTAT==1) %>%
  group_by(COUNTYFIP, YEAR) %>%
  summarize(
    AVG_INCOME = weighted.mean(INCWAGE, PERWT, na.rm=TRUE)
  )

# Merge the four dataframes into a single county/year dataframe
temp1 <- inner_join(county_pop, county_emp, by=c("COUNTYFIP","YEAR"))
temp2 <- inner_join(temp1, county_educ, by=c("COUNTYFIP","YEAR"))
county_df <- inner_join(temp2, county_inc, by=c("COUNTYFIP","YEAR"))
