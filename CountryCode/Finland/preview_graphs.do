* Test graphs using takeout tables prior to takeout. "Finnish halves" of manuscript figures 
* INPUT: 
* $outDir/tables/
* OUTPUT: 
* $outDir/figures/

macro list GPH outDir


* Figure 1
* ========

use "$outDir/tables/earn_vs_cog", clear
histogram cog_stanine [fw=n], percent disc  ///
	aspect(1) ///
	fcolor(gray%50) lcolor(black) lwidth(thin) ///
	xlabel(1(1)9) xtitle("Stanine")

graph export "$outDir/figures/figure-1.png", width(3200) replace	


* Figure 2
* ========

use "$outDir/tables/cog_vs_earnings", clear

* 95% confidence interval
gen ci_plus = cog_stanine_z + 1.96*se_cog_stanine_z
gen ci_minus = cog_stanine_z - 1.96*se_cog_stanine_z
format cog_stanine_z ci_* %2.1f

replace PT_earnings=PT_earnings-0.5  // center within percentile
* Custom yaxis(2) labels: mapping from raw stanine to z-score 
quiet reg cog_stanine_z cog_stanine  
di "This should be 1: " `e(r2)' //  R^2 = 100%
local b = _b[cog_stanine]
local a = _b[_cons]
forvalues i = 4(1)7 { 
 local p`i' = `a'+`b'*`i'
}
*
twoway ///
	(rarea ci_plus ci_minus PT_earnings, ///
		fcolor(black%20) lcolor(black%10) yaxis(1 2)) ///
	(scatter cog_stanine_z PT_earnings, ///
		msize(tiny) connect(l) msym(Sh) color(black%60) yaxis(1)), ///
scale(0.9) aspect(1) plotregion(margin(0 0 0 0)) ///
ytitle("Cognitive score (stanine)", axis(2)) ytitle("Cognitive score (standardized)", axis(1)) ///	
ylabel(-0.5(0.5)1.0, axis(1)) ymticks(-0.7(0.1)1.3, axis(1)) /// 
ylabel(`p4' "4" `p5' "5" `p6' "6" `p7' "7" , axis(2)) yscale(titlegap(2)) ///
yline(-0.5(0.5)1.0, lcolor(gray%50) lwidth(thin) lpattern(dash)) /// 
xtitle("Earnings (percentile)", size(*0.9)) xscale(titlegap(1)) ///	
xlabel(0(10)100)  xscale(titlegap(3)) ///
xline(10(10)90, lcolor(gray%50) lwidth(thin) lpattern(dash)) /// 
legend(off) 

graph export "$outDir/figures/figure-2.png", width(3200) replace


* Figure 3
* ========

use "$outDir/tables/stanshares_vs_earnings", clear

replace PT_earnings=PT_earnings-0.5
foreach v of varlist stan? {
replace `v' = 100*`v'
}

twoway (scatter stan1 PT_earnings, ///
		msize(vsmall) connect(l) msym(sh) color(red%60) yaxis(1 2)) ///
	(scatter stan2 PT_earnings, ///
		msize(vsmall) connect(l) msym(O) mfc(white) color(orange%60)) ///
	(scatter stan8 PT_earnings, ///
		msize(vsmall) connect(l) msym(O) mfc(white) color(gray%60)) ///
	(scatter stan9 PT_earnings, ///
		msize(vsmall) connect(l) msym(sh) color(black%60)), ///
scale(0.9) aspect(1) plotregion(margin(0 0 0 1)) ///
xtitle("Earnings (percentile)", size(*0.9)) ///	
ytitle("Share in stanine (%)", axis(1)) ytitle("", axis(2)) ///	
ylabel(0(5)30, axis(1)) ymticks(1(1)29, axis(1)) ///
ylabel(0(5)30, axis(2)) ymticks(1(1)29, axis(2)) ///
yline(0(5)30, lcolor(gray%50) lwidth(thin) lpattern(dash)) /// 
xlabel(0(10)100) xsc(titlegap(2)) ///
xline(10(10)90, lcolor(gray%50) lwidth(thin) lpattern(dash)) /// 
legend(pos(6) rows(2)  ///
	order(1 "Stanine 1" 2 "Stanine 2" 3 "Stanine 8" 4 "Stanine 9"))

graph export "$outDir/figures/figure-3.png", width(3200) replace
	

* Figure 4
* ========	

use "$outDir/tables/cog-sd_vs_earn", clear

global xvar PT_earnings 
global yvar sd_cog_stanine_z 
format sd_cog_stanine_z %2.1f

replace PT_earnings=PT_earnings-0.5
*
twoway (scatter sd_cog_stanine_z PT_earnings, yaxis(1 2) ///
	msize(vsmall) connect(l) msym(sh) color(black%60)), ///
 scale(0.9)  aspect(1) plotregion(margin(0 0 2 1)) ///
 xtitle("Earnings (percentile)", size(*0.9)) ///	
 ytitle("Standard Deviation of Cognitive Scores", axis(1)) ytitle("", axis(2)) ///	
 ylabel(0.7(0.1)1.1, axis(1)) ymticks(0.7(0.1)1.1, axis(1)) ///
 ylabel(0.7(0.1)1.1, axis(2)) ymticks(0.7(0.1)1.1, axis(2)) ///
 yline(0.7(0.1)1.1, lcolor(gray%50) lwidth(thin) lpattern(dash)) /// 
 xlabel(0(10)100) ///
 xline(10(10)90, lcolor(gray%50) lwidth(thin) lpattern(dash)) /// 
 legend(off)
 
graph export "$outDir/figures/figure-4.png", width(3200) replace


* Figure 5
* ========	

use "$outDir/tables/earn_vs_cog", clear
append using "$outDir/tables/earn_vs_cog-percentiles"
drop if cog_stanine_q==. & PT_cog_sumscore==.

forvalues i=1(1)9 {
	qui sum PT_earnings if cog_stanine==`i'
	local s`i'=`r(mean)' - 0.5
	qui sum cog_stanine_q if cog_stanine==`i'
	local x`i'=`r(mean)' + 3
	di as result "Stanine `i': `s`i'' `x`i''"
}
* tweak stanine label positions:
local x9 = `x9' - 7
local s9 = `s9' +1
local sopts "size(*0.8) placement(east)"
*
replace PT_cog_sumscore=PT_cog_sumscore-0.5 // centering
sort cog_stanine_q
levelsof cog_stanine_q
twoway ///
	(scatter PT_earnings PT_cog_sumscore, ///
		msize(small) connect(l) msym(sh) color(gray%60) yaxis(1 2)) ///
	(scatter PT_earnings cog_stanine_q, ///
		msize(small) connect(l) msym(Sh) color(black%60) connect(.)), ///
scale(0.9) aspect(1) plotregion(margin(0 0 1 1)) ///
xtitle("Cognitive score (quantile)") ///	
ytitle("Earnings (percentile)", axis(1)) ytitle("", axis(2)) ///	
ylabel(30(10)70, axis(1)) ymticks(25(5)75, axis(1)) ///
ylabel(30(10)70, axis(2)) ymticks(25(5)75, axis(2)) /// 
yline(30(10)70, lcolor(gray%50) lwidth(thin) lpattern(dash)) /// 
xlabel(0(10)100)  /// 
legend(pos(6) rows(1) size(*.9) ///
		subtitle ("Average by", size(*0.7)) ///
		order(2 "Stanine" 1 "Percentile") ) ///
text(`s1' `x1' "1", `sopts') ///
text(`s2' `x2' "2", `sopts') ///
text(`s3' `x3' "3", `sopts') ///
text(`s4' `x4' "4", `sopts') ///
text(`s5' `x5' "5", `sopts') ///
text(`s6' `x6' "6", `sopts') ///
text(`s7' `x7' "7", `sopts') ///
text(`s8' `x8' "8", `sopts') ///
text(`s9' `x9' "9", `sopts')

graph export "$outDir/figures/figure-5.png", width(3200) replace	
	

* Figure 6 
* ======== 

use "$outDir/tables/alt_percentiles", clear

label list percentile_type
keep if percentile_type==1

replace sample="_"+sample
keep sample n* P
reshape wide n*, i(P) j(sample) string

foreach v of varlist n* {
	gen s_`v' = 100*`v'/n_full
}

replace P=P-0.5  // center plot point horizontally within percentile
*
twoway line s_n_full s_n_cog_full s_n_intermediate s_n_restricted P, ///
	title("Sample coverage", size(*.7)) ///
	color(black black red red) lpattern(shortdash solid shortdash solid) ///
	aspect(1) ///
	xlabel(0(10)100) xtitle("Earnings (percentile)",size(*.9)) ///
	ylabel(0(10)100) ytitle("% of full sample",size(*.9)) ///
	plotregion(margin(0 0 0 1)) ///
	legend(size(*0.55) pos(3) cols(1) ///
		order( 1 "Full sample" 2 "with cog.observed" 3 "Restricted sample" 4 "with cog. observed" ))

graph export "$outDir/figures/figure-6.png", width(3200) replace
		
		
* Figure 7 
* ========

use "$outDir/tables/alt_percentiles", clear

gen sample1 = (sample=="full" & percentile_type==5)
gen sample2 = (sample=="restricted" & percentile_type==8)
keep if sample1 | sample2

* 95% confidence intervals
gen ci_plus = cog_stanine_z + 1.96*se_cog_stanine_z
gen ci_minus = cog_stanine_z - 1.96*se_cog_stanine_z
format cog_stanine_z ci_* %2.1f

replace P=P-0.5  // center plot point horizontally within percentile
* Custom yaxis(2) labels: mapping from raw stanine to z-score
quiet reg cog_stanine_z cog_stanine  
di "This should be 1: " `e(r2)' 
local b = _b[cog_stanine]
local a = _b[_cons]
forvalues i = 4(1)7 { 
 local p`i' = `a'+`b'*`i'
}
*
twoway (rarea ci_plus ci_minus P if sample1, ///
		fcolor(black%20) lcolor(black%10) yaxis(1 2)) ///
	(rarea ci_plus ci_minus P if sample2, ///
		fcolor(red%20) lcolor(red%10)) 	///
	(scatter cog_stanine_z P if sample1, ///
		msize(tiny) connect(l) msym(Sh) color(black%60)) ///
	(scatter cog_stanine_z P if sample2, ///
		msize(tiny) connect(l) msym(Sh) color(red%60)), ///
scale(0.9) aspect(1) plotregion(margin(0 0 0 0)) ///
ytitle("Cognitive score (stanine)", axis(2)) ytitle("Cognitive score (standardized)", axis(1)) ///	
ylabel(-0.5(0.5)1.0, axis(1)) ymticks(-0.7(0.1)1.3, axis(1)) yscale(titlegap(2)) /// 
ylabel(`p4' "4" `p5' "5" `p6' "6" `p7' "7" , axis(2)) ///
yline(-0.5(0.5)1.0, lcolor(gray%50) lwidth(thin) lpattern(dash)) /// 
xtitle("Wage (percentile)", size(*0.9)) ///	
xlabel(0(10)100) xscale(titlegap(3)) ///
xline(10(10)90, lcolor(gray%50) lwidth(thin) lpattern(dash)) /// 
legend(pos(3) cols(1) order(3 "Full sample" 4 "Restricted sample")) 

graph export "$outDir/figures/figure-7.png", width(3200) replace


* Figure A1 
* =========

use "$outDir/tables/cog_vs_earnings", clear

gen ci_plus = cog_stanine_z + 1.96*se_cog_stanine_z
gen ci_minus = cog_stanine_z - 1.96*se_cog_stanine_z
format cog_stanine_z ci_* %2.1f

quiet reg cog_stanine_z cog_stanine  
di "This should be 1: " `e(r2)' 
local b = _b[cog_stanine]
local a = _b[_cons]
forvalues i = 4(1)7 { 
local p`i' = `a'+`b'*`i'
}
replace earnings=earnings/1000 
quietly sum earnings
local xmax = 25*floor(`r(max)'/25)+25
*
twoway (rcap ci_plus ci_minus earnings, color(black%60) yaxis(1 2)) ///
	(scatter cog_stanine_z earnings, msize(vsmall) msym(Sh) color(black%60) yaxis(1)), ///
scale(0.9)  aspect(1) plotregion(margin(0 1 0 1)) ///
ytitle("Cognitive score (stanine)", axis(2)) ytitle("Cognitive score (standardized)", axis(1)) ///	
ylabel(-0.5(0.5)1.0, axis(1)) ymticks(-0.7(0.1)1.3, axis(1)) /// 
ylabel(`p4' "4" `p5' "5" `p6' "6" `p7' "7" , axis(2)) yscale(titlegap(2)) ///
yline(-0.5(0.5)1.0, lcolor(gray%50) lwidth(thin) lpattern(dash)) /// 
xtitle("Earnings (€1000s/year)", size(*0.9)) ///	
xlabel(0(25)`xmax') /* xmticks(0(5)`xmax') xsc(titlegap(2)) */   ///
xline(0(25)`xmax', lcolor(gray%50) lwidth(thin) lpattern(dash)) /// 
legend(off) 

graph export "$outDir/figures/figure-a1.png", width(3200) replace


* Figure A2
* =========

use "$outDir/tables/earn_vs_cog", clear
append using "$outDir/tables/earn_vs_cog-percentiles"
drop if cog_stanine_q==. & PT_cog_sumscore==.

replace earnings = earnings/1000
forvalues i=1(1)9 {
	qui sum earnings if cog_stanine==`i'
	local s`i'=`r(mean)' - 1
	qui sum cog_stanine_q if cog_stanine==`i'
	local x`i'=`r(mean)' + 3
	di as result "Stanine `i': `s`i'' `x`i''"
}
* tweak stanine label positions:
local x9 = `x9' - 7
local s9 = `s9' +1
local sopts "size(*0.8) placement(east)"
*
replace PT_cog_sumscore=PT_cog_sumscore-0.5
levelsof cog_stanine_q
twoway ///
	(scatter earnings PT_cog_sumscore, ///
		msize(small) connect(l) msym(sh) color(gray%60) yaxis(1 2)) ///
	(scatter earnings cog_stanine_q, ///
		msize(small) connect(l) msym(Sh) color(black%60) connect(.)), ///
scale(0.9) aspect(1) plotregion(margin(0 0 1 2)) ///
xtitle("Cognitive score (quantile)") ///	
ytitle("Earnings (€1000s)", axis(1)) ytitle("", axis(2)) ///	
ymticks(20(10)70 72,tstyle(none)) ///
yline(20(10)70, lcolor(gray%50) lwidth(thin) lpattern(dash)) /// 
xlabel(0(10)100)  /// 
legend(pos(6) rows(1) size(*.9) ///
		subtitle ("Average by", size(*0.7)) ///
		order(2 "Stanine" 1 "Percentile") ) ///
text(`s1' `x1' "1", `sopts') ///
text(`s2' `x2' "2", `sopts') ///
text(`s3' `x3' "3", `sopts') ///
text(`s4' `x4' "4", `sopts') ///
text(`s5' `x5' "5", `sopts') ///
text(`s6' `x6' "6", `sopts') ///
text(`s7' `x7' "7", `sopts') ///
text(`s8' `x8' "8", `sopts') ///
text(`s9' `x9' "9", `sopts') 

graph export "$outDir/figures/figure-a2.png", width(3200) replace	


* =========
* Figure A3
* ==========	

use "$outDir/tables/stanshares_vs_earnings", clear

gen stan1to4 = 100*(stan1+stan2+stan3+stan4) 
gen stan5to9 = 100*(stan6+stan7+stan8+stan9) 
qui sum stan1to4
local cdf4 = `r(mean)'
qui sum stan5
local pdf5 = `r(sum)'
local s5above = (`cdf4'+`pdf5'-50)/`pdf5'
gen cog_stanine_abovemd = 100*(`s5above'*stan5 + stan6+stan7+stan8+stan9)
gen cog_stanine_belowmd = 100 - cog_stanine_abovemd
gen cog_stanine_asym = abs(cog_stanine_abovemd - cog_stanine_belowmd)
*
replace PT_earnings=PT_earnings-0.5
*
twoway ///
    (scatter cog_stanine_below  PT_earnings, ///
		msize(tiny) connect(l) msym(Sh) color(red%60) yaxis(1)) ///
    (scatter cog_stanine_above PT_earnings, ///
		msize(tiny) connect(l) msym(Oh) color(blue%60) yaxis(1)) ///
    (scatter cog_stanine_asym PT_earnings, ///
		msize(tiny) connect(l) msym(none) color(black%80) lpattern(shortdash) yaxis(2)), ///
    scale(0.9) aspect(1) plotregion(margin(0 0 0 0)) ///
    xtitle("Earnings (percentile)", size(*0.8)) ///
    ytitle("Share (%)", axis(1)) ///
    ytitle("", axis(2)) ///
    ylabel(0(20)100, axis(1)) yticks(0(10)100, axis(1)) ///
    ylabel(0(20)100, axis(2)) yticks(0(10)100, axis(2)) ///
    yline(0(20)100, lcolor(gray%50) lwidth(thin) lpattern(dash)) ///
    xlabel(0(10)100) xsc(titlegap(2)) ///
    xline(10(10)90, lcolor(gray%50) lwidth(thin) lpattern(dash)) ///
    legend(pos(3) cols(1) size(*1) ///
    subtitle("Cognitive ability", size(*1)) ///
    order(1 "Below median" 2 "Above median" 3 "Absolute difference"))
	

graph export "$outDir/figures/figure-a3.png", width(3200) replace


* =========
* Figure A4
* ==========	

* Left panel
* ----------

use "$outDir/tables/subscores_vs_earnings", clear
format arithmetic verbal visuospatial %2.1f

replace PT_earnings=PT_earnings-0.5
twoway ///
	(scatter visuospatial PT_earnings, ///
		msize(tiny) connect(l) msym(Sh) color(black%60) yaxis(1 2)) ///
	(scatter verbal PT_earnings, ///
		msize(tiny) connect(l) msym(Th) color(red%60)) ///
	(scatter arithmetic PT_earnings, ///
		msize(tiny) connect(l) msym(Oh) color(blue%60)), ///
	scale(0.9) aspect(1) plotregion(margin(0 0 1 1)) ///
	subtitle("Cognitive subscores") ///
	xtitle("Earnings (percentile)") ///
	xlabel(0(10)100) xsc(titlegap(2)) ///
	xline(10(10)90, lcolor(gray%50) lwidth(thin) lpattern(dash)) /// 
	ytitle("Standardized", axis(1)) ytitle("", axis(2)) ///
	ylabel(-0.5(0.5)1.5, axis(1)) ymticks(-0.5(0.1)1.5, axis(1)) /// 
	ylabel(-0.5(0.5)1.5, axis(2)) ymticks(-0.5(0.1)1.5, axis(2)) /// 
	yline(-0.5(0.5)1.5, lcolor(gray%20) lwidth(thin) lpattern(dash)) ///	
	legend(pos(0) bplacement(north) cols(1) size(*.9) ///
		order(1 "Visuospatial" 2 "Verbal" 3 "Arithmetic")) ///
		saving("$GPH/Subscores.gph", replace)
		
* Right panel
* -----------
		
use "$outDir/tables/altscores_vs_earnings", clear
format cog_linear noncog_linear combo_linear %2.1f
		
replace PT_earnings = PT_earnings-0.5
twoway ///
	(scatter cog_linear PT_earnings, ///
		msize(tiny) connect(l) msym(Sh) color(gray%60) yaxis(1 2)) ///
	(scatter noncog_linear PT_earnings, ///
		msize(tiny) connect(l) msym(Th) color(green%60)) ///
	(scatter combo_linear PT_earnings, ///
		msize(tiny) connect(l) msym(Oh) color(black%60)), ///
	scale(0.9) aspect(1) plotregion(margin(0 0 1 1)) ///
	subtitle("Anchored scores") ///	
	xtitle("Earnings (percentile)") ///
	xlabel(0(10)100) xsc(titlegap(2)) ///
	xline(10(10)90, lcolor(gray%50) lwidth(thin) lpattern(dash)) /// 
	ytitle(" ", axis(2)) ytitle("", axis(1)) ///
	ylabel(-0.5(0.5)1.5, axis(1)) ymticks(-0.5(0.1)1.5, axis(1)) /// 
	ylabel(-0.5(0.5)1.5, axis(2)) ymticks(-0.5(0.1)1.5, axis(2)) /// 
	yline(-0.5(0.5)1.5, lcolor(gray%20) lwidth(thin) lpattern(dash)) ///	
	legend(pos(0) bplacement(north) cols(1) size(*.9) ///
		order(2 "Non-cognitive" 1 "Cognitive"  3 "Combined")) ///
	saving("$GPH/Anchoreds.gph", replace) 
	
* Combine graph	
* -------------		

graph combine "$GPH/Subscores.gph" "$GPH/Anchoreds.gph", ycommon xcommon

graph export "$outDir/figures/figure-a4.png", width(3200) replace

