* Gather and merge income data, deflate, round to whole euros to save memory
* INPUT:
* $TULODATA/.dta  // FOLK incomes module
* OUTPUT:
* $TEMP/tulo_years.dta  // person-year panel of income variables
* $AUX/earn_years.dta // selected variables panel, english labeling
* $AUX/male_static.dta // person table, income variables over age ranges

macro list TULODATA TEMP AUX cpiBaseYear Deflator

* Gather income data
* ------------------
clear 
save "$TEMP/tulo_years", replace emptyok

filelist, dir("$TULODATA") pattern("folk_tulo_*.dta")
levelsof filename
foreach fname in `r(levels)' {
	ls "$TULODATA/`fname'"
	use shnro vuosi palk tyotu yrtu tyrtuo svatv svatva kturaha omtu svatvp using "$TULODATA/`fname'", clear
	foreach v of varlist * { 
	    di "`v'"
	    cap confirm numeric variable `v'
		if _rc==0  replace `v' = round(`v')  // round off cents
	}
	compress
	append using "$TEMP/tulo_years"
	save "$TEMP/tulo_years", replace
}


* Apply CPI deflator
* ------------------

rename vuosi year
merge m:1 year using "$Deflator", keepusing(cpi_deflator) nogen  

sum cpi_deflator if year==$cpiBaseYear 
local cpi_Base = `r(mean)'
foreach v of varlist _all {
    cap confirm numeric variable `v'
		if _rc==0 & "`v'"!="year" {
		replace `v' = round(`v'*(`cpi_Base'*cpi_deflator)) 
		}
	}
drop cpi_deflator 
drop if missing(shnro)

sort year shnro
gisid year shnro
label data "Deflated to $cpiBaseYear euros using CPI deflator."
compress 
save "$TEMP/tulo_years", replace 


* Combine wage and enterpreneurial earnings into earnings  
* -------------------------------------------------------
* noting TK variable reforms 1995, 1993

gen wage = palk 
replace wage = tyotu if year < 1995   
gen earnings = palk + yrtu
replace earnings = tyotu + tyrtuo if year < 1995
label var wage "Wage earnings"
label var earnings "Earnings"
drop palk yrtu tyotu tyrtuo

rename kturaha disposable_income 
rename svatv taxable_earnings
replace taxable_earnings=svatva if year>=1993

rename omtu property_income
rename svatvp capital_income
drop svatv* 

label var taxable_earnings "Taxable earnings"
label var disposable_income "Disposable income"
label var property_income "Property income"
label var capital_income "Capital income"
label var year "Year"

merge 1:1 shnro year using "$AUX/folk_years", keepusing(ptoim1) nogen 
label var ptoim1 "Main activity"

cap recast long *earnings *income *wage 
sort shnro year
order shnro year 
compress
label data "Earnings in $cpiBaseYear euros"
save "$AUX/earn_years", replace  

clear
