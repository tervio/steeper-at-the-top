* make dta for graphs that have cognitive test results on horizontal axis
* INPUT:
confirm file "$TEMP/sample_full.dta"
* OUTPUT:
* $outDir/tables/.dta

use "$TEMP/sample_full", clear


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
gen jittered=cog_sumscore
replace jittered = round(cog_sumscore,.01) + 0.02*runiform() - 0.01
gquantiles PT_cog_sumscore = jittered, xtile nq(100) by(syntyv)	
local vlab: var label cog_sumscore
label var PT_cog_sumscore "`vlab' percentile (within cohort)"
drop jittered	
compress


* Cognitive score stanine bins
* ============================

preserve
gcollapse (mean) cog_stanine_z earnings cog_sumscore cog_sumscore_z PT_earnings ///
	(semean) se_earnings=earnings se_PT_earnings=PT_earnings ///
	(p50) p50_earnings=earnings (count) n=syntyv, ///
	by(cog_stanine) fast
label var n "Observations"	
*
gen nsum = n in 1
replace nsum = nsum[_n-1] +n in 2/-1
replace nsum=. if cog_stanine==.
sum n if cog_stanine!=.
gen csum=nsum/`r(sum)'
gen cog_stanine_q=100*0.5*(csum+csum[_n-1]) if cog_stanine!=.
label var cog_stanine_q "Quantile (midpoint of stanine)"
replace cog_stanine_q=100*0.5*csum in 1
drop nsum csum
order cog_stanine* cog_sum*
*
save "$outDir/tables/earn_vs_cog", replace
restore	


* Cognitive score percentile bins
* ===============================

preserve
gcollapse (mean) cog_sumscore cog_sumscore_z cog_stanine cog_stanine_z ///
		earnings PT_earnings ///
	(semean) se_earnings=earnings se_PT_earnings=PT_earnings ///
	(count) n=syntyv , ///
	by(PT_cog_sumscore) fast
label var n "Observations"
save "$outDir/tables/earn_vs_cog-percentiles", replace
restore	

