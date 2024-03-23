* Standard deviation of cognitive scores by earnings percentile 
* -------------------------------------------------------------

format sd_cog_stanine_z  %2.1f

local i=1 // y-axis to label
local j=2 // y-axis to plain
foreach Country in "Finland" "Norway" {
preserve
keep if country=="`Country'" 
replace PT_earnings=PT_earnings-0.5 // centering
twoway (scatter sd_cog_stanine_z PT_earnings, ///
        yaxis(1 2) msize(vsmall) msym(sh) connect(l) lwidth(medthick) color(black%60)), ///
 title("`Country'") ///
 scale(0.9) aspect(1) plotregion(margin(0 0 2 1)) ///
 xtitle("Earnings (percentile)") ///	
 xlabel(0(10)100) ///
 xline(10(10)90, lcolor(gray%50) lwidth(thin) lpattern(dash)) /// 
 ytitle("Standard Deviation of Cognitive Scores", axis(1) size(*0.9)) ytitle("", axis(2)) ///	
 ylabel(0.7(0.1)1.1, axis(`i')) ymticks(0.7(0.1)1.1, axis(`j')) ///
 ylabel(none, axis(`j')) ///
 yline(0.7(0.1)1.1, lcolor(gray%50) lwidth(thin) lpattern(dash)) /// 
 legend(off) ///
 saving("$tempDir/`Country'.gph", replace) nodraw
restore
local i = 2
local j = 1
}
*

grc1leg2 "$tempDir/Finland.gph" "$tempDir/Norway.gph",  ///
	xtob1title ytol1title y2tor1title imargin(medsmall) loff

graph export  "$figureDir/figure-4.pdf", replace
graph export  "$figureDir/figure-4.jpg", quality(100) width(3200) replace
