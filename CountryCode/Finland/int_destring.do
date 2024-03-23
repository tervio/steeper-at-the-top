* Much faster than destring : string to int
local varname `1'

tempvar varname_2
gen int `varname_2' = real(`varname')			
local lab : var label `varname'
label var `varname_2' "`lab'"
drop `varname'
rename `varname_2' `varname'
compress `varname'
