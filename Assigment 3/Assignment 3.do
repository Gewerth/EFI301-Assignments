/* 

File header. Please fill in with the relevant information - the words in capital letters are placeholders.


Name: Gustaf Lewerth, NAME2, NAME3, NAME4
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
use DATASET


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








********************************************************************************

/* 
At the end of the do-file, usually you'd want to save the changed data set 
under a different name (don’t overwrite the original file!).
*/
save NEWDATAFILENAME3, replace

// Close the log-file.
log close 
