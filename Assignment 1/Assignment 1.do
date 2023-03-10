/* 

File header. Please fill in with the relevant information - the words in capital letters are placeholders.


Name: Gustaf Lewerth, Sebastian Tham. 
Content: ASSIGNMENT 1, 
Date: 2023-January-26	

*/

set more off

/* 
Set up your working directory. This is the path of the folder in which you 
save all your files. 
*/ 

cd "/Users/gustaf/Documents/GitHub/EFI301-Assignments/Assignment 1"


// Clear memory, i.e., erase data that is alreday loaded.
clear all

/* 
Open the data set you want to work with 
(path relative to your working directory).
*/
use cps.dta


// Close running log files, as you can only run one log file at the time. 
capture log close


/* 
Start a new log file. The replace option makes sure that you overwrite the 
file when you re-run the do-file.
*/
log using LOGFILEASSIGNMENT1.log, replace	

********************************************************************************

/*
Now start your analysis. 
- Clearly label each answer.
- for questions that require a text reply give your answer in a comment block.
*/

/*Problem 2*/
	/* Question 1 */
regress wage educ exper
	/*every year of education raises the wage by $1.24/H, with a 95% confidence between $1.17/H and $1.31/H. */

	/*Question 2 */
gen lwage = log(wage) /* This snipet makes a logarithmic version of wage called lwage*/

regress lwage educ exper 
	/* every year of education raises the income per hour by 11.3%*/

	/* Question 3*/
gen exper2 = exper^2 /* This term may explain that beyond a certain point more education does not emply more earning power*/

regress lwage educ exper exper2
margins, dydx(exper exper2)

	/* ∂exper = .0390322 
	   ∂exper2= -.0006602 
	   0 = ∂exper -2* ∂exper2*x => x= 
	   
	   
	   Marginal effects = 0.0390322- 2*0.0006602*x, range(0 50)
	   
 gen marginaleffect= 0.0390322*exper - 0.0006602*exper2      */
	   
twoway (scatter exper marginaleffect) 

gen zpoint = 

count if exper >  zpoint
/*There are no observations with the amount of experince*/


/*Problem 3*/
	*Question 1*/
regress lwage educ exper exper2
/*ST.ER is given in outputt of **regress** as .0000478 */

	/*Question 2*/
reg lwage educ exper exper2
predict U_hat, residuals

sum U_hat
corr U_hat educ exper exper2
/*We save the error-term as U_hat. Hence, there is a small corelation between it and all other variables but more between the others especially exper and exper2. i.e. Exp(U_hat) != 0  */

	/*Question 3 */
twoway (scatter U_hat educ)
/*No, we belive that it is heteroscedastic, beacuse students have probably read diferent subjects, and different educations garner different lifetime incomes, hence the non-observed term is probably what kind of education the studnets have had, therfore the variance doesn't increase after 15 years pointing to exesively long educations not being worth while */

	/*Question 4*/
reg lwage educ exper exper2, robust
/*Yes, slighly*/

/* Problem 4*/
	/*Question 1*/
reg lwage educ exper exper2, robust

di (- .0006602-0)/.0000498

display invnormal(0.05/2)
display invnormal(1-(0.05/2))
/*The test-value is returned in the **regress** output under column "t".
 The Zero-hyp states that the effect of more experince is the same independent of how much experience the person has. 
 */
 
display invnormal(0.05/2) /* -1.9596 */
display invnormal(1-(0.05/2)) /* 1.9596 */

/* Critial region on [- inf, -1.9596] & [1.9596, inf].

reject the null-hypo, ≈-13<≈-2. */
 
	/*Question 2 */
/*  .1016993    .1134744 with robust ///
    .1018637      .11331 without robust ///
	We saw previously that it isn't  homoscedastic, which means that OLS-4 doesn't hold, hence there will be some difference when taking this into account and allow for non robust standard errrors. */
	 
	/* Question 3 */
regress lwage educ exper exper2, level(90) /*Easier*/

invnormal(0.95)
	di 0.1075	-invnormal(0.95)*0.0030031 
	di 0.1075869+invnormal(0.95)*0.0030031

/*Problem 5*/
	/*Question 1*/
reg lwage educ exper exper2 midwest west south

/* B4 = -0.041 "He who lives in the midwest has 4.1% lower salary than north east" 
   B5 = -0.05  "He who lives in the west has 5% lower salary than north east"
   B6 = -0.104 "He who lives in the south has 10% lower salary than north east"
   
	/*Question 2*/
H0 : B4=B5=B6=0
If the effects of living in the midwest, south and West is zero, then that's insignificant. */

	/*Question 3*/
gen obsnum =4733
gen k = 6
gen q = 3
gen df1 = q
gen df2 = obsnum - k -1 /*4726*/
di invF(df1, df2, 0.95)
	/*F(w)= 2.606787)*/

	/* Question 4*/ 

reg lwage educ exper exper2 midwest west south
test midwest west south 
	/*F(3,4726)=10.86. This is larger than the answer in Question 3, which means that the actual calculated F-value is larger than the critical, hence the zero hypothesis is rejected. The doefisients are jointly significant, it does affect your salary if you live outside the northe east, at least somewhere*/
	
	di 1-F(dfq, df2, 10.86) /* Probability of getting an F> F-from test above is very small */


      
	/* Question 5 */

 di F(df1,df2,1.8)
 /* p(f=1.8)=0.1449  probability of getting F>1.8 is 14,5%*/

	/* Question 6*/

reg lwage educ exper exper2 midwest west south
test educ exper exper2 midwest west south 

/* F(6, 4726) = 332.53, the calculated  F-value is much larger than al typical significanses of 0.1,0.05,0.01. This means that we ca reject the zero-hypothesis and thereby know that our model has joint significance, and has descriptive poswers of what affects salary.*/

********************************************************************************

/* 
At the end of the do-file, usually you'd want to save the changed data set 
under a different name (don’t overwrite the original file!).
*/
save NEWDATAFILENAME1, replace

// Close the log-file.
log close 
