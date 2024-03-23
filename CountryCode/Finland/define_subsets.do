* Define subset indicators for comparisons with Keuschnigg et al (2023)
* full: Native men born 1962-75 observed every year at age 35-45
* intermediate: apply labor market entry criteria ... 
* restricted: ... and require cognitive test data
* INPUT:
confirm file "$AUX/earn_years.dta"
confirm file "$TEMP/male_static.dta" 
confirm file "$TEMP/skill_measures.dta"
* OUTPUT
* $TEMP/subsets


use shnro syntyv *_3545 using "$TEMP/male_static", clear

keep if n_3545==11 // balanced sample
drop n_3545
keep if inrange(syntyv,1962,1975) // these cohorts have earnings at age 35-45 also in Norway

merge 1:1 shnro using "$TEMP/skill_measures", keepusing(p1_data) keep(1 3) nogen 

merge 1:m shnro using "$AUX/earn_years", ///
	keepusing(year ptoim1 earnings) keep(1 3) nogen
gen byte employed_SF = (ptoim1==11)  // StatFin: classified as employed at end of year
drop ptoim1

* mimic Keuschnigg et al (2023) sample criterion
* ----------------------------------------------
gen byte notEmployed96 = (year==1996 & !employed_SF)
gen byte employed9709= inrange(year,1997,2009) & employed_SF

gcollapse (lastnm) *_3545 p1_data (max) notEmployed employed9709, ///
	 by(syntyv shnro) labelformat(#sourcelabel#) fast
	 
gen kcCriterion = notEmployed96 * employed9709
	 

* Subsets
* -------

gen sample_full = 1 
gen sample_intermediate = inrange(syntyv,1962,1975)  & kcCriterion
gen sample_restricted = sample_intermediate & (p1_data==1)
label var sample_full "Born 1962-75" 
label var sample_intermediate "Born 1962-75, not employed 1996, ever employed 1997-2010" 
label var sample_restricted "Born 1962-75, not employed 1996, ever employed 1997-2010, cog. score observed" 

keep shnro syntyv sample*
sort shnro 
compress
label data "Native born men born 1962-75, observed at age 35-45"
save "$TEMP/subsets", replace
