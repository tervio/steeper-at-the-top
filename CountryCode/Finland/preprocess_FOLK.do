* Gather 'demographic' data from FOLK tables
* INPUT
* $TKDATA/FOLK_perus_* // FOLK basic module 
* OUTPUT {keys}
* $AUX/person_static {shnro} 		
* $AUX/folk_years {shnro,vuosi}

macro list TKDATA TEMP AUX 
confirm file int_destring.do 


* Static from FOLK_perus 
* -----------------------

clear
save "$AUX/person_static", replace emptyok
foreach path in "$TKDATA/FOLK_perus_8800a/folk_19872000_tua_perus21tot_1" ///
				"$TKDATA/FOLK_perus_0110a/folk_20012010_tua_perus21tot_1" ///
				"$TKDATA/FOLK_perus_11a/folk_20112020_tua_perus21tot_1" {
	append using "`path'", keep(shnro vuosi syntyv sukup syntyp2)
	}
sum vuosi if !missing(syntyv,sukup,syntyp2)
label data "Unique individuals in FOLK 1987-`r(max)'" 
drop vuosi

gduplicates drop
gisid shnro

foreach varname of varlist sukup syntyp2 {  
	do int_destring `varname'			
	}
	
gduplicates drop shnro, force
sort syntyv shnro 
save "$AUX/person_static", replace


* Yearly from FOLK_perus 
* -----------------------

clear
save "$AUX/folk_years", replace emptyok
foreach path in "$TKDATA/FOLK_perus_8800a/folk_19872000_tua_perus21tot_1" ///
				"$TKDATA/FOLK_perus_0110a/folk_20012010_tua_perus21tot_1" ///
				"$TKDATA/FOLK_perus_11a/folk_20112020_tua_perus22tot_1" {
	append using "`path'", ///
		keep(shnro vuosi ptoim1 kunta)
	}
	
do int_destring ptoim1

do int_destring kunta

rename vuosi year
label var year "Year"
sort shnro year
order shnro year ptoim1
label data "Data from FOLK_perus"
save "$AUX/folk_years", replace  

clear
