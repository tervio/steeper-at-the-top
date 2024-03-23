/* Make graphs for Bratsberg-Rogeberg-Terviö 2023
Input:  .dta tables at ../Input/`country'/
Output: (pdf,jpg) graphs at ../Output/

Code for producing the input dta's is available separately for Fin & Nor. The individual-level data is confidential but can be accessed by researchers by obtaining a permit from the statistics authority in each country, and also from the FDF (Finnish Defense Forces) in the case of Finland. 
marko.tervio@aalto.fi 2023-10-26 
*/

* Dependencies
* ------------
cap net install grc1leg2.pkg 

* Global paths
* ============

* Input
* -----
global inputDir "../Input" 

* Output
* ------
global figureDir "../Output"
cap mkdir "$figureDir" 
global tempDir "../Temp" 
cap mkdir "$tempDir"


* Earnings at age 35-45 within-cohort percentile on horizontal axis
* =================================================================

* Figure 2. Cognitive ability by earnings percentile.
* Figure A1. Cognitive ability by level of earnings.

use "$inputDir/Finland/cog_vs_earnings", clear
gen country = "Finland"
append using "$inputDir/Norway/cog_vs_earnings"
replace country = "Norway" if country==""

do cog_vs_earn


* Figure 3. Cognitive ability shares for extreme stanines by earnings percentile 

use "$inputDir/Finland/stanshares_vs_earnings", clear
gen country = "Finland"
append using "$inputDir/Norway/stanshares_vs_earnings" 
replace country = "Norway" if country==""

do stans_vs_earn


* Figure 4. Standard deviation of cognitive scores by earnings percentile

use "$inputDir/Finland/cog-sd_vs_earn", clear
gen country = "Finland"
append using "$inputDir/Norway/cog-sd_vs_earn"
replace country = "Norway" if country==""

do stdev_vs_earn


* Cognitive skill on horizontal axis
* ==================================

* Figure 5. Earnings percentile by cognitive ability
* Figure A2. Earnings level by cognitive ability
* Figure 1. Histogram of cognitive ability (stanines)

use "$inputDir/Finland/earn_vs_cog", clear
append using "$inputDir/Finland/earn_vs_cog-percentiles"  
gen country = "Finland" 
append using "$inputDir/Norway/earn_vs_cog"
replace country = "Norway" if country==""

do earn_vs_cog


* Compare samples
* =================
* Full sample is native-born men 1962-75 who are observed throughout ages 35-45
* Restricted sample attempts to mimic the sample restrictions of Keuschnigg et al (2023)

* Figure 6. Data coverage (% of full balanced) by earnings percentile: Full vs Restricted sample

use "$inputDir/Finland/alt_percentiles", clear
gen country = "Finland"
append using "$inputDir/Norway/alt_percentiles"
replace country="Norway" if country==""

do coverage_multisample

* Figure 7. Cognitive ability by earnings percentile: Full vs Restricted sample

use "$inputDir/Finland/alt_percentiles", clear
gen country = "Finland"
append using "$inputDir/Norway/alt_percentiles"
replace country="Norway" if country==""

do cog_vs_earn_multisample


* Appendix
* ========

* Figure A3. Share of {below,above}-median ability scores by earnings percentile 

do mismatch

* Figure A4. Finland extras. Cognitive subscores, non-cognitive scores by earnings percentile

do finland_extras

* Figure A5. Norway extras. Cognitive ability by earnings percentile in birth cohorts 1950-61 

do norway_extras
