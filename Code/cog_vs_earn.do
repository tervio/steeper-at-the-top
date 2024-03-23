* Cognitive ability plotted against earnings
* ==========================================

* 95% confidence interval
gen ci_plus = cog_stanine_z + 1.96*se_cog_stanine_z
gen ci_minus = cog_stanine_z - 1.96*se_cog_stanine_z
format cog_stanine_z ci_* %2.1f


* Cognitive ability by earnings percentile
* ----------------------------------------

foreach Country in "Finland" "Norway" {
preserve
keep if country=="`Country'" 
replace PT_earnings=PT_earnings-0.5  // center within percentile
* Custom yaxis(2) labels: mapping from raw stanine to z-score differs by country
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
title("`Country'") ///
scale(0.9) aspect(1) plotregion(margin(0 0 0 0)) ///
xtitle("Earnings (percentile)") ///	
xlabel(0(10)100) xscale(titlegap(3)) ///
xline(10(10)90, lcolor(gray%50) lwidth(thin) lpattern(dash)) /// 
ytitle("Cognitive score (standardized)", axis(1)) ytitle("Cognitive score (stanine)", axis(2)) ///	
ylabel(-0.5(0.5)1.0, axis(1)) ymticks(-0.7(0.1)1.3, axis(1)) /// 
ylabel(`p4' "4" `p5' "5" `p6' "6" `p7' "7" , axis(2)) yscale(titlegap(2)) ///
yline(-0.5(0.5)1.0, lcolor(gray%50) lwidth(thin) lpattern(dash)) /// 
legend(off) ///
saving("$tempDir/`Country'.gph", replace) nodraw
restore
}
*
grc1leg2 "$tempDir/Finland.gph" "$tempDir/Norway.gph",  ///
	xtob1title ytol1title y2tor1title imargin(small) loff

graph export "$figureDir/figure-2.pdf", replace
graph export "$figureDir/figure-2.jpg", quality(100) width(3200) replace


* Cognitive ability by earnings level
* ----------------------------------------

foreach Country in "Finland" "Norway" {
preserve
keep if country=="`Country'"
quiet reg cog_stanine_z cog_stanine  
di "This should be 1: " `e(r2)' //  R^2 = 100%
local b = _b[cog_stanine]
local a = _b[_cons]
forvalues i = 4(1)7 { 
 local p`i' = `a'+`b'*`i'
 }
replace earnings=earnings/1000 
quietly sum earnings
local xmax = 25*floor(`r(max)'/25)+25
*
twoway ///
	(rcap ci_plus ci_minus earnings, ///
		color(black%60) yaxis(1 2)) ///
	(scatter cog_stanine_z earnings, ///
		msize(vsmall) msym(Sh) color(black%60) yaxis(1)), ///
title("`Country'") ///
scale(0.9) aspect(1) plotregion(margin(0 1 0 1)) ///
xtitle("Earnings (€1000s/year)") ///	
xlabel(0(25)`xmax')  ///
xline(0(25)`xmax', lcolor(gray%50) lwidth(thin) lpattern(dash)) /// 
ytitle("Cognitive score (standardized)", axis(1)) ytitle("Cognitive score (stanine)", axis(2)) ///	
ylabel(-0.5(0.5)1.0, axis(1)) ymticks(-0.7(0.1)1.3, axis(1)) /// 
ylabel(`p4' "4" `p5' "5" `p6' "6" `p7' "7" , axis(2)) yscale(titlegap(2)) ///
yline(-0.5(0.5)1.0, lcolor(gray%50) lwidth(thin) lpattern(dash)) /// 
legend(off) ///
saving("$tempDir/`Country'.gph", replace) nodraw
restore
}

grc1leg2 "$tempDir/Finland.gph" "$tempDir/Norway.gph",  ///
	xtob1title ytol1title y2tor1title imargin(small) loff

graph export "$figureDir/figure-a1.pdf", replace
graph export "$figureDir/figure-a1.jpg",  quality(100) width(3200) replace
