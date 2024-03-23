* From raw FDF subscores to anchored scores
* INPUT:
* $AUX/pkoe.dta
* $TEMP/male_static
* OUTPUT:
* $TEMP/skill_measures.dta

macro list AUX TEMP


use "$AUX/pkoe", clear
merge 1:1 shnro using "$TEMP/male_static", /// 
	keep(3) keepusing(syntyv earnings_3540 n_3540) nogen

* Anchoring specifications 
* ========================

gen byte ok = !missing(pluku)
gen log_earn = log(earnings)

* Linear 
*-------

areg log_earn kuv san las if ok, robust absorb(syntyv) 
predict lp1_linear
label var lp1_linear "P1 linear"
sum lp1_linear if syntyv==1962
gen p1_linear = (lp1_linear-r(mean))/r(sd)
label var p1_linear "P1 linear (1962 SDs)"

areg log_earn T2_? if ok, robust absorb(syntyv) 
predict lp2_linear
label var lp2_linear "P2 linear"
sum lp2_linear if syntyv==1962
gen p2_linear = (lp2_linear-r(mean))/r(sd)
label var p2_linear "P2 linear (1962 SDs)"

areg log_earn kuv san las T2_? if ok, robust absorb(syntyv) 
predict lp12_linear
label var lp12_linear "P1 & P2 linear"
sum lp12_linear if syntyv==1962
gen p12_linear = (lp12_linear-r(mean))/r(sd)
label var p12_linear "P1 & P2 linear (1962 SDs)"

* Nonpara (full set of score dummies)
* -----------------------------------

areg log_earn i.kuv i.san i.las if ok, robust absorb(syntyv)
predict lp1_nonpara
label var lp1_nonpara "P1 nonparametric"
sum lp1_nonpara if syntyv==1962
gen p1_nonpara = (lp1_nonpara-r(mean))/r(sd)
label var p1_nonpara "P1 nonparametric (1962 SDs)"

areg log_earn i.T2_? if ok, robust absorb(syntyv)
predict lp2_nonpara
label var lp2_nonpara "P2 nonparametric"
sum lp2_nonpara if syntyv==1962
gen p2_nonpara = (lp2_nonpara-r(mean))/r(sd)
label var p2_nonpara "P2 nonparametric (1962 SDs)"

areg log_earn i.kuv i.san i.las i.T2_? if ok, robust absorb(syntyv) 
predict lp12_nonpara
label var lp12_nonpara "P1 & P2 nonparametric"
sum lp12_nonpara if syntyv==1962
gen p12_nonpara = (lp12_nonpara-r(mean))/r(sd)
label var p12_nonpara "P1 & P2 nonparametric (1962 SDs)"


keep shnro syntyv pluku kuv san las p*_linear p*_nonpara

* Standardize to base year 1962
* -----------------------------

sum pluku if syntyv==1962
gen z_pluku = (pluku-`r(mean)')/`r(sd)' 
label var z_pluku  "Z-score of FDF stanine" 

gen p1sum = kuv+san+las
label var p1sum "Sum of cognitive scores"
sum p1sum if syntyv==1962
gen z_p1sum = (p1sum-`r(mean)')/`r(sd)'
label var z_p1sum  "Z-score of sum of cognitive scores" 
egen zt_p1sum = std(p1sum), by(syntyv)
label var zt_p1sum  "Z-score of sum of cognitive scores (standardized by cohort)" 

gen p1_data=!missing(p1_linear)
label var p1_data "Cognitive score observed"
gen p2_data=!missing(p2_linear)
label var p2_data "Non-cognitive score observed"

label var syntyv "Year of birth"
order shnro syntyv pluku z_pluku
label data "FDF test results"
compress
save "$TEMP/skill_measures", replace	
