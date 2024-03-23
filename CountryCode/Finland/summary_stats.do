* Progressive drops table: sample size and average cogscore in samples
* INPUT:
confirm file "$TEMP/sample_full.dta"
confirm file "$TEMP/sample_restricted.dta"
* OUTPUT:
*  $outDir/tables/


use "$TEMP/sample_full", clear

tabstat earnings cog_stanine* cog_sumscore*, stat(mean sd p50 n) columns(stat) save
putexcel set "$outDir/tables/summary_stats", replace
putexcel A1=matrix(r(StatTotal)), names 
putexcel save

corr arithmetic verbal visuospatial cog_sumscore *_linear
putexcel set "$outDir/tables/subscore_correlations", replace
putexcel A1=matrix(r(C)), names colwise
putexcel save


use "$TEMP/sample_restricted", clear

tabstat earnings wage cog_stanine*, stat(mean sd p50 n) columns(stat) save
putexcel set "$outDir/tables/summary_stats_restricted", replace
putexcel A1=matrix(r(StatTotal)), names colwise
putexcel save
