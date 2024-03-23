* Clean and lable FDF (pkoe) test score data variables in current dataset

* From w:/PNAS2017_archive/merge/do/labels.do
* LABELS FOR PKOE-VARIABLES:
capture label variable id "ID"
capture label variable suorituspvm "Date of test"
capture label variable pkoe1_suorituspvm "Date of P1 test"
capture label variable pkoe2_suorituspvm "Date of P2 test"
capture label variable KUV_N "Visuospatial (stanine)"
capture label variable SAN_N "Verbal (stanine)"
capture label variable LAS_N "Arithmetic (stanine)"
capture label variable pluku "Cog.test (stanine)"
capture label variable kuv "Visuospatial"
capture label variable san "Verbal"
capture label variable las "Arithmetic"
capture label variable kuviot "Visuospatial (strings)"
capture label variable sanat "Verbal (strings)"
capture label variable laskut "Arithmetic(strings)"
capture label variable T1_1 "L-scale"
capture label variable T1_2 "F-scale" 
capture label variable T1_3 "K-scale"
capture label variable T1_4 "Psychopathic deviate"
capture label variable T1_5 "Hypochondriasis"
capture label variable T1_6 "Psychastenia"
capture label variable T1_7 "Schizophrenia"
capture label variable T2_1 "Leadership motivation"
capture label variable T2_2 "Activity-energy"
capture label variable T2_3 "Achievement striving"
capture label variable T2_4 "Self-confidence"
capture label variable T2_5 "Deliberation"
capture label variable T2_6 "Sociability"
capture label variable T2_7 "Dutifulness"
capture label variable T2_8 "Masculinity"
capture label variable johted "Leadership potential"
capture label variable T1_OSIOT "T1 (strings)"
capture label variable T2_OSIOT "T2 (strings)"
capture label variable synaika "Date of birth"
capture label variable Tk_tutnro "Statistics Finland ID"

* Replace impossible values with missing values
* From w:/PNAS2017_archive/merge/do/omit_typos.do

* Replace values that exceed the theoretical maximum with a missing value
* Pkoe 1:
replace kuv=. if kuv>40
replace las=. if las>40
* Pkoe 2:
replace T2_4=. if T2_4>32
replace T2_5=. if T2_5>26
replace T2_6=. if T2_6>33
replace T2_7=. if T2_7>18
replace T2_8=. if T2_8>27
