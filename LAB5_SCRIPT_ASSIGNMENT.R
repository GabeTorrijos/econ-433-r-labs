rm(list =ls()) # clear the workspace

#load libraries

library(dplyr)
library(ggplot2)

# load data
df <- read.csv("IPUMS_ACS_CA_2018_2023.csv")

# Deal with invalid values for INCWAGE and EMPSTAT
df$INCWAGE <- na_if(df$INCWAGE, 999999)
df$INCWAGE <- na_if(df$INCWAGE, 999998)
df$EMPSTAT <- na_if(df$EMPSTAT, 0)
df$EMPSTAT <- na_if(df$EMPSTAT, 9)

# Create college indicator (4+ years of college)
df$COLLEGE <- df$EDUC>=10

# change in avg income vs. change in pct college
county_2018 <- df %>%
  filter(YEAR==2018 & EMPSTAT==1 & AGE>=25 & AGE<=65) %>%
  group_by(COUNTYFIP) %>%
  summarize(
    AVERAGE_INCOME_2018 = weighted.mean(INCWAGE, PERWT, na.rm=TRUE),
    PCT_COLLEGE_2018 = weighted.mean(COLLEGE, PERWT, na.rm=TRUE)
  )

county_2023 <- df %>%
  filter(YEAR==2023 & EMPSTAT==1 & AGE>=25 & AGE<=65) %>%
  group_by(COUNTYFIP) %>%
  summarize(
    AVERAGE_INCOME_2023 = weighted.mean(INCWAGE, PERWT, na.rm=TRUE),
    PCT_COLLEGE_2023 = weighted.mean(COLLEGE, PERWT, na.rm=TRUE)
  )

# merge 2018 and 2023, calculate changes
county_change <- inner_join(
  county_2018,
  county_2023,
  by=c("COUNTYFIP")
)

county_change$INCOME_CHG <- county_change$AVERAGE_INCOME_2023 - county_change$AVERAGE_INCOME_2018
county_change$PCT_COLLEGE_CHG <- county_change$PCT_COLLEGE_2023 - county_change$PCT_COLLEGE_2018

#drop COUNTYFIP 0
county_change <- county_change %>%
  filter(COUNTYFIP != 0)

# make scatter plot
ggplot(data=county_change) +
  geom_point(aes(x=PCT_COLLEGE_CHG, y=INCOME_CHG)) +
  xlab("Change in Pct College 2018-2023") +
  ylab("Change in AVG Income 2018-2023") +
  ggtitle("Change in AVG Income vs. Change in Pct College, California 2018-2023")
