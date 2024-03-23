* Figures by cognitive ability, aka the "non-flipped" figures
* ===========================================================

* Graphs for Finland and Norway are substantially different, because raw cognitive scores are not available in Norway.


* Quantiles-on-Quantiles
* ----------------------

* Finland

preserve
keep if country=="Finland"
forvalues i=1(1)9 {
	qui sum PT_earnings if cog_stanine==`i'
	local s`i'=`r(mean)' - 0.5
	qui sum cog_stanine_q if cog_stanine==`i'
	local x`i'=`r(mean)' + 3
	di as result "Stanine `i': `s`i'' `x`i''"
}
local x9 = `x9' - 7
local s9 = `s9' + 1
*
local sopts "size(*0.8) placement(east)"
replace PT_cog_sumscore=PT_cog_sumscore-0.5 // centering
sort cog_stanine_q
drop if cog_stanine_q==. & PT_cog_sumscore==.
twoway 	///
	(scatter PT_earnings PT_cog_sumscore, ///
		msize(small) connect(l) msym(sh) color(gray%80) yaxis(1 2)) ///
	(scatter PT_earnings cog_stanine_q, ///
		msize(small) connect(.) msym(Sh) color(black%80)), ///
title("Finland") ///
scale(0.9) aspect(1) plotregion(margin(0 0 1 1)) ///
xtitle("Cognitive score (quantile)") ///	
xlabel(0(10)100)  /// 
ytitle("Earnings (percentile)", axis(1)) ytitle("", axis(2)) ///	
ylabel(30(10)70, axis(1)) ymticks(25(5)75, axis(1)) ///
ylabel(none, axis(2)) ymticks(25(5)75, axis(2)) /// 
yline(30(10)70, lcolor(gray%50) lwidth(thin) lpattern(dash)) /// 
legend(rows(1) size(*.9) subtitle ("Average by", size(*0.7)) ///
		order(2 "Stanine" 1 "Percentile") ) ///
text(`s1' `x1' "1", `sopts') ///
text(`s2' `x2' "2", `sopts') ///
text(`s3' `x3' "3", `sopts') ///
text(`s4' `x4' "4", `sopts') ///
text(`s5' `x5' "5", `sopts') ///
text(`s6' `x6' "6", `sopts') ///
text(`s7' `x7' "7", `sopts') ///
text(`s8' `x8' "8", `sopts') ///
text(`s9' `x9' "9", `sopts') ///
saving("$tempDir/Finland.gph", replace) nodraw				
restore


* Norway  

preserve
keep if country=="Norway"
forvalues i=1(1)9 {
	qui sum PT_earnings if cog_stanine==`i'
	local s`i'=`r(mean)' - 0.5
	qui sum cog_stanine_q if cog_stanine==`i'
	local x`i'=`r(mean)' + 3
	di as result "Stanine `i': `s`i'' `x`i''"
}
local x9 = `x9' - 7
local s9 = `s9' + 1
*
local sopts "size(*0.8) placement(east)"
sort cog_stanine_q
drop if cog_stanine_q==. 
twoway 	(scatter PT_earnings cog_stanine_q, yaxis(1 2) ///
	msize(small) connect(.) msym(Sh) color(black%80)), ///
title("Norway") ///
scale(0.9)  aspect(1) plotregion(margin(0 0 1 1)) ///
xtitle("Cognitive score (quantile)") ///	
xlabel(0(10)100)  /// 
ytitle("Earnings (percentile)", axis(1)) ytitle("", axis(2)) ///	
ylabel(none, axis(1)) ymticks(25(5)75, axis(1)) ///
ylabel(30(10)70, axis(2)) ymticks(25(5)75, axis(2)) /// 
yline(30(10)70, lcolor(gray%50) lwidth(thin) lpattern(dash)) /// 
legend(off) ///
text(`s1' `x1' "1", `sopts') ///
text(`s2' `x2' "2", `sopts') ///
text(`s3' `x3' "3", `sopts') ///
text(`s4' `x4' "4", `sopts') ///
text(`s5' `x5' "5", `sopts') ///
text(`s6' `x6' "6", `sopts') ///
text(`s7' `x7' "7", `sopts') ///
text(`s8' `x8' "8", `sopts') ///
text(`s9' `x9' "9", `sopts') ///
saving("$tempDir/Norway.gph", replace) nodraw				
restore


* Combine Fin & Nor

grc1leg2 "$tempDir/Finland.gph" "$tempDir/Norway.gph",  ///
	xtob1title ytol1title y2tor1title imargin(small) 

graph export "$figureDir/figure-5.pdf", replace
graph export "$figureDir/figure-5.jpg", quality(100) width(3200) replace



* Levels-on-Quantiles 
* -------------------

* Finland

preserve
keep if country=="Finland"
replace earnings = earnings/1000
forvalues i=1(1)9 {
	qui sum earnings if cog_stanine==`i'
	local s`i'=`r(mean)' - 1
	qui sum cog_stanine_q if cog_stanine==`i'
	local x`i'=`r(mean)' + 3
	di as result "Stanine `i': `s`i'' `x`i''"
}
local x9 = `x9' - 7
local s9 = `s9' +1
*
local sopts "size(*0.8) placement(east)"
replace PT_cog_sumscore = PT_cog_sumscore-0.5 // centering
sort cog_stanine_q
drop if cog_stanine_q==. & PT_cog_sumscore==.
twoway 	///
	(scatter earnings PT_cog_sumscore, ///
		msize(small) connect(l) msym(sh) color(gray%80) yaxis(1 2)) ///
	(scatter earnings cog_stanine_q, ///
		msize(small) connect(.) msym(Sh) color(black%80)), ///
title("Finland") ///
scale(0.9)  aspect(1) plotregion(margin(0 0 1 2)) ///
xtitle("Cognitive score (quantile)") ///	
xlabel(0(10)100) /// 
ytitle("Earnings (€1000s)", axis(1)) ytitle("", axis(2)) ///	
ymticks(20(10)70 72,tstyle(none)) ///
yline(20(10)70, lcolor(gray%50) lwidth(thin) lpattern(dash)) /// 
legend(rows(1) size(*.9) subtitle ("Average by", size(*0.7)) ///
		order(2 "Stanine" 1 "Percentile") ) ///
text(`s1' `x1' "1", `sopts') ///
text(`s2' `x2' "2", `sopts') ///
text(`s3' `x3' "3", `sopts') ///
text(`s4' `x4' "4", `sopts') ///
text(`s5' `x5' "5", `sopts') ///
text(`s6' `x6' "6", `sopts') ///
text(`s7' `x7' "7", `sopts') ///
text(`s8' `x8' "8", `sopts') ///
text(`s9' `x9' "9", `sopts') ///
saving("$tempDir/Finland.gph", replace) nodraw				
restore

* Norway

preserve
keep if country=="Norway"
replace earnings = earnings/1000
forvalues i=1(1)9 {
	qui sum earnings if cog_stanine==`i'
	local s`i'=`r(mean)' - 1
	qui sum cog_stanine_q if cog_stanine==`i'
	local x`i'=`r(mean)' + 3
	di as result "Stanine `i': `s`i'' `x`i''"
}
local x9 = `x9' - 7
local s9 = `s9' +1
*
local sopts "size(*0.8) placement(east)"
sort cog_stanine_q
drop if cog_stanine_q==. 
twoway 	(scatter earnings cog_stanine_q, yaxis(1 2) ///
	msize(small) connect(.) msym(Sh) color(black%80)), ///
title("Norway") ///
scale(0.9) aspect(1) plotregion(margin(0 0 1 2)) ///
xtitle("Cognitive score (quantile)") ///	
xlabel(0(10)100) /// 
ytitle("Earnings (€1000s)", axis(1)) ytitle("", axis(2)) ///	
ymticks(30(10)80 82, tstyle(none)) ///
yline(30(10)80, lcolor(gray%50) lwidth(thin) lpattern(dash)) /// 
legend(off) ///
text(`s1' `x1' "1", `sopts') ///
text(`s2' `x2' "2", `sopts') ///
text(`s3' `x3' "3", `sopts') ///
text(`s4' `x4' "4", `sopts') ///
text(`s5' `x5' "5", `sopts') ///
text(`s6' `x6' "6", `sopts') ///
text(`s7' `x7' "7", `sopts') ///
text(`s8' `x8' "8", `sopts') ///
text(`s9' `x9' "9", `sopts') ///
saving("$tempDir/Norway.gph", replace) nodraw				
restore


* Combine Fin & Nor

grc1leg2 "$tempDir/Finland.gph" "$tempDir/Norway.gph",  ///
	xtob1title ytol1title y2tor1title imargin(medsmall) 

graph export "$figureDir/figure-a2.pdf", replace
graph export "$figureDir/figure-a2.jpg", quality(100) width(3200) replace



* Histogram of cognitive test result stanines
* -------------------------------------------

* Finland
preserve
keep if country=="Finland" & cog_stanine_q!=.
histogram cog_stanine [fw=n], percent disc  ///
	title("Finland") ///
	aspect(1) ///
	fcolor(gray%50) lcolor(black) lwidth(thin) ///
	xlabel(1(1)9) xtitle("Stanine") ///
saving("$tempDir/Finland.gph", replace) nodraw		
restore

* Norway
preserve
keep if country=="Norway"
histogram cog_stanine [fw=n], percent disc  ///
	title("Norway") ///
	aspect(1) ///
	fcolor(gray%50) lcolor(black) lwidth(thin) ///
	xlabel(1(1)9) xtitle("Stanine") ///
saving("$tempDir/Norway.gph", replace) nodraw	
restore

* Combine Fin & Nor
graph combine "$tempDir/Finland.gph" "$tempDir/Norway.gph", xcommon ycommon

graph export "$figureDir/figure-1.pdf", replace
graph export "$figureDir/figure-1.jpg", quality(100) width(3200) replace
