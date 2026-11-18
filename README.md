# Selection Assessment Analysis

A retail clothing company hired sales associates through unstructured interviews and wanted a process based on evidence. It had written 15 assessment items and given them, along with a cognitive ability test, to 225 current sales associates. This analysis decides which of those measures are worth using to hire, and whether using them would disadvantage any group.

Case study with the full write up: https://othmanjournal.com/portfolio/selection-assessment.html

## What we found

| Question | Answer |
|---|---|
| How many things do the 15 items measure | Three. Counterproductive work behavior (CWB), emotional stability and conscientiousness. Each scale has a Cronbach's alpha of about .80 |
| Which predictors are worth using | Cognitive ability, conscientiousness and CWB. Emotional stability adds almost nothing and shows a gender difference |
| Which is strongest | Cognitive ability explains the most variance in performance, but it has the largest race difference |
| How to combine them | Equal weights. They predict about as well as regression weights and produce less adverse impact on race |
| Adverse impact if the top 100 of 225 are hired | Race ratio 0.55 and gender ratio 0.84 under equal weights. 0.80 is the usual warning line, so the race ratio is below it |

The race ratio is the main limit on this recommendation. The report says so and suggests weighing the prediction gain from cognitive ability against the fairness cost, and sourcing applicants differently.

## Method

1. Exploratory factor analysis (maximum likelihood, promax rotation) on the 15 items.
2. Reliability of each scale with Cronbach's alpha.
3. Correlations between predictors and the outcomes.
4. Multiple regression on two outcomes, manager performance ratings and rule infractions, with squared semi partial correlations to see each predictor's unique contribution.
5. T-tests for race and sex differences on each predictor and outcome.
6. A combined outcome from the z scores of ratings and reversed infractions.
7. Equal weight and regression weight composites compared on prediction.
8. Adverse impact ratios from a scenario that hires the top 100 of 225.

## Files

| File | What it is |
|---|---|
| `selection-assessment-analysis.sas` | The full analysis in SAS, in numbered sections that follow the method above |

## Data

The data file is `WorkingData (3).csv` in this repository. To run the code, change `&datafile` at the top of the SAS file to its location. The file has these columns.

| Column | Meaning |
|---|---|
| `Race` | 1 = white, 0 = non-white |
| `sex` | 1 = female, 0 = male |
| `cog` | Cognitive ability test score |
| `it1` to `it15` | Responses to the 15 assessment items, from 1 to 7 |
| `r1`, `r2` | Overall performance ratings from two managers, from 1 to 11 |
| `Inf` | Number of infractions, where a higher number means more rule violations |

## Notes on the code

- Items 1, 2, 9, 10 and 12 are reverse scored.
- The z scores use the sample means and standard deviations from `PROC MEANS`, entered as constants.
- Adverse impact ratio is the selection rate of the lower group divided by the selection rate of the higher group.

## Author

Mohammed Othman. MASc in Industrial/Organizational Psychology, University of Waterloo.
