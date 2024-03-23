* Compare sample coverage relative to full study population
* ---------------------------------------------------------

local i=1 // y-axis to label
local j=2 // y-axis to plain
foreach country in "Finland" "Norway" {
preserve	
keep if country=="`country'"
keep if percentile_type==1  // 1 Earnings percentile (within full sample cohort)
replace sample="_"+sample
keep sample n* P
reshape wide n*, i(P) j(sample) string

foreach v of varlist n* {
	gen s_`v' = 100*`v'/n_full
}

replace P=P-0.5  // center plot point horizontally within percentile
*
twoway line s_n_full s_n_cog_full s_n_intermediate s_n_restricted P, yaxis(1 2) ///
	title("`country'") ///
	color(black black red red) lpattern(shortdash solid shortdash solid) ///
	scale(0.9) aspect(1) plotregion(margin(0 0 0 0)) ///
	xlabel(0(10)100) xtitle("Earnings (percentile)") ///
	xline(10(10)90, lcolor(gray%50) lwidth(thin) lpattern(dash)) /// 
	ylabel(0(10)100, axis(`i')) ylabel(none, axis(`j')) ///
	ytitle("% of full sample",size(*.8)) ///
	yline(10(10)100, lcolor(gray%50) lwidth(thin) lpattern(dash)) /// 
	legend(rows(1) ///
		order( 1 "Full sample" 2 "with cog.  observed" 3 "Restricted sample" 4 "with cog. observed" )) ///
	saving("$tempDir/`country'.gph", replace) nodraw		
restore
local i=2
local j=1
}

grc1leg2 "$tempDir/Finland.gph" "$tempDir/Norway.gph", ///
	pos(6) xcommon ycommon xtob1title ytol1title imargin(medsmall) 

graph export "$figureDir/figure-6.pdf", replace	
graph export "$figureDir/figure-6.jpg", quality(100) width(3200) replace	
