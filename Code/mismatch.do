* Plot the shares above/below selected (interpolated) quantiles
* -------------------------------------------------------------

local i=1 // y-axis to label
local j=2 // y-axis to plain
foreach country in "Finland" "Norway" {
use "$inputDir/`country'/stanshares_vs_earnings", clear
* calculate share of stanine 5 above population median by assuming that latent score uniformly distributed within stanine?
gen stan1to4 = 100*(stan1+stan2+stan3+stan4) 
qui sum stan1to4
local cdf4 = `r(mean)'
qui sum stan5
local pdf5 = `r(sum)'
local s5above = (`cdf4'+`pdf5'-50)/`pdf5'
gen cog_stanine_abovemd = 100*(`s5above'*stan5 + stan6+stan7+stan8+stan9)
gen cog_stanine_belowmd = 100 - cog_stanine_abovemd
gen cog_stanine_asym = abs(cog_stanine_abovemd - cog_stanine_belowmd)
replace PT_earnings=PT_earnings-0.5 // centering
*
twoway ///
    (scatter cog_stanine_below PT_earnings, ///
        msize(tiny) connect(l) msym(Sh) color(red%60) yaxis(1)) ///
    (scatter cog_stanine_above PT_earnings, ///
        msize(tiny) connect(l) msym(Oh) color(blue%60) yaxis(1)) ///
    (scatter cog_stanine_asym PT_earnings, ///
        msize(tiny) connect(l) msym(none) color(black%80) lpattern(shortdash) yaxis(2)), ///
    scale(0.9) aspect(1) plotregion(margin(0 0 0 0)) ///
	title("`country'") ///
    xtitle("Earnings (percentile)") ///
    xlabel(0(10)100) ///
    xline(10(10)90, lcolor(gray%50) lwidth(thin) lpattern(dash)) ///
    ytitle("Share (%)", axis(`i')) ///
    ytitle("", axis(`j')) ///
    ylabel(0(20)100, axis(`i')) yticks(0(10)100, axis(`i')) ///
    ylabel(none, axis(`j')) yticks(0(10)100, axis(`j')) ///
    yline(0(20)100, lcolor(gray%50) lwidth(thin) lpattern(dash)) ///
    legend(pos(6) rows(1) ///
    subtitle("Cognitive ability", size(*.8)) ///
    order(1 "Below median" 2 "Above median" 3 "Absolute difference")) ///
	saving("$tempDir/`country'.gph", replace) nodraw
local i = 2
local j = 1	
}

grc1leg2 "$tempDir/Finland.gph" "$tempDir/Norway.gph",  ///
	xtob1title ytol1title y2tor1title imargin(small) 

graph export "$figureDir/figure-a3.pdf", replace
graph export "$figureDir/figure-a3.jpg", quality(100) width(3200) replace
