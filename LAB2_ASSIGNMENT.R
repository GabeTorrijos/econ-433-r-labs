rm(list=ls())   # Clear the workspace

# Read IPUMS Data and store it in a dataframe.
df <- read.csv("IPUMS_ACS2023_CA_1.csv")

# Create a boolean variable called IS_HISPANIC, if a person is hispanic, true.
df$IS_HISPANIC <- (df$HISPAN != 0)
table(df$IS_HISPANIC)

# Create a boolean variable called NLF_WORKING_AGE_MALE that is TRUE if the person is not in the labor force,between ages 25-65, and male
df$NLF_WORKING_AGE_MALE <- (df$EMPSTAT==3) & (df$AGE>=25) & (df$AGE<=65) & (df$SEX==1)
table(df$NLF_WORKING_AGE_MALE)