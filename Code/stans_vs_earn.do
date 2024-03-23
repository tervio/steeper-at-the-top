* Cognitive ability share in extreme stanines, by earnings percentile
* --------------------------------------------------------------------

local i=1 // y-axis to label
local j=2 // y-axis to plain
foreach Country in "Finland" "Norway" {
preserve
keep if country=="`Country'"  
replace PT_earnings=PT_earnings-0.5 // centering
foreach v of varlist stan1 stan2 stan8 stan9 {
	replace `v' = 100*`v'
}
*
twoway ///
	(scatter stan1 PT_earnings , ///
		msize(vsmall) connect(l) msym(sh) color(red%60) yaxis(1 2)) ///
	(scatter stan2 PT_earnings, ///
		msize(vsmall) connect(l) msym(O) mfc(white) color(orange%60)) ///
	(scatter stan8 PT_earnings, ///
		msize(vsmall) connect(l) msym(O) mfc(white) color(gray%60)) ///
	(scatter stan9 PT_earnings, ///
		msize(vsmall) connect(l) msym(sh) color(black%60)), ///
title("`Country'") ///
scale(0.9) aspect(1) plotregion(margin(0 0 0 1)) ///
xtitle("Earnings (percentile)") ///	
xlabel(0(10)100) ///
xline(10(10)90, lcolor(gray%50) lwidth(thin) lpattern(dash)) /// 
ytitle("Share in stanine (%)", axis(1)) ytitle("", axis(2)) ///	
ylabel(0(5)30, axis(`i')) ymticks(1(1)29, axis(`i')) ///
ylabel(none, axis(`j')) ///
yline(0(5)30, lcolor(gray%50) lwidth(thin) lpattern(dash)) /// 
legend(rows(1) ///
	order(1 "Stanine 1" 2 "Stanine 2" 3 "Stanine 8" 4 "Stanine 9")) ///
saving("$tempDir/`Country'.gph", replace) nodraw
restore
local i = 2
local j = 1
}

grc1leg2 "$tempDir/Finland.gph" "$tempDir/Norway.gph",  ///
	xtob1title ytol1title y2tor1title imargin(medsmall) 

graph export "$figureDir/figure-3.pdf", replace
graph export "$figureDir/figure-3.jpg", quality(100) width(3200) replace
