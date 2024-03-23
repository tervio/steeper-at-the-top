* Norway: ability-earnings relation for pre-1950s birth cohorts
* -------------------------------------------------------------

foreach dname in "3545" "4555" {
use "$inputDir/Norway/cog_vs_earn`dname'_1950s", clear
if "`dname'"=="3545" local toptitle="Age 35-45"
if "`dname'"=="4555" local toptitle="Age 45-55"	
* 95% confidence interval
gen ci_plus = cog_stanine_z + 1.96*se_cog_stanine_z
gen ci_minus = cog_stanine_z - 1.96*se_cog_stanine_z
format ci_* %2.1f
replace PT_earnings=PT_earnings-0.5  // center within percentile
* Custom yaxis(2) labels: mapping from raw stanine to z-score differs by country
quiet reg cog_stanine_z cog_stanine  
di "This should be 1: " `e(r2)' //  R^2 = 100%
local b = _b[cog_stanine]
local a = _b[_cons]
forvalues i = 4(1)8 { 
 local p`i' = `a'+`b'*`i'
 }
*
twoway ///
	(rarea ci_plus ci_minus PT_earnings, ///
		fcolor(black%20) lcolor(black%10) yaxis(1 2)) ///
	(scatter cog_stanine_z PT_earnings, ///
		msize(tiny) connect(l) msym(Sh) color(black%60) yaxis(1)), ///
title("`toptitle'") ///
scale(0.9) aspect(1) plotregion(margin(0 0 1 1)) ///
ytitle("Cognitive score (standardized)", axis(1)) ytitle("Cognitive score (stanine)", axis(2)) ///	
ylabel(-0.5(0.5)1.0, axis(1)) ymticks(-0.7(0.1)1.3, axis(1)) /// 
ylabel(`p4' "4"  `p5' "5" `p6' "6" `p7' "7" , axis(2)) yscale(titlegap(2)) ///
yline(-0.5(0.5)1.0, lcolor(gray%50) lwidth(thin) lpattern(dash)) /// 
xtitle("Earnings (percentile)") xscale(titlegap(1)) ///	
xlabel(0(10)100) ///
xline(10(10)90, lcolor(gray%50) lwidth(thin) lpattern(dash)) /// 
legend(off) ///
saving("$tempDir/Norway_`dname'.gph", replace) nodraw
}

grc1leg2 "$tempDir/Norway_3545.gph" "$tempDir/Norway_4555.gph",  ///
	xtob1title ytol1title y2tor1title imargin(small) loff
	
graph export "$figureDir/figure-a5.pdf", replace
graph export "$figureDir/figure-a5.jpg", quality(100) width(3200) replace
