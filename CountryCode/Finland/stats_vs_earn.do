* make dta's for graphs that have earnings on horizontal axis
* INPUT:
confirm file "$TEMP/sample_full.dta"
* OUTPUT:
* $outDir/tables/.dta


use syntyv earnings cog_stanine* arith verb visuo cog_sumscore* *linear using "$TEMP/sample_full", clear


* Make percentile variables
*==========================

* Earnings. Atom at zero; tie-break jitter to get equal-sized percentiles
*-------------------------------------------------------------------------
set seed 1
gen jittered=earnings
replace jittered = round(earnings,.01) + 0.02*runiform() - 0.01 if earnings==0
gquantiles PT_earnings = jittered, xtile nq(100) by(syntyv)	
local vlab: var label earnings
label var PT_earnings "`vlab' percentile (within cohort)"
drop jittered	

* Discrete test score variables
* -----------------------------
* tie-break jitter to get equal-sized percentiles
foreach var of varlist visuospatial verbal arithmetic cog_sumscore { 
gen jittered = round(`var',.01) + 0.02*runiform() - 0.01 
		local vlab: var label `var'
	gquantiles P_`var' = jittered, xtile nq(100)  
		label var P_`var' "`vlab' percentile (within sample)"
	gquantiles PT_`var' = jittered, xtile nq(100) by(syntyv)	
		label var PT_`var' "`vlab' percentile (within cohort)"
drop jittered	
}	

* Percentiles for continuous variables
foreach var of varlist *_linear {
local vlab: var label `var'
gquantiles P_`var' =  `var', xtile nq(100) 
	label var P_`var' "`vlab' percentile (within sample)"
gquantiles PT_`var' =  `var', xtile nq(100) by(syntyv)	
	label var PT_`var' "`vlab' percentile (within cohort)"
}

compress


* Make dta's for graphing
* =======================


* Cognitive score
* ---------------

preserve
gcollapse (mean) earnings cog* (semean) se_cog_stanine=cog_stanine se_cog_stanine_z=cog_stanine_z, ///
	by(PT_earnings) labelformat(#sourcelabel#) fast
save "$outDir/tables/cog_vs_earnings", replace	
restore


* Stanine shares
* --------------

preserve
keep if !missing(cog_stanine)
forvalues i=1(1)9 {
	gen stan`i' = cog_stanine==`i' 
	label var stan`i' "Share in stanine `i'"
}
gcollapse (mean) stan*, by(PT_earnings) labelformat(#sourcelabel#) fast
save "$outDir/tables/stanshares_vs_earnings", replace	
restore


* Standard deviation
* ------------------

preserve
keep if !missing(cog_stanine)
gcollapse (sd) sd_cog_stanine=cog_stanine sd_cog_stanine_z=cog_stanine_z, ///
	by(PT_earnings)  fast
save "$outDir/tables/cog-sd_vs_earn", replace	
restore


* Subscores 
* ----------

preserve
foreach v of varlist visuospatial verbal arithmetic {
	gen se_`v' = `v'
	local vlab: var label `v'
	label var se_`v' "`vlab'" 
}

gcollapse (mean) visuospatial verbal arithmetic ///
	(semean) se_*, ///
	by(PT_earnings) fast

save "$outDir/tables/subscores_vs_earnings", replace	
restore


* Anchored scores
* ---------------

preserve
foreach v of varlist cog_linear noncog_linear combo_linear {
	gen se_`v' = `v'
	local vlab: var label `v'
	label var se_`v' "`vlab'" 
}

gcollapse (mean) cog_linear noncog_linear combo_linear ///
	(semean) se_*, ///
	by(PT_earnings) fast

save "$outDir/tables/altscores_vs_earnings", replace	
restore
