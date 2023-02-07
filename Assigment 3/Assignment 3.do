/* 

File header. Please fill in with the relevant information - the words in capital letters are placeholders.


Name: Gustaf Lewerth, NAME2.
Content: ASSIGNMENT 3, 
Date: 2023-Februari-DAY	

*/

set more off

/* 
Set up your working directory. This is the path of the folder in which you 
save all your files. 
*/ 

cd "/Users/gustaf/Documents/GitHub/EFI301-Assignments/Assigment 3"


// Clear memory, i.e., erase data that is alreday loaded.
clear all

/* 
Open the data set you want to work with 
(path relative to your working directory).
*/
use cps_big_data.dta


// Close running log files, as you can only run one log file at the time. 
capture log close


/* 
Start a new log file. The replace option makes sure that you overwrite the 
file when you re-run the do-file.
*/
log using LOGFILEASSIGNMENT3.log, replace	

********************************************************************************

/*
Now start your analysis. 
- Clearly label each answer.
- for questions that require a text reply give your answer in a comment block.
*/

/* Problem 8 */
	/*1. We start by dividing the sample into a training subsample (70% of sample) and a testing subsample (30% of sample) by using the following Stata commands. */

splitsample , generate(sample) split(.7 .3) rseed(1223) 
label define slabel 1 "Training" 2 "Test"
label values sample slabel

/* A new variable has been created. What does this variable indicate? 
Convince yourself that we have indeed sorted (at least approximately) 70% of the observations into the training subsample and 30% into the test subsample (Hint: Use tabulate*/
tabulate sample

/*	2. We first run an OLS regression on the levels of the continuous and the dummy variables using only the training data. We use the estimates store command to remember fitted regression models (Don't worry about the details here). */
reg lwage cont1-cont2 dummy1-dummy9 if sample==1 
estimates store ols_levels
reg lwage cont* dummy* interact* if sample==1
estimates store ols_all
/* How do we tell Stata to use only the training data when fitting the model?
 Explain what the wildcard operator (*) does. 
 What does dummy1-dummy9 mean?*/

/* By stating that weonly wish to  use the samples, where the label is 1, i.e training.*/
/* The wildcard "*" represetns one or two carachters, here it's the number at the end ov \textit{varname} */
/* The "cont1-cont2 dummy1-dummy9" Stipulates which variables should be included, i.e cont1 & cont2 & dummy1 through dummy9. */

/*	3. We will now compute the training error of the two regressions.*/
lassogof ols_levels ols_all if sample ==1
/* Which regression has the smaller training error (MSE = mean squared error)? Explain why we could have answered this question even without looking at the data.*/

/*-------------------------------------------------
       Name |         MSE    R-squared        Obs
------------+------------------------------------
 ols_levels |    .8746327       0.0788      1,050
    ols_all |    .8108753       0.1459      1,050
-------------------------------------------------
*/

/*We could have told this simply by realising that the  ols_all model is more complex and would probably have greater precission at the cost of more bias*/

/*	4. We will now compute the test error of the two regressions.*/
lassogof ols_levels ols_all if sample ==2
/*Which regression has the smaller test error? Why can a regression have small training error but large test error?*/

/*-------------------------------------------------
       Name |         MSE    R-squared        Obs
------------+------------------------------------
 ols_levels |    1.059587       0.0499        450
    ols_all |    1.186286      -0.0637        450
-------------------------------------------------*/
/* The ols_levels model now utperform the ols_all model. We see the effect of overfitting, i.e the model has to many variables with very little information gain, who all increase the bias and therfore makes our accuracy at ooutt of sample data much worse. */

/*	5. We now run a Ridge regression and compare it to the OLS regressions.*/ 
elasticnet linear lwage cont* dummy* interact* if sample==1, alpha (0) nolog rseed (1223)
/*-------------------------------------------------------------------------------
               |                               No. of      Out-of-      CV mean
               |                              nonzero       sample   prediction
alpha       ID |     Description      lambda    coef.    R-squared        error
---------------+---------------------------------------------------------------
0.000          |
             1 |    first lambda    205.0223       53      -0.0032     .9524592
            61 |   lambda before    .7718958       53       0.0523     .8997049
          * 62 | selected lambda    .7033227       53       0.0524     .8996733
            63 |    lambda after    .6408415       53       0.0524     .8996781
           100 |     last lambda    .0205022       53       0.0337     .9173624
-------------------------------------------------------------------------------*/

estimates store ridge_all
lassogof ols_all ols_levels ridge_all if sample ==2
/*Ridge regression uses as many features as the OLS regression that regresses on all features. Why does Ridge regression still perform well on the test sample? (Hint: Shrinkage.)*/
/*-------------------------------------------------
       Name |         MSE    R-squared        Obs
------------+------------------------------------
    ols_all |    1.186286      -0.0637        450
 ols_levels |    1.059587       0.0499        450
  ridge_all |    1.057637       0.0517        450
-------------------------------------------------*/
/*Well  you gave it away with the hint, simply, we get all the advantage of having a large and complex model, i.e. high precission, with the benefit of the small and simple model, i.e. less varinace, this makes the modell less overfitted on the training data.*/


/* 6. In addition to the Ridge regression above, run a second Ridge regression using only the levels of the predictors. For the two Ridge regressions, compare the lambda values selected by Stata. For which regression do we apply more shrinkage? Is this choice intuitive?*/
elasticnet linear lwage cont1-cont2 dummy1-dummy9 if sample==1, alpha (0) nolog rseed (1223)
/*-------------------------------------------------------------------------------
               |                               No. of      Out-of-      CV mean
               |                              nonzero       sample   prediction
alpha       ID |     Description      lambda    coef.    R-squared        error
---------------+---------------------------------------------------------------
0.000          |
             1 |    first lambda     176.418       11      -0.0032     .9524592
            78 |   lambda before    .1365941       11       0.0561      .896129
          * 79 | selected lambda    .1244594       11       0.0561     .8961281
            80 |    lambda after    .1134028       11       0.0561     .8961422
           100 |     last lambda    .0176418       11       0.0551     .8970955
-------------------------------------------------------------------------------*/
/* We see that the lamdas are smaller this time, that makes sense  given that we are  using fewer variables.*/

estimates store ridge_levels
lassogof ols_all ols_levels ridge_all ridge_levels if sample ==2
/*-------------------------------------------------
       Name |         MSE    R-squared        Obs
------------+------------------------------------
    ols_all |    1.186286      -0.0637        450
 ols_levels |    1.059587       0.0499        450
  ridge_all |    1.057637       0.0517        450
ridge_levels|    1.056942       0.0523        450
-------------------------------------------------*/
/*Even better results!*/


/* We now want to look at another penalized regression/shrinkage method, the LASSO (least absolute shrinkage and selection operator). The LASSO solves the following minimization problem

	(β_0ˆlasso , β_1ˆlasso , . . . , β_kˆlasso)
	=argmin(b_0,b_1..b_k){(1/2n)Sum[i=1->n(Y_i −b_0 −b_1 *X_1,i −···−b_k X_k,i)2 +λ*Sum[l=1->k(b_l)

where λ is regularization parameter. This is very similar to Ridge regression but uses a
different penalty function that measures how big the coefficient vector is by looking at
the sum of the absolute values of the components (rather than the sum of the squares of
the components). The absolute value function has a kink at zero, whereas the operation
of taking a square is smooth. A result of this is that in cases where Ridge regression
estimates a βˆridge very close to zero, LASSO often estimates a corner solution and sets j
βˆlasso exactly equal to zero. If the LASSO estimates βˆlasso ̸= 0 then we say that Xj is jj
selected by the LASSO, if the LASSO estimates βˆlasso = 0 then we say that Xj is not j
selected by the LASSO. This is why the LASSO is called a selection operator.*/


/*	7. We fit a LASSO regression by using the following commands.*/
elasticnet linear lwage cont* dummy* interact* if sample==1, alpha (1) nolog rseed (1223)
estimates store lasso_all
/*Compare the (estimated) test error of Ridge, LASSO and OLS using all features
as well as OLS using only the features corresponding to levels.*/
lassogof ols_all ols_levels ridge_all ridge_levels lasso_all if sample ==2
/*-------------------------------------------------
       Name |         MSE    R-squared        Obs
------------+------------------------------------
    ols_all |    1.186286      -0.0637        450
 ols_levels |    1.059587       0.0499        450
  ridge_all |    1.057637       0.0517        450
ridge_levels|    1.056942       0.0523        450
  lasso_all |    1.056924       0.0523        450
-------------------------------------------------*/
/* What! lasso_all  is the best model!*/


/*	8. Find out which variables were selected by the LASSO by using the following command.*/
lassocoef , display(coef)
/*Consider the following statement:
	"The variables that are not selected by the LASSO (e.g. cont2 = age and cont2 	square = age2) probably do not have an economic effect on
(log) wages."
Explain why this statement is wrong.*/
/*------------------------
             | lasso_all
-------------+----------
       cont1 |  .0271338
      dummy2 | -.0387529
      dummy6 | -.0241366
      dummy7 | -.0232785
  interact12 |  .1518034
  interact18 |   .011654
  interact21 |  .0246426
  interact25 |  .0957434
  interact26 |  .0261598
       _cons |         0
------------------------*/


/*HERE WE NEED A RESON FOR OUR ANSWER, I DON'T EXACTLY KNOW WHY*/


/*Problem 9*/
clear 
/*	1. Open the data in Stata. How is time encoded in the dataset?*/
use ts_minwage.dta

/* Two variables; month, int R[1-12] and year, int R[1947-1997].*/

/*	2. We now encode time in one variable using the following commands.*/
gen date = ym(year, month)
label variable date "date in year-month format"
/*Open the data editor and check how the date is encoded. How are the numbers in date supposed to be interpreted? (Hint: help datetime). How would you advance all dates by one year? For the convenience of humans who look at the data, prettify how the date is displayed.*/
/*help datetime*/
/*The time is displayed relative to january 1960, i.e botth in positive and negative time...  */
format date %tm
/*Look again at date. What has changed?*/
/*We now display time as yearmx, i.e. year followed by numerical month.*/

/*	3. Define new variables lminwage and lemp foot corresponding to logged values of minwage and emp_foot, respectively. Let's plot the two time series lemp foot and lminwage. We put them together into the same figure.*/
gen lminwage = log(minwage)
gen lemp_foot = log(emp_foot) 
twoway line lemp_foot date, saving(emp, replace) 
twoway line lminwage date, saving(minwage, replace)
gr combine emp.gph minwage.gph, col(1) iscale(1)
/*Do the time series exhibit (stochastic) trends?*/
/* Yes, first plot has a negative derivative, and the second plot has a positive derivative */

/*	4. We now use */
tsset date
/*to tell Stata that we are using a time series and that date is the time index. This will allow us to use special commands such as the D. operator to refer to first differences and the L. operator to refer to lagged values. For example we can write L.lminwage to refer to the lagged values (i.e. the previous period's value) of lminwage.
*/

/*	5. Compute the correlation between lemp_foot and the lagged value of lminwage (Hint: use the command cor and the L. operator). If we are interested in predicting the level of the minimum wage based on employment, why would we look at the correlation of employment with the lagged minimum wage rather than the
contemporaneous (i.e. current period) minimum wage? (Hint: monthly data).*/

correlate lemp_foot l.lminwage 
/*
             |                 L.
             | lemp_f~t lminwage
-------------+------------------
   lemp_foot |   1.0000
    lminwage |
         L1. |  -0.8653   1.0000*/

/* When employments are made, it's depending on salary at time of employment, i.e time before employment is made. An increases in wage will reduce the demand for employees, thus an increase in salary also increses suply of employees. Not the other way around, thus there is a time delay between wage and employment   */

/*	6. Explain the notion of a "spurious correlation" in the presence of trending time*/

/*  ##TO DO## */

/*	7. From now on we consider first differences. This gets rid of trends and hopefully is a first step towards making our time series stationary. Plot the first difference D.lemp foot against time.*/
twoway tsline D.lemp_foot

/*	8. Labor markets often exhibit systematic fluctuations over the course of a year. This is called seasonality. We remove the seasonal component from the employment time series by using the following code.*/
tab month , gen(m)
reg D.lemp_foot m2-m12
predict d_lemp_foot_adj , residuals
/*What does the first line of this piece of code do?
 The time series d lemp_foot adj is called seasonally adjusted.
 Explain why the seasonally adjusted time series has no seasonal component 
 (i.e. it will not exhibit a predictable pattern of variation over the course of a year). 
 From now on, we will use the seasonally adjusted time series. 
 Explain why a time series with a seasonal component cannot be stationary.
*/
/*	The first line of this code creates new rows in the data set, with binary values depending on the month, i.e if row m1 is true the data is from january etc.
As the name emplies, sesonaly adjusted time series, has had the sesonal component removed

If a time series has a sesonal component, it is time dependent, thus non-stationary
	*/

/*9. Regress d_lemp_foot_adj on the first difference of the lagged minimum wage. Does the minimum wage today predict employment in footwear manufacturing tomorrow
(α = 0.05, robust standard errors)?*/
regress d_lemp_foot_adj d.l.lminwage, robust

/*
------------------------------------------------------------------------------
             |               Robust
d_lemp_foo~j | Coefficient  std. err.      t    P>|t|     [95% conf. interval]
-------------+----------------------------------------------------------------
    lminwage |
         LD. |  -.0062394   .0132559    -0.47   0.638    -.0322723    .0197934
             |
       _cons |   9.90e-06   .0007962     0.01   0.990    -.0015538    .0015736
------------------------------------------------------------------------------*/
/*	Sadly we have a result within the 95% confidence interval, hence we can't reject the null-hypothesis and say that minwage has an effect */


/*	10. Explain why, in a time series context, even (heteroscedasticity) robust standard errors may be incorrect. Compute auto-correlation robust standard errors (Newey- West) by using the following code.*/
newey d_lemp_foot_adj D.L.lminwage , lag(12)
/*------------------------------------------------------------------------------
             |             Newey–West
d_lemp_foo~j | Coefficient  std. err.      t    P>|t|     [95% conf. interval]
-------------+----------------------------------------------------------------
    lminwage |
         LD. |  -.0062394   .0129344    -0.48   0.630    -.0316409    .0191621
             |
       _cons |   9.90e-06   .0006682     0.01   0.988    -.0013023    .0013221
------------------------------------------------------------------------------*/



/*Problem 10*/
clear 
use fatality long allyears.dta
/*	1. We set up the data set as a panel data set and replicate the panel regression from the lecture.*/
xtset state year
xtreg fr tax , fe
/* What is the numerical value of the t-statistic for the null hypothesis that tests the coefficient on fr against zero? Add the option vce(cluster state) to the fixed effect regression. What does it do? After adding the option you'll see a decrease in the realized absolute value of the t-statistic for the null hypothesis that tests the coefficient on fr against zero. Explain intuitively why this is expected.*/

/*	2. Suppose that due to safer cars the fatality rate of road accidents decreases over time. In addition, suppose that state beer taxes tend to increase over time for unrelated reasons. Intuitively argue why we may overestimate the causal effect of the beer tax.*/

/*	3. We now want to account explicitly for a time trend by including time dummies.*/
tab year, generate(dummy_y)
xtreg fr tax dummy_y2 -dummy_y7 , fe vce(cluster state)
/*Is it true that there is a time trend of decreasing number of road accidents? Consider the following statement:
	"If we observe that there is no decreasing time trend then we can just as well estimate the model without the time dummies. This will allow us to use the specification where tax is significant, rather than the specification where it is insignificant."
Explain why this statement is incorrect (Hint: p-hacking).
There is an easier way to add the time dummies to the regression.*/
xtreg fr tax i.year, fe vce(cluster state)
/*Verify that this command yields the same estimation results as our previous
approach.*/
/*
The time dummies that we included in the previous regression are called time fixed effects. Just like an individual or unit fixed effect has a constant effect (over all time periods) on a unit, a time fixed effect has a constant effect (for all units) on a time period. To write down a panel model with time and unit fixed effects we can write down for example
		Y_t =α_t+β_1*X_1,t+...+β_k*X_k,t+A+U_t for t=1,...,T, 
where αt is the time fixed effect for time period t and A is the individual or unit fixed effect.*/







********************************************************************************

/* 
At the end of the do-file, usually you'd want to save the changed data set 
under a different name (don’t overwrite the original file!).
*/
save NEWDATAFILENAME3, replace

// Close the log-file.
log close 
