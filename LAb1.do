use "/Users/gustaf/Downloads/Stata"
clear
import delim "GPA1.csv", varnames(1), case(preserve)
label variable colGPA "Grade point average in collage"
label variable hsGPA "grrade poiint average in high scool"
label variable ACT "score university entrance exam"
pctile pctcolGPA = colGPA, nq(10)
save "GPA1Answers.dta"
