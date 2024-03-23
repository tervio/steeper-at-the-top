* Compare ability-earnings relation in different samples
* ------------------------------------------------------

foreach Country in "Finland" "Norway" {
preserve
keep if country=="`Country'" & P!=. 
gen sample1 = (sample=="full" & percentile_type==5) // 5 Wage percentile (within full sample cohort)
gen sample2 = (sample=="restricted" & percentile_type==8) // 8 Wage percentile (within restricted sample)
keep if (sample1 | sample2)

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
twoway ///
	(rarea ci_plus ci_minus P if sample1, ///
		fcolor(black%20) lcolor(black%10) yaxis(1 2)) ///
	(rarea ci_plus ci_minus P if sample2, ///
		fcolor(red%20) lcolor(red%10)) 	///
	(scatter cog_stanine_z P if sample1, ///
		msize(tiny) connect(l) msym(Sh) color(black%60)) ///
	(scatter cog_stanine_z P if sample2, ///
		msize(tiny) connect(l) msym(Sh) color(red%60)), ///
title("`Country'") ///
scale(0.9) aspect(1) plotregion(margin(0 0 0 0)) ///
ytitle("Cognitive score (standardized)", axis(1)) ytitle("Cognitive score (stanine)", axis(2)) ///	
ylabel(-0.5(0.5)1.0, axis(1)) ymticks(-0.7(0.1)1.3, axis(1)) yscale(titlegap(2)) /// 
ylabel(`p4' "4" `p5' "5" `p6' "6" `p7' "7" , axis(2)) ///
yline(-0.5(0.5)1.0, lcolor(gray%50) lwidth(thin) lpattern(dash)) /// 
xtitle("Wage (percentile)") ///	
xlabel(0(10)100) xscale(titlegap(3)) ///
xline(10(10)90, lcolor(gray%50) lwidth(thin) lpattern(dash)) /// 
legend(rows(1) order(3 "Full sample" 4 "Restricted sample")) ///
saving("$tempDir/`Country'.gph", replace) nodraw
restore
}

grc1leg2 "$tempDir/Finland.gph" "$tempDir/Norway.gph",  ///
	xtob1title ytol1title y2tor1title imargin(small) 

graph export "$figureDir/figure-7.pdf", replace
graph export "$figureDir/figure-7.jpg", quality(100) width(3200) replace
