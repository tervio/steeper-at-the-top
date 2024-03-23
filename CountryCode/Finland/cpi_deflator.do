/* 
Convert TK consumer price index based value of money-multiplier from .xlsx to .dta
Account for the 2002 currency change (since all incomes in $TKDATA already converted to nominal euros using the fixed rate)
 
The yearly deflator series is part of StatFin read-only "metadata" at: 
*/

import excel "D:/metadata/classifications/deflators/rahanarvonkerroin_1860-2021.xlsx", clear
drop in 1/7
rename A year
rename B cpi_deflator_raw
drop C
destring year, replace
destring cpi_deflator_raw, replace
drop if year==.
keep if year>=1963

gen cpi_deflator = cpi_deflator_raw
replace cpi_deflator=cpi_deflator_raw*5.94573 if year<2002 // switch to Euro

sort year
gisid year
save "$TEMP/cpi_deflator", replace 
