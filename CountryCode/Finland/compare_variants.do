* compare main result and FDF data coverage across samples and percentile definitions
* INPUT by analysis_samples.do
ls "$TEMP/sample_*.dta"
* OUTPUT
* "$outDir/tables/alt_percentiles"


* Combine samples
* ===============

clear
save "$TEMP/cog_vs_earn_variants", emptyok replace
foreach sample in "full" "intermediate" "restricted" {
	use shnro syntyv p1_data cog_stanine* cog_sumscore* earnings wage using "$TEMP/sample_`sample'"
	gen sample = "`sample'"
	append using "$TEMP/cog_vs_earn_variants"
	save "$TEMP/cog_vs_earn_variants", replace
}
sort sample syntyv 

* income variables; atom at zero, tie-break jitter for equal-sized percentiles
set seed 1
foreach var of varlist earnings wage { 
	gen jittered = `var'
	replace jittered = round(`var',.01) + 0.02*runiform() - 0.01 if jittered==0
	local vlab: var label `var'
	gquantiles P_`var' = jittered, xtile nq(100) by(sample) 
	label var P_`var' "`vlab' percentile (within sample)"
	gquantiles PT_`var' = jittered, xtile nq(100) by(sample syntyv)	
	label var PT_`var' "`vlab' percentile (within cohort)"
	drop jittered	
}	
compress

tempfile fullp
preserve
keep if sample=="full"
keep shnro sample P*
foreach v of varlist P* {
	rename `v' F`v'
}
save `fullp'
sum
restore
merge m:1 shnro using `fullp', keep(3) nogen 

foreach v of varlist P* {
	rename `v' R`v'
	replace R`v'=. if sample!="restricted"
}
foreach v of varlist FP* {
	local newname = substr("`v'",2,.)
	rename `v' `newname'
}

label var P_earnings "Earnings percentile (within full sample)"
label var PT_earnings "Earnings percentile (within full sample cohort)"
label var P_wage "Wage percentile (within full sample)"
label var PT_wage "Wage percentile (within full sample cohort)"
label var RP_earnings "Earnings percentile (within restricted sample)"
label var RPT_earnings "Earnings percentile (within restricted sample cohort)"
label var RP_wage "Wage percentile (within restricted sample)"
label var RPT_wage "Wage percentile (within restricted sample cohort)"
label data ""
save "$TEMP/cog_vs_earn_variants", replace


use  "$TEMP/cog_vs_earn_variants", clear	
foreach pvar of varlist P* RP* {
use  "$TEMP/cog_vs_earn_variants", clear
drop if missing(`pvar')
gcollapse (count) n=syntyv n_cog=cog_stanine ///
	(mean) cog_stanine_z cog_stanine ///
	(semean) se_cog_stanine_z=cog_stanine_z se_cog_stanine=cog_stanine, ///
	by(sample `pvar') labelformat(#sourcelabel#) fast
label var n "N"
label var n_cog "Cognitive score observed"
label var cog_stanine "FDF stanine"
label var se_cog_stanine_z "Z-score of FDF stanine (semean)"
label var se_cog_stanine "FDF stanine (semean)"
save "$TEMP/cog_vs_`pvar'", replace
}	


clear
save "$outDir/tables/alt_percentiles", replace emptyok
filelist, dir("$TEMP") pattern("cog_vs_*P*_*.dta")
glevelsof filename
*
foreach fname in `r(levels)' {
use "$TEMP/`fname'", clear
ds *P*_*
gen percentile_name = "`r(varlist)'"
local pname = percentile_name[1]
local plab: var label `pname'
gen percentile_label = "`plab'"
drop percentile_name
rename `pname' P
append using "$outDir/tables/alt_percentiles"
save "$outDir/tables/alt_percentiles", replace
}
label var P "Percentile"
label var percentile_label "Percentile"
encode percentile_label, gen(percentile_type)
label var percentile_type "Percentile type"
drop percentile_label 
sort sample percentile_type P
order sample percentile_type P 
compress
save "$outDir/tables/alt_percentiles", replace

/*
log using $outDir/alt_percentiles.log, text replace
sum
desc
label list percentile_type
tab percentile_type sample 
log close
*/
