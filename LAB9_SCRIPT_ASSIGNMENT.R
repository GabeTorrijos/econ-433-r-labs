#Clear the workspace
rm(list=ls())  

#Load libraries
library(dplyr)
library(lfe)
library(stargazer)
library(ggplot2)

#Load airbnb.csv into a dataframe "df"
df <- read.csv("airbnb.csv")

#Create a variable called treated which is TRUE if the city 
#passed an Airbnb regulation between 2015 and 2016
df$treated <- df$city %in% c('New York', 'Los Angeles', 'San Francisco', 'Las Vegas')

#Create a variable called post which is TRUE if the year is
#2016 or later
df$post <- df$year>=2016

#Create a variable that is equal to treated times post and 
#call it treatedXpost
df$treatedXpost <- df$post * df$treated


#Create a DID analysis plot showing the trends in log(building_permits) 
#for the treatment and the control groups
plot_df <- df %>%
  group_by(treated, year) %>% 
  summarize(
    mean_log_building_permits = mean(log(building_permits))
  )

ggplot(data=plot_df) + 
  geom_line(aes(x=year, y=mean_log_building_permits, color=treated))


#Run the DID regressions
r1 <- felm( log(building_permits) ~ treatedXpost + treated + post, data=df)
r2 <- felm( log(building_permits) ~ treatedXpost | city + year, data=df)
r3 <- felm( log(building_permits) ~ treatedXpost + log(population) + log(avg_hh_income) + log(tourists) | city + year, data=df)

stargazer(r1, r2, r3, type="text")

#Check that building_permits are positive, can use log
summary(df$building_permits)