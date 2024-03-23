/* Gather, clean and label  FDF test data 
INPUT: 
	$CUSTDATA/Main/pkoe*  	FDF test data
	$CUSTDATA/Main/u0377_b_tutnroavain	TK id crosswalk for merging FDF with FOLK
OUTPUT: 
	$AUX/pkoe.dta 	person-level conscript test results (first take only - retakes discarded)	
*/

macro list CUSTDATA TEMP AUX
confirm file fdf_labels.do 


* FDF Test (Pkoe) Data
* =====================

* Gather FDF data from $CUSTDATA 

* P1 (cognitive test)
* -------------------
clear
save "$TEMP/pkoe1", replace emptyok
local dta_list : dir "$CUSTDATA/Main" files "pkoe1*.dta"
foreach dta in `dta_list' {
	use Tk_tutnro synaika suorituspvm kuv san las pluku using "$CUSTDATA/Main/`dta'"
	append using "$TEMP/pkoe1"
	save "$TEMP/pkoe1", replace 
	}
*
sort Tk_tutnro suorituspvm
missings dropobs kuv san las pluku, force
gduplicates  report Tk_tutnro
drop if Tk_tutnro=="" 			// mostly born pre-1962 or in 1996
gduplicates drop Tk_tutnro, force
rename suorituspvm pkoe1_suorituspvm
save "$TEMP/pkoe1", replace 

* P2 (non-cognitive test)
* -----------------------
clear
save "$TEMP/pkoe2", replace emptyok
local dta_list : dir "$CUSTDATA/Main" files "pkoe2*.dta"
foreach dta in `dta_list' {
	use "$CUSTDATA/Main/`dta'"
	keep Tk_tutnro synaika suorituspvm T1_? T2_? johted
	append using "$TEMP/pkoe2"
	save "$TEMP/pkoe2", replace 
	}
*
sort Tk_tutnro suorituspvm
missings dropobs T?_?, force
gduplicates report Tk_tutnro
drop if Tk_tutnro==""
gduplicates drop Tk_tutnro, force
rename suorituspvm pkoe2_suorituspvm
merge 1:1 Tk_tutnro using "$TEMP/pkoe1", nogen
sort Tk_tutnro


do fdf_labels   // make var labels AND remove crazy test score values
format pkoe?_suorituspvm synaika %tdCCYY-NN-DD // ISO Date format
merge 1:1 Tk_tutnro using "$CUSTDATA/Main/u0377_b_tutnroavain", keep(1 3) nogen // id crosswalk

cap rm "$TEMP/pkoe1.dta"
cap rm "$TEMP/pkoe2.dta"

* P2 observed for one (sic) person born in 1980, get rid of it to make life simpler
foreach v of varlist T?_? johted pkoe2 {
	replace `v'=. if year(synaika)==1980
}

rename uusi_tutnro shnro
order shnro 
label var shnro "ID"
compress
sort shnro
gisid shnro
label data "Raw FDF test scores"
save "$AUX/pkoe", replace

clear
