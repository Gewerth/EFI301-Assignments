/* 

File header. Please fill in with the relevant information - the words in capital letters are placeholders.


Name: Gustaf Lewerth, NAME2, NAME3, NAME4
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
 <<Due to extreme sandboxing entire path is needed for me>> 
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
	/* Fråga 1 */
regress wage educ exper

	/*Fråga 2 */
gen lwage = log(wage) /* Detta gör en logaritmerad variant av wage, kallade lwage*/

regress lwage educ exper 

	/* Fråga 3*/
gen exper2 = exper^2

regress lwage educ exper exper2
margins, dydx(exper)
twoway (scatter exper exper2)


/*Problem 3*/
	*Fråga 1*/

regress lwage edux exper exper2
/*ST.ER ges i outputt av **regress** */

	/*Fråga 2*/
reg lwage educ exper exper2
predict U_hat, residuals

sum U_hat
corr U_hat educ exper exper2
/*Vi sparar fel-termen därav att det är lite correlation mellan felterm och allt men mer mellan de övriga framför allt mellan exper och exper2 */

	/*Fråga 3 */
twoway (scatter U_hat educ)
/* Nej, vi anser att det är heteroscedastiskt, då Studneter antagligen har läst olika saker, dvs. att olika utbildningar ger olika framtida livsinkomster. därav är den icke-obseverade termen vara vilken typ av utbildning som studneter har läst, därav ökar inte heller variansen ytterligare efter 15-års utbilndnig vilket ligger i lag med att phD- sellan betalar för sig. */

	/*Fråga 4*/
reg lwage educ exper exper2, robust
/*Ja*/

/* Problem 4*/
 /*Fråga 1*/

reg lwage educ exper exper2, robust

display invnormal(0.95)
/*Test värdet lämans i **regress** output under kolumnen "t", att mer erfarenhet har mindre effekt på lön desto mer erfarenhet en individ har. T-testet håller, på otroligt liten osäkerhetsnivå */

	/*Fråga 2 */
/*  .1016993    .1134744 med robust ///
    .1018637      .11331 utan robust ///
	 Vi såg tidigare att det inte är homoscedastiskt, vilket innebär att OLS-4 inte håller, därav blir det skilnad mär man tar det i beaktelse. */
	 
	/* Fråga 3 */
regress lwage educ exper exper2, level(90)
invnormal(0.9)


/*Problem 5*/
	/*Fråga 1*/
reg lwage educ exper exper2 midwest west south

/* B4 = -0.041 "den som bor i midwest har 4.1% lägre lön" 
   B5 = -0.05  "Den som bor i väst har 5% lägre lön"
   B6 = -0.104 "Den som bor i söder har 10% lägre lön"
   
	/*Fråga 2*/
H0 : B4=B5=B6=0
Om offekten av att bo i midwest, söder eller west har noll effekt på lön, så är det insignifikanta. */

	/*Fråga 3*/
gen obsnum =_n
gen k = the number of different groups
gen df1 = k - 1
gen df2 = obsnum - k
di invF(df1, df2, 0.95)

	/* Fråga 4*/ 

reg lwage educ exper exper2 midwest west south
test midwest west south 
      
	/* Fråga 5 */

reg lwage educ exper exper2 midwest west south
test educ exper exper2 midwest west south 


********************************************************************************

/* 
At the end of the do-file, usually you'd want to save the changed data set 
under a different name (don’t overwrite the original file!).
*/
save NEWDATAFILENAME1, replace

// Close the log-file.
log close 
