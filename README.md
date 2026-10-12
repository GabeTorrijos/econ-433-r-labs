# ECON 433: R Labs in Applied Public Economics

Coursework from ECON 433 at California State University, Northridge. The labs use R to analyze American Community Survey (ACS) microdata from IPUMS for California, covering data cleaning, county-level summary statistics, visualization, and regression analysis.

## Skills demonstrated

- Cleaning survey data: recoding IPUMS missing-value codes to `NA`, building indicator variables
- Working with survey weights (`PERWT`) to produce population-level estimates
- Aggregating with `dplyr` (`group_by`, `summarize`, `filter`, `inner_join`)
- Visualization with `ggplot2`
- Regression with `lfe::felm`, including high-dimensional fixed effects, and formatted output with `stargazer`

## The labs

| Lab | Script | What it does |
|-----|--------|--------------|
| 2 | `LAB2_ASSIGNMENT.R` | Builds two indicator variables from IPUMS codes, `IS_HISPANIC` and `NLF_WORKING_AGE_MALE` (not in the labor force, male, aged 25-65), and tabulates each with `table()`. |
| 3 | `LAB3_ASSIGNMENT.R` | Recodes invalid `INCWAGE` values to `NA`, then computes 2023 county-level total population, employment rate, and average income of employed workers, overall and by sex. |
| 4 | `LAB4_ASSIGNMENT.R` | Repeats the county summaries for 2018 and 2023 and adds the share of adults 25+ with 4+ years of college. Merges population, employment rate, college share, and average income into one county-by-year table with `inner_join`. |
| 5 | `LAB5_SCRIPT_ASSIGNMENT.R` | Compares 2018 to 2023 for employed people aged 25-65. Computes each county's change in average income and in college share, then plots one against the other in a scatter plot. |
| 6 | `LAB6_SCRIPT_ASSIGNMENT.R` | Estimates five regressions of log wage income on a female indicator for employed 2018 workers, adding controls at each step (education, marital status, age, race and ethnicity, then occupation, industry, and county fixed effects, then hours worked). Results are shown side by side with `stargazer`. |

### What I found

- **Lab 5:** Across the 34 California counties identified in the data, counties with larger gains in college share between 2018 and 2023 tended to see larger gains in average wage income, but the relationship is weak (correlation of 0.28) and counties with similar college gains had very different income changes. With only 34 counties, this is suggestive rather than conclusive.
- **Lab 6:** Among employed California workers in 2018, women's wage income is about 28% lower than men's with no controls. Adding education, marital status, and age leaves the gap about the same (about 29%). Adding occupation, industry, and county fixed effects shrinks it to about 19%, and adding usual weekly hours shrinks it to about 12%. Part of the raw gap is associated with differences in occupation, industry, and hours worked, but a gap of about 12% remains unexplained by these controls. These are associations, not causal estimates.

### Caveats

- `INCWAGE` is in nominal dollars, so the 2018-2023 income changes in Lab 5 include inflation.
- The Lab 5 scatter plot shows correlation across counties, not a causal effect of education on income.
- The Lab 2 counts are unweighted sample counts, not population estimates.

## Data

The scripts use ACS microdata for California (2018 and 2023) from [IPUMS USA](https://usa.ipums.org). **The data files are not included in this repository**, because IPUMS's terms of use do not permit redistributing the data.

To reproduce the analysis, you need the IPUMS extracts and the combined file that Labs 4-6 read.

1. Create a free account at [usa.ipums.org](https://usa.ipums.org) and download CSV extracts for California from the ACS 2018 and 2023 samples. Each year comes as two extracts (`IPUMS_ACS2018_CA_1.csv` and `IPUMS_ACS2018_CA_2.csv`, and the same for 2023). Each contains different variables for the same people. Between them they include the variables the scripts use: `PERWT`, `COUNTYFIP`, `AGE`, `SEX`, `HISPAN`, `EMPSTAT`, `INCWAGE`, `EDUC`, `MARST`, `RACWHT`, `RACBLK`, `RACASIAN`, `OCC`, `IND`, and `UHRSWORK`, plus the identifiers `YEAR`, `SERIAL`, and `PERNUM`.
2. Build the combined file: inner-join each year's two extracts on `YEAR`, `SERIAL`, and `PERNUM`, stack the 2018 and 2023 results with `rbind`, and save the result as `IPUMS_ACS_CA_2018_2023.csv`. This step was done with a data-preparation script provided by the course instructor, which is not included here.
3. Put all the CSV files in the project folder.

Labs 2 and 3 read only `IPUMS_ACS2023_CA_1.csv`. Labs 4-6 read the combined file, which holds both years (distinguished by the `YEAR` column).

## Running the code

Requires R with these packages:

```r
install.packages(c("dplyr", "ggplot2", "lfe", "stargazer"))
```

Open `project.Rproj` in RStudio so the working directory is the project folder, put the data files there, and run any lab script.