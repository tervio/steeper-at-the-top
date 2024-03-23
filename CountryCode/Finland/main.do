* Analyze the shape of ability-earnings relation
/* Finnish half of data analysis for Bratsberg-Rogeberg-Terviö (2023)  
 "Steeper at the top: cognitive ability and earnings in Finland and Norway"  

 Assumes *.do files in present working directory
 Paths at TK (Tilastokeskus = "Statistics Finland" aka StatFin) remote servers
 
 This (final !) version 2024-03-06 
 `c(username)' MarTervio-a72
*/

* Global PATHS
* ============ 

* BEGIN Repository version only:
* Hardcode global paths from user profile; values as of 2024-03-06
global TKDATA "D:/ready-made"
global CUSTDATA "D:/a72/custom-made"
global WORK "W:/marko"
global OUT "O:/marko"
* END Repository version-only

* INPUT:
macro list TKDATA CUSTDATA  // read-only drives at TK
global TULODATA "$TKDATA/CONTINUOUS/FOLK_TULO_C" // TK income module

* OUTPUT: 
macro list WORK  // writable drive for intermediate files at TK, from user profile
macro list OUT // output drive for taking files out of TK, from user profile 
global AUX "W:/auxiliary" // preprocessed data, shared between papers
global TEMP "$WORK/steeper"   // temporary files
global GPH "$TEMP/gph" // Stata graphs to combine

global outDir "$OUT/takeout" // Output
cap mkdir "$outDir"
cap mkdir "$outDir/tables"
cap mkdir "$outDir/figures"
cap mkdir "$outDir/code"
cap mkdir "$TEMP"
cap mkdir "$GPH"

* Deflator settings
* -----------------
global cpiBaseYear = 2020
global Deflator "$AUX/cpi_deflator.dta"
confirm file "$Deflator" // dta extracted from StatFin metadata by cpi_deflator.do

* Helpers
* -------
confirm file int_destring.do // speed up destring
confirm file fdf_labels.do // for cleaning and labeling variables in FDF data
*confirm file cpi_deflator.do // update dta-format deflator


* Preprocess 
* ==========

* Statistics Finland registry data
* --------------------------------
do preprocess_FOLK
desc using "$AUX/person_static"
desc using "$AUX/folk_years"

do preprocess_TULO 
desc using "$AUX/earn_years"

* Military test score data
* ------------------------
do preprocess_FDF
desc using "$AUX/pkoe"


* Gather data for "Steeper at the top"
* ====================================

* From panel to static variables 
* ------------------------------
do collapse_males
desc using "$TEMP/male_static"

* Anchored test scores
* --------------------
do dimreduce_FDF
desc using "$TEMP/skill_measures"


* Analysis data
* ==============

do define_subsets
desc using "$TEMP/subsets"

do analysis_samples
ls "$TEMP/sample_*"
desc using "$TEMP/sample_full"
desc using "$TEMP/sample_intermediate"
desc using "$TEMP/sample_restricted"


* Summarize data 
* ==============

do summary_stats  
ls "$outDir/tables/*.xlsx"


* ==============================================
* Takeout tables - all graphs are based on these
* ==============================================

* Prepare dta's for graphs with earnings on horizontal axis
do stats_vs_earn 
desc using "$outDir/tables/cog_vs_earnings"
desc using "$outDir/tables/stanshares_vs_earnings"
desc using "$outDir/tables/cog-sd_vs_earn"
desc using "$outDir/tables/subscores_vs_earnings"
desc using "$outDir/tables/altscores_vs_earnings"

* Prepare dta's for graphs with FDF test results on horizontal axis 
do stats_vs_cog  
desc using "$outDir/tables/earn_vs_cog"
desc using "$outDir/tables/earn_vs_cog-percentiles"

* Prepare the dta for comparisons with Keuschnigg et al (2023)
do compare_variants 
desc using "$outDir/tables/alt_percentiles"


* ==========================
* Optional preview of graphs
* ==========================

do preview_graphs
ls "$outDir/figures/*.png"


* ==========================
* Copy codes to takeout dir
* ==========================

* code shared with other a72 projects
foreach fname in "preprocess_FOLK" "preprocess_TULO" "preprocess_FDF" "dimreduce_FDF" "fdf_labels" "int_destring" "cpi_deflator" {
	copy "`fname'.do" "$outDir/code/`fname'.do", replace
	}

* code specific to Bratsberg-Rogeberg-Terviö (2023)	
foreach fname in "main"  "collapse_males" "define_subsets" "analysis_samples" "summary_stats" "stats_vs_earn" "stats_vs_cog" "compare_variants" "preview_graphs" {
	copy "`fname'.do" "$outDir/code/`fname'.do", replace
	}
	
ls "$outDir/code/"
clear
