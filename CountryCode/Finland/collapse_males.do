* Calculate person-level income variables for the study population
* INPUT:
* $AUX/person_static
* $AUX/earn_years
* OUTPUT: 
* $TEMP/male_static

macro list TEMP AUX cpiBaseYear

* Native-born male population for FDF birth years 
* =========================================================================

* Select native-born male cohorts with FDF test scores
use if inrange(syntyv,1962,1979) using "$AUX/person_static", clear
keep if inlist(syntyp2,11,21) // keep native-born (regardless of parent's background)
keep if sukup==1 // keep males
drop sukup syntyp2

merge 1:m shnro using "$AUX/earn_years", ///
	keepusing(year ptoim1 earnings wage) keep(1 3) nogen

foreach maxage of numlist 40 45 {	
gen byte age_35`maxage' = inrange(year-syntyv,35,`maxage')	
gen byte employed_35`maxage' = age_35`maxage' * (ptoim==11)
	foreach var of varlist earnings wage {
		gen `var'_35`maxage' = age_35`maxage' * `var'
		local lab : var label `var'
		label var `var'_35`maxage' "`lab'"
	}
}
gcollapse (count) n_years = year (sum) *_3540 *_3545, ///
	 by(syntyv shnro) labelformat(#sourcelabel#) fast

label var n_years "Years in FOLK since 1987"	
 
foreach maxage of numlist 40 45 {
rename age_35`maxage' n_35`maxage'
label var n_35`maxage' "Years in FOLK at age 35-`maxage'"
label var employed_35`maxage' "Years employed at age 35-`maxage'"
replace earnings_35`maxage' = earnings_35`maxage'/n_35`maxage'
label var earnings_35`maxage' "Yearly earnings at age 35-`maxage'"
replace wage_35`maxage' = wage_35`maxage'/n_35`maxage'
label var wage_35`maxage' "Yearly wage earnings at age 35-`maxage'"
}

label data "Native-born men; $cpiBaseYear euros"
compress
save "$TEMP/male_static", replace
