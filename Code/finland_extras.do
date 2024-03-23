* Extra Figure for Finland, using more detailed test results 
* ==========================================================

* Standardized version: cog subscores
* -----------------------------------

use "$inputDir/Finland/subscores_vs_earnings", clear

format visuospatial verbal arithmetic %2.1f

replace PT_earnings=PT_earnings-0.5 // centering
twoway ///
	(scatter visuospatial PT_earnings,  yaxis(1 2) ///
		msize(tiny) connect(l) msym(Sh) color(black%60)) ///
	(scatter verbal PT_earnings, ///
		msize(tiny) connect(l) msym(Th) color(red%60)) ///
	(scatter arithmetic PT_earnings, ///
		msize(tiny) connect(l) msym(Oh) color(blue%60)), ///
	scale(0.9) aspect(1) plotregion(margin(0 0 1 1)) ///
	title("Cognitive subscores") ///
	xtitle("") ///	
	xlabel(0(10)100) ///
	xline(10(10)90, lcolor(gray%50) lwidth(thin) lpattern(dash)) /// 
	ytitle("", axis(1)) ytitle(" ", axis(2)) ///
	ylabel(-0.5(0.5)1.5, axis(1)) ymticks(-0.5(0.1)1.5, axis(1)) /// 
	ylabel(none, axis(2)) yticks(-0.5(0.5)1.5, axis(2))  ymticks(-0.5(0.1)1.5, axis(2)) ///
	yline(-0.5(0.5)1.5, lcolor(gray%20) lwidth(thin) lpattern(dash)) ///	
	legend(pos(0) bplacement(north) cols(1)  ///
		order(1 "Visuospatial" 2 "Verbal" 3 "Arithmetic")) ///
	saving("$tempDir/Subscores.gph", replace) nodraw


* Standardized version : cog and non-cog
* -------------------

use "$inputDir/Finland/altscores_vs_earnings", clear

format cog_linear noncog_linear combo_linear %2.1f

replace PT_earnings=PT_earnings-0.5 // centering
twoway ///
	(scatter cog_linear PT_earnings, ///
		msize(tiny) connect(l) msym(Sh) color(gray%60) yaxis(1 2)) ///
	(scatter noncog_linear PT_earnings, ///
		msize(tiny) connect(l) msym(Th) color(green%60)) ///
	(scatter combo_linear PT_earnings, ///
		msize(tiny) connect(l) msym(Oh) color(black%60)), ///
	scale(0.9) aspect(1) plotregion(margin(0 0 1 1)) ///
	title("Anchored scores") ///	
	xtitle("") ///	
	xlabel(0(10)100) ///
	xline(10(10)90, lcolor(gray%50) lwidth(thin) lpattern(dash)) /// 
	ytitle("", axis(1)) ytitle(" ", axis(2)) ///
	ylabel(none, axis(1)) yticks(-0.5(0.5)1.5, axis(1)) ymticks(-0.5(0.1)1.5, axis(1)) /// 
	ylabel(-0.5(0.5)1.5, axis(2)) ymticks(-0.5(0.1)1.5, axis(2)) /// 
	yline(-0.5(0.5)1.5, lcolor(gray%20) lwidth(thin) lpattern(dash)) ///	
	legend(pos(0) bplacement(north) cols(1) ///
		order(1 "Cognitive" 2 "Non-cognitive"  3 "Combined")) ///
	saving("$tempDir/CogNoncog.gph", replace) nodraw

* Combine graphs
* --------------

graph combine "$tempDir/Subscores.gph" "$tempDir/CogNoncog.gph", xcommon ycommon ///
	imargin(0) b1title("Earnings (percentile)", size(*.9)) l2title("Standardized score")

/* grc1leg2 loses overlay legends
grc1leg2  "$tempDir/Subscores.gph" "$tempDir/CogNoncog.gph",  ///
	b1title("Earnings (percentile)", size(*.9)) l1title("Standardized score", size(*.9)) imargin(small) loff
*/
	
graph export "$figureDir/figure-a4.pdf", replace
graph export "$figureDir/figure-a4.jpg", quality(100) width(3200) replace
