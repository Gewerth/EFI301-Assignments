/* 

File header. Please fill in with the relevant information - the words in capital letters are placeholders.


Name: Gustaf Lewerth, NAME2,
Content: ASSIGNMENT 2, 
Date: 2023-Februari-DAY	

*/

set more off

/* 
Set up your working directory. This is the path of the folder in which you 
save all your files. 
*/ 

cd "/Users/gustaf/Documents/GitHub/EFI301-Assignments/Assignment 2"


// Clear memory, i.e., erase data that is alreday loaded.
clear all

/* 
Open the data set you want to work with 
(path relative to your working directory).
*/
use airtravel00.dta


// Close running log files, as you can only run one log file at the time. 
capture log close


/* 
Start a new log file. The replace option makes sure that you overwrite the 
file when you re-run the do-file.
*/
log using LOGFILEASSIGNMENT2.log, replace	

********************************************************************************

/*
Now start your analysis. 
- Clearly label each answer.
- for questions that require a text reply give your answer in a comment block.
*/

/*  Problem 6
	1.  Consider the following model of demand on a given airline route
			log(passen) = β0 + β1 log(fare) + U. 					(1)
		a, Interpret the coefficient β1.
			if the fare increse by β1 % then the  number of passengers increase  by 1%.  		β1  is  the relation between fare and passengers. 
		b, Estimate the model. */
		gen lpassen =log(passen)
		gen lfare =log(fare)
		regress lpassen lfare
/*      lpas | Coefficient  Std. err.      t    P>|t|     [95% conf. interval]
-------------+----------------------------------------------------------------
       lfare |  -.4815181    .063324    -7.60   0.000    -.6057619   -.3572742
       _cons |   8.540983   .3273545    26.09   0.000     7.898703    9.183264
------------------------------------------------------------------------------
		
*/
/*
	2. Our application here is an example of demand estimation in a many markets framework. What is a market in our application? 
	## The market is the airline market, where buyers, buy seats from airlines. ##*/
	 
/*	3. In the model above, we do not control explicitly for the distance between the 	airport of origin and the destination. Suppose that model in problem 6.1 can be rewritten as
		log(passen) = β0 + β1 log(fare) + β2 log(dist) + V 			(2)
where the demand shock V satisfies the exogeneity assumption
		E[V | log(fare), log(dist)] = E[V | fare, dist] = 0. 		(3)
		a) Rewrite U from equation in (1) as a function of dist and V .*/
		/* 	β0 + β1 log(fare) + U =	 β0 + β1 log(fare) + β2 log(dist) + V		*/
		/*						U =  β2 log(dist) + V							*/
/*		b) Use this representation of U to state the exogeneity condition for OLS estima-
tion of model (1). */
	
	/*	Cov(fare, V) = 0 	(I)
	Using U = inserted into (I) we get Cov(fare, β2*log(dist) + U)  = -β2* Cov(fare,  log(dist) + cov(fare, U))= β2* Cov(fare, log(dist))=0*/

/*		c) Is it plausible that this exogeneity assumption is satisfied? Explain.*/
		/* For this to hold, either β2=0 or there is no covariance between fare and distance, the latter is more plausible, however some quick googling finds greater differnece between prices the longer the flights are, indcating that it inprobable that the exogenity assumption is satisfied. 

/*	4. We will now try to sign the bias that we face if the true model is (2) and we estimate β1 by fitting (1) by OLS. You may assume that we have a "large sample".
		a) Adapt the formula for omitted variable bias to this scenario.*/
		Cov(log(fare),log(dist))/var(log(fare))*β2 */
	
/*		b) What sign do you expect for β2?*/
		/* We expect that the number of people who fly 10+h flights is smaller than the number of people who fly 2h flights.  Hence we expect β2<0 */

/*		c) What sign do you expect for the covariance between log(fare) and log(dist)? */
gen ldist = log(dist)
correlate lfare ldist, covariance
		/*After some googleing of aiirfares, we've seen that the variance in price increses the longer the travle is. This would indicate that the covarience is positive.*/
/*		d) What sign do you expect for the omitted variable bias? */
		/*since the denumerator is >0 by definition and the nominator is >0 and  β2<0 the OV-bias has a negative sign. */

/*	5. We have data on dist and can estimate (2). Compare the the OLS estimates for the effect of log(fare) from the two models. Is your conjecture about the sign of the omitted variable bias confirmed?*/
regress lpassen lfare
/*
----------------------------------------------------------------------------
        lpas | Coefficient  Std. err.      t    P>|t|     [95% conf. interval]
-------------+----------------------------------------------------------------
       lfare |  -.4815181    .063324    -7.60   0.000    -.6057619   -.3572742
       _cons |   8.540983   .3273545    26.09   0.000     7.898703    9.183264
------------------------------------------------------------------------------
*/

regress lpassen lfare ldist
/*

   lpas | Coefficient  Std. err.      t    P>|t|     [95% conf. interval]
-------------+----------------------------------------------------------------
       lfare |  -.6128103   .0776797    -7.89   0.000    -.7652208   -.4603999
       ldist |   .1424345   .0491188     2.90   0.004     .0460617    .2388073
       _cons |   8.263681   .3400264    24.30   0.000     7.596537    8.930825
------------------------------------------------------------------------------
*/
/* No, we were wrong about the sign of β2, it was infact ngative. */

/*	6. Verify that the slope coefficient from fitting model (1) by OLS is equal to
					βˆ1ˆ + δˆ log(dist)|log(fare) βˆ2^			(III)
where βˆ1 and βˆ2 are the OLS estimates obtained by fitting model (2) and
				δˆ log(dist)|log(fare) = cov(log(dist),log(fare))/ Var^(log(fare)) 
is the slope coefficient from a regression of log(dist) on log(fare). */

/* From model 1 we get βˆ1= -.4815181 there are no more coeffisients. i.e βˆ1 is the slope coeficient. 
 Model 2 gives us βˆ1 = -.6128103 and βˆ2 = .1424345
*/ 
correlate ldist lfar, covariance
/*             |    ldist    lfare
-------------+------------------
       ldist |  .434984
       lfare |  .160316  .173921
	   */

tabstat lfare, s(variance)
/*
    Variable |  Variance
-------------+----------
       lfare |  .1739213
------------------------
*/
 
di  .160316 / .1739213 /* =.92177324*/

/* Thus, the expression (III) becomes  -.4815181 + .92177324 * .1424345 = -.35022579*/
di -.4815181 + .92177324 * .1424345

 /*βˆ1 i.e the slope coefficient from model (1) fitted by OLS is not equal to -.35022579. */


/*Problem 7 
For this problem we continue to use the data from Problem 6. */
/*	1. Generate new variables lpassen, lfare and ldist for logged passen, fare and
dist, respectively (if you haven't done so already).*/
 
/* Done previously */

/*	2. Fares for air travel are determined in a competitive market by the laws of supply and demand. Explain intuitively why this renders the exogeneity assumption (3) implausible.*/
	
		/* Fares are in the market the result of suply and demand.  We can express the demanded quantity as a linear function alpa_0 - alpha_1*p and suplied quantity as a function eta_0 +eta_a*p  where p is price, var_0 is amount produced and consumed when the price is 0, and var_1 is the increase in quantity produced/demanded if the price increased by 1. We know from economics that for every price only one possible number of products are exchanged. Thus eta_0 +eta_a*p = alpa_0 - alpha_1*p. To this model, we intorduce a rapid change in demand, we call it u, thus  eta_0 +eta_a*p = alpa_0 - alpha_1*p +u. We have now spotted a feed-back loop, the demanded quantity is dependent on this chock i.e if there is a rapid change in price, the demand and suply change is dependent on the price. Thus we can learn somthing about the dependent variable from the independent ones    */
 
/*	3. The data set "airconc00.dta" contains for each route the variable bmktshr which gives the market share of the airline with the largest market share on this route. This is a measure of the concentration of market power on a given route.*/

/*		a) Explain in intuitive terms (drawing from your knowledge of economic theory) how bmktshr influences the supply side of the market.*/
	/*When an actor on the market has monopoly power, he earns price setting power, ho does this through limiting suply. This maximizes his profit. Thus, large bmktshr would emply limited compitition and therfore suply more dependnet on the profit function of the largest actor.*/

/*		b) Suppose that one carrier stops providing service on a route so that bmktshr for this route increases. What happens to the supply curve for this route? What happens to the ticket price? Is the price change informative about the demand shock?*/
	/* when bmktshr increase, the monopoly power increase, thereby the suply curve aproximates the proffit curve of the supliers. this will either raise ticket prices or keep them at the same price. XXXXXXXXXXXXX*/

/*	4. We want to import the variable bmktshr into our dataset. */
/*		a) Type help merge to learn about the syntax of the stata command merge.*/
	help merge
/*		b) Run "merge 1:1 route using airconc00.dta" and explain the meaning of this command. */
	merge 1:1 route using airconc00.dta
	/*We make a joins of the coresponding enteries for the specified variable "route" for the file airconc00.dta */
/*		c) How does your dataset change? */
 /* Result                      Number of obs
    -----------------------------------------
    Not matched                             0
    Matched                             1,149  (_merge==3)
    -----------------------------------------*/
	/* We've sucesfully added another variable to our dataframe */

/*		d) Why do you have to specify "route"?*/
	/* To make a joins you need to specify the target/key(to match to) in stata that can be either a varlist or as ususal _n if you want a sequential merge. */  

/*	5. We want to estimate the structural equation (2) by instrumental variable regression.*/
/*		a) State the instrument relevance condition for using bmtshr as an instrument for lfare. Hint: The structural equation contains a control variable!*/

	/* log(passen) = β0 + β1 log(fare) + β2 log(dist) + V 	(2)	
		The instrument relevance condition is Cov(Z_1, X_1)!=0, where Z_1 is bmtshr and lfare is X_1 this gives Cov(bmtshr, lfare) != 0 */
		
/*		b) Do you expect it to be satisfied? Explain.*/
	
	/*Yes, we expect that the larger dominance an actor has on a market, the hifgher the pices will be, from the argument in 3.a. */

/*		c) Run the first stage and use the regression output to conduct a statistical test of the instrument relevance condition (α = 0.05). */

regress lfare bmktshr 
 
 /*  lfare | Coefficient  Std. err.      t    P>|t|     [95% conf. interval]
-------------+----------------------------------------------------------------
     bmktshr |  -.4722088   .0609252    -7.75   0.000    -.5917461   -.3526715
       _cons |   5.436751   .0385649   140.98   0.000     5.361085    5.512416
------------------------------------------------------------------------------ */
 
 /*Since H_0: bmktshr=0 is outside of the 95% confidence interval, we reject h_0 which emplies that the instrument is relevant */


/*		d) Now we want to develop a hypothetical setting in which the instrument
relevance assumption is not satisfied and in which we still have cov(bmtshr, log(fare))!= 0. Assume that passengers are willing to spend more money the longer the distance travelled. What would the joint distribution of log(dist) and bmtshr have to look like to ensure that that
    cov(bmtshr, log(fare)) < 0. */
		/* This would mean that more dominance of an actor on a route the less variance in price, since we already have that cor(lfare, ldist)>0 we would also have that cor(bmtshr, ldist)<0,  thus there would have to be more competition on longer flights, since these are the ones with larger fares.   */
		
/*	6. */
/*		a) State the appropriate instrument exogeneity assumption.*/
		/*E[U|Z_1, X_1, ... X_k]=0
		  E[U|bmktshr]        */
/*		b) Do you expect it to be satisfied? Explain.*/


/*	7. Instruments like market share that affect the supply side of the market are called "supply shifters". Supply shifters are often used to estimate demand parameters.
Explain briefly in intuitive terms*/
/*		a) why a supply shifter is a relevant instrument. */
	/*Suply shifters move the suply curve verticaly, thus enableing us to find the component that moves in horizontal direction, we besically create the ceteru paribus effect by decomposingthe vector of the suply function into two parts the supply shifter, and the ceteris paribus part*/

/*		b) under what conditions does a supply shifter satisfies the instrument exogeneity assumption.*/
	/*The instruments exogenity assumption E[U|Z_1, X_2,..,X_k]=0 is satisfied when Z_1 is uncorelated with the error term, i.e the supply shifter can have no predictive power of the error term. */

/*	8. The Stata command ivregress computes the IV estimates β_1ˆiv(ω0) and β_2ˆiv(ω0).
The output of ivregress also reports correct standard errors for the estimated coefficients. The Stata command to fit the IV regression is "ivregress 2sls lpassen ldist (lfare = bmktshr), robust"*/

/*		a) Run the IV regression and compare the estimated coefficient β_1ˆiv(ω0) to the
OLS estimate β_2ˆols(ω0) that we obtained by fitting (2) by OLS. 1 */
ivregress 2sls lpassen ldist (lfare = bmktshr), robust
/*------------------------------------------------------------------------------
             |               Robust
     lpassen | Coefficient  std. err.      z    P>|z|     [95% conf. interval]
-------------+----------------------------------------------------------------
       lfare |  -3.307795   .9266881    -3.57   0.000    -5.124071    -1.49152
       ldist |   1.135688   .3442868     3.30   0.001     .4608979    1.810477
       _cons |   15.49878   2.539809     6.10   0.000     10.52085    20.47672
------------------------------------------------------------------------------*/


/*		log(passen) = β0 + β1 log(fare) + β2 log(dist) + V 			(2*/

regress lpassen lfare ldist
/*------------------------------------------------------------------------------
     lpassen | Coefficient  Std. err.      t    P>|t|     [95% conf. interval]
-------------+----------------------------------------------------------------
       lfare |  -.6128103   .0776797    -7.89   0.000    -.7652208   -.4603999
       ldist |   .1424345   .0491188     2.90   0.004     .0460617    .2388073
       _cons |   8.263681   .3400264    24.30   0.000     7.596537    8.930825
------------------------------------------------------------------------------*/
/* We se that B_1^ols =-.6128103 & B_1^IV =-3.307795,
		  for B_2^ols = .1424345 & B_2^IV =1.135688*/

/*		b) Give an econometric explanation for the different estimates. */

/*	9. Now we want to compute the IV estimate βˆiv(ω0) by implementing the two-stage
least squares (2SLS) protocol. */

/*		a) Run the first-stage regression and store the fitted values from this regression in a new variable lfare hat. (Hint: use the command predict with the option xb).*/
regress lfare bmktshr 
predict lfare_hat, xb
/*		b) Run the second-stage regression and verify that you get the same estimates as you get by using the ivregress command.*/
regress lpassen lfare_hat ldist 
/*------------------------------------------------------------------------------
     lpassen | Coefficient  Std. err.      t    P>|t|     [95% conf. interval]
-------------+----------------------------------------------------------------
   lfare_hat |   1.772124   .3386188     5.23   0.000     1.107741    2.436506
       ldist |  -.2159496   .0477663    -4.52   0.000    -.3096688   -.1222304
       _cons |  -1.625216   1.598616    -1.02   0.310    -4.761758    1.511327 */

/*No the regression results are not the same, nor even similar. */
/*		c) Compare the standard errors reported at the second stage to the standard errors computed by ivregress. Explain. */












********************************************************************************

/* 
At the end of the do-file, usually you'd want to save the changed data set 
under a different name (don’t overwrite the original file!).
*/
save NEWDATAFILENAME2, replace

// Close the log-file.
log close 
