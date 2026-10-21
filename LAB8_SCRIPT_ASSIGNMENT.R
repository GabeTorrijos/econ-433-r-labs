rm(list=ls()) #Clean the workspace

#Load necessary packages
library(dplyr)
library(lfe)
library(stargazer)

#Load the data
students <- read.csv("students.csv")
classes <- read.csv("classes.csv")

#Merge into one df
df <- left_join(students, classes, by = c("class_id", "school_id"))

#Create a boolean variable for small classes
df$small <- df$class_size == "SMALL"

#Create a dataframe of only experimental cohort students
df_exp <- df %>% filter(cohort == "EXPERIMENTAL")

#Create a dataframe of only regular cohort students
df_reg <- df %>% filter(cohort == "REGULAR")

#Regress small on income and race, experimental cohort
r0exp <- felm(small ~ log(family_income) + as.factor(race), data = df_exp)

#Regress small on income and race, regular cohort
r0reg <- felm(small ~ log(family_income) + as.factor(race), data = df_reg)

#Combine the balance-check regressions into one table
stargazer(r0exp, r0reg, type = "text")

#Column (1), the experimental cohort: income and race don't predict whether a 
#student gets a small class (no stars, R2 near 0). This is expected
#because students in this cohort were randomly assigned to classrooms.
#
#Column (2), the regular cohort: income and race predict a small class size.
#Higher-income students were more likely to get one, and Black and Hispanic
#students were less likely to. This means assignment in this cohort was
#not random.
#
#The table is trying to show that in the regular cohort, the students
#in small classes differ from the students in large classes in family income and race
#so a test score comparison would not be appropriate. In the experimental cohort, it would be.

#Regress test_score on class size and controls, experimental cohort
r1exp <- felm(test_score ~ small, data = df_exp)
r2exp <- felm(test_score ~ small + teacher_has_ma, data = df_exp)
r3exp <- felm(test_score ~ small + teacher_has_ma + as.factor(race) + log(family_income), data = df_exp)
r4exp <- felm(test_score ~ small + teacher_has_ma + as.factor(race) + log(family_income) | school_id, data = df_exp)

#Combine the test score regressions into one table
stargazer(r1exp, r2exp, r3exp, r4exp, type = "text")

#Column (1): students in small classes score about 9 points higher than
#students in large classes
#
#Column (2): once we control for teacher_has_ma, the small coefficient
#decreases (from about 9 to about 5). This happens because column (1) was also picking
#up the effect of teachers. Small classes are more likely to have teachers with master's
#degrees, and those teachers raise test scores by about 7.7 points.
#
#Columns (3) and (4): adding race, income, and school dummies barely change the
#small coefficient. This is expected because the random assignment of students to classrooms made income
#and race balanced across small and large classes.
#
#Overall: the effect of a small class is about 5 points, and it is
#statistically significant at the 1% level.

#Regress test_score on class size and controls, regular cohort
r1reg <- felm(test_score ~ small, data = df_reg)
r2reg <- felm(test_score ~ small + teacher_has_ma, data = df_reg)
r3reg <- felm(test_score ~ small + teacher_has_ma + as.factor(race) + log(family_income), data = df_reg)
r4reg <- felm(test_score ~ small + teacher_has_ma + as.factor(race) + log(family_income) | school_id, data = df_reg)

#Combine the regular cohort test score regressions into one table
stargazer(r1reg, r2reg, r3reg, r4reg, type = "text")

#The small coefficient is larger in the regular cohort than in the experimental
#cohort: about 15 in column (1) versus about 9. The gap stays about 5 to 6 points
#in columns (2) through (4) (about 10.7 versus about 5.1 to 5.3), so adding
#controls does not close it.
#
#This happens because students in the regular cohort were not randomly assigned
#to classrooms. Families with higher income were more likely to get a small class,
#and income also raises test scores. So part of the small coefficient is really
#the effect of family background, not class size.
#
#Controls don't close the gap because they only account for observed
#characteristics like income and race. Things like parental involvement are not
#in the data, so the regular cohort estimate stays biased upward (endogeneity).
#
#The experimental estimate of about 5 points is the better estimate of the true
#effect of class size, because random assignment makes the students in small and
#large classes similar on both observed and unobserved characteristics.