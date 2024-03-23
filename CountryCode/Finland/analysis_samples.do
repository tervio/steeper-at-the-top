* Prepare use data for each analysis sample
* INPUT:
confirm file  "$TEMP/subsets.dta"
confirm file "$TEMP/male_static.dta"
confirm file "$TEMP/skill_measures.dta"
* OUTPUT
* $TEMP/sample*.dta

use "$TEMP/subsets", clear
foreach sampleVar of varlist sample* {
preserve
local sampleLabel: var label `sampleVar'
keep if `sampleVar'
keep shnro syntyv
merge 1:1 shnro using "$TEMP/male_static", 	///
	keepusing(earnings_3545 wage_3545) keep(1 3) nogen
merge 1:1 shnro using "$TEMP/skill_measures", 	///
	keep(1 3) nogen
replace p1_data=0 if p1_data==. 
replace p2_data=0 if p2_data==. 
* Standardize subscores by base year
foreach v of varlist las san kuv {
	sum `v' if syntyv==1962
	gen std_`v' = (`v'-`r(mean)')/`r(sd)'
}
* English variable names and labels	
rename pluku cog_stanine
label var cog_stanine "Cognitive score (stanine)"
rename z_pluku cog_stanine_z
rename p1sum cog_sumscore
label var cog_sumscore "Sum of cognitive scores"
rename z_p1sum cog_sumscore_z
label var cog_sumscore_z "Sum of cognitive scores (standardized)"
rename p1_linear cog_linear
label var cog_linear "Cognitive score (SDs)"
rename p2_linear noncog_linear
label var noncog_linear "Non-cognitive score (SDs)"
rename p12_linear combo_linear
label var combo_linear "Combined score (SDs)"
rename std_kuv visuospatial
rename std_san verbal
rename std_las arithmetic
label var arithmetic "Arithmetic (SDs)"
label var verbal "Verbal (SDs)"
label var visuospatial "Visuospatial (SDs)"
rename earnings_3545 earnings
rename wage_3545 wage
*
label data "`sampleLabel'"
save "$TEMP/`sampleVar'", replace
di as result _n "`sampleLabel'"
restore
}

