#delimit ;
set more 1;
set seed 22052023;

*NAV wage index 1967-2022;
mat G= (5400, 5900, 6400, 6800, 
 7400, 7900, 8500, 9533, 10800, 
 12000, 13383, 14550, 15200, 16633, 
 18658, 20667, 22333, 23667, 25333, 
 27433, 29267, 30850, 32275, 33575, 
 35033, 36167, 37033, 37820, 38847, 
 40410, 42000, 44413, 46423, 48377, 
 50603, 53233, 55964, 58139, 60059, 
 62161, 65505, 69108, 72006, 74721,
 78024, 81153, 84204, 87328, 89502,
 91740, 93281, 95800, 98866, 100853,
104716, 109784) ;

*CPI 1967-2022;
mat P= (10.9, 11.3, 11.6, 12.8,
13.7, 14.6, 15.7, 17.2, 19.2,
21, 22.9, 24.7, 25.9, 28.7,
32.6, 36.3, 39.4, 41.9, 44.2,
47.4, 51.6, 55, 57.5, 59.9, 
61.9, 63.4, 64.8, 65.7, 67.3,
68.2, 69.9, 71.5, 73.2, 75.5,
77.7, 78.7, 80.7, 81, 82.3,
84.2, 84.8, 88, 89.9, 92.1,
93.3, 93.9, 95.9, 97.9, 100,
103.6, 105.5, 108.4, 110.8, 112.2,
116.1, 122.8) ;


*replication code for Norwegian register data, iq income plateau paper;
*2020 1 EUR= 10.7207 NOK;

*input data sets;
*1. \data\demo\faste, fixed variables from central population register;
*2. \data\demo\bosted_wide, registered municipality of residence 1 January 1985-2021;
*3. \data\forsvar\evner, stanine score from conscription;
*4. \data\inntekt\wyrk_wide, annual sum of wage and self-employment earnings 1993-2020;
*5. \data\inntekt\wlonn_wide, annual sum of wage earnings 1993-2020;
*6. \data\areg\atmlto1996, employer-employee register records from 1996; 
*7. \data\inntekt\pgiv_wide, annual pensionable income 1967-2020;


use \data\demo\faste if kjonn=="1" & inrange(real(faar),1962,1975) & inlist(invkat,"A","C","F"), clear;
g byr= real(faar);
g dyr= real(dodsaar);
g noise= uniform();

sort lopenr;
merge lopenr using \data\demo\bosted_wide, nokeep;
tab _m;
drop _m;

forvalues t= 1997/2020 {;
local t1= `t'+1;
*bosted as of 1 jan yr t+1;
g byte inor`t'= bosted`t1'!="";
};

forvalues a= 35/45 {;
g byte inor`a'= 0;
};

forvalues b= 1962/1975 {;
forvalues a= 35/45 {;
local t= `b'+`a';
replace inor`a'= 1 if inor`t'==1 & byr==`b';
};
};

egen yrsinor35_45= rsum(inor35-inor45);
keep if yrsinor35_45==11;

sort lopenr;
merge lopenr using \data\forsvar\evner, nokeep keep(ae);
tab _m;
drop _m;
g stanine= real(ae);
g byte iqmiss= stanine==.;

sort lopenr;
merge lopenr using \data\inntekt\wyrk_wide, nokeep;
tab _m;
drop _m;
sort lopenr;
merge lopenr using \data\inntekt\wlonn_wide, nokeep;
tab _m;
drop _m;

forvalues t= 1997/2020 {;
local p= `t'-1966;
g byte emp`t'= wyrk`t'>G[1,`p'] & wyrk`t'<.; 
};

forvalues a= 35/45 {;
g y`a'= .;
};
forvalues a= 35/45 {;
g py`a'= .;
};
forvalues a= 35/45 {;
g w`a'= .;
};
forvalues a= 35/45 {;
g pw`a'= .;
};
forvalues a= 35/45 {;
g emp`a'= 0;
};

forvalues b= 1962/1975 {;
forvalues a= 35/45 {;
local t= `b'+`a';
local p= `t'-1966;
replace y`a'= wyrk`t' if byr==`b'; 
replace py`a'= P[1,2020-1966]*y`a'/P[1,`p'] if byr==`b';
replace w`a'= wlonn`t' if byr==`b'; 
replace pw`a'= P[1,2020-1966]*w`a'/P[1,`p'] if byr==`b';
replace emp`a'= emp`t' if byr==`b'; 
};
};

egen yrsemp1997_2009= rsum(emp1997-emp2009);
egen yrsemp35_45= rsum(emp35-emp45);

egen cumy= rsum(py35-py45);
g y= cumy/11;
replace y= y/10.7207;

egen cumw= rsum(pw35-pw45);
g w= cumw/11;
replace w= w/10.7207;

replace y= noise if y==0;
replace w= noise if w==0;

sort lopenr;
save temp\base_plateau, replace;


*fulltime 1996;

use lopenr using temp\base_plateau, clear;
sort lopenr;
merge lopenr using \data\areg\atmlto1996, nokeep;
tab _m;
drop _m;
g byte tmp1= 1 if forv_arb=="3";
egen full1996= mean(tmp1), by(lopenr);
sort lopenr;
keep if lopenr!=lopenr[_n+1];
keep lopenr full1996;
replace full1996= 0 if full1996==.;

sort lopenr;
save temp\full1996_plateau, replace;



use temp\base_plateau, clear;
sort lopenr;
merge lopenr using temp\full1996_plateau, nokeep;
tab _m;
drop _m;
g byte ismpl= yrsemp1997_2009>0 & full1996==0;
g byte rsmpl= ismpl & stanine<.;

gquantiles yrank= y, xtile nq(100) by(byr);
gquantiles wrank= w, xtile nq(100) by(byr);
gquantiles yrank_pooled= y, xtile nq(100);
gquantiles wrank_pooled= w, xtile nq(100);

g tmp1= y if ismpl;
gquantiles yrank_ismpl= tmp1, xtile nq(100) by(byr);
gquantiles yrank_ispooled= tmp1, xtile nq(100);
drop tmp1;
g tmp1= w if ismpl;
gquantiles wrank_ismpl= tmp1, xtile nq(100) by(byr);
gquantiles wrank_ispooled= tmp1, xtile nq(100);
drop tmp1;

g tmp1= y if rsmpl;
gquantiles yrank_rsmpl= tmp1, xtile nq(100) by(byr);
gquantiles yrank_rspooled= tmp1, xtile nq(100);
drop tmp1;
g tmp1= w if rsmpl;
gquantiles wrank_rsmpl= tmp1, xtile nq(100) by(byr);
gquantiles wrank_rspooled= tmp1, xtile nq(100);
drop tmp1;

sum stanine if byr==1962;
g st_z= (stanine-r(mean))/r(sd);

sort lopenr;
save temp\iqplateau_micro, replace;


log using sampledescript, t replace;

use temp\iqplateau_micro, clear;

sum y w stani st_z, d;
sum y w stani st_z if ismpl, d;
sum y w stani st_z if rsmpl, d;

sum *rank*, sep(0);
sum *rank* if ismpl, sep(0);
sum *rank* if rsmpl, sep(0);

log close;


use  temp\iqplateau_micro , clear;
g P= yrank;

collapse (count) n= y (count) n_cog= stanine 
(mean) cog_stanine= stanine (mean) cog_stanine_z= st_z
(sem) se_cog_stanine= stanine (sem) se_cog_stanine_z= st_z
, by(P);

g sample= "full";
g percentile_type= 1;
sort P;
save \temp\tmpsmpl1, replace;


use  temp\iqplateau_micro if ismpl , clear;
g P= yrank;

collapse (count) n= y (count) n_cog= stanine 
(mean) cog_stanine= stanine (mean) cog_stanine_z= st_z
(sem) se_cog_stanine= stanine (sem) se_cog_stanine_z= st_z
, by(P);

g sample= "intermediate";
g percentile_type= 1;
sort P;
save \temp\tmpsmpl2, replace;


use  temp\iqplateau_micro if rsmpl , clear;
g P= yrank;

collapse (count) n= y (count) n_cog= stanine 
(mean) cog_stanine= stanine (mean) cog_stanine_z= st_z
(sem) se_cog_stanine= stanine (sem) se_cog_stanine_z= st_z
, by(P);

g sample= "restricted";
g percentile_type= 1;
sort P;
save \temp\tmpsmpl3, replace;


use temp\iqplateau_micro , clear;
g P= yrank_pooled;

collapse (count) n= y (count) n_cog= stanine 
(mean) cog_stanine= stanine (mean) cog_stanine_z= st_z
(sem) se_cog_stanine= stanine (sem) se_cog_stanine_z= st_z
, by(P);

g sample= "full";
g percentile_type= 2;
sort P;
save \temp\tmpsmpl4, replace;


use temp\iqplateau_micro if ismpl , clear;
g P= yrank_pooled;

collapse (count) n= y (count) n_cog= stanine 
(mean) cog_stanine= stanine (mean) cog_stanine_z= st_z
(sem) se_cog_stanine= stanine (sem) se_cog_stanine_z= st_z
, by(P);

g sample= "intermediate";
g percentile_type= 2;
sort P;
save \temp\tmpsmpl5, replace;


use temp\iqplateau_micro if rsmpl , clear;
g P= yrank_pooled;

collapse (count) n= y (count) n_cog= stanine 
(mean) cog_stanine= stanine (mean) cog_stanine_z= st_z
(sem) se_cog_stanine= stanine (sem) se_cog_stanine_z= st_z
, by(P);

g sample= "restricted";
g percentile_type= 2;
sort P;
save \temp\tmpsmpl6, replace;


use temp\iqplateau_micro if rsmpl , clear;
g P= yrank_rsmpl;

collapse (count) n= y (count) n_cog= stanine 
(mean) cog_stanine= stanine (mean) cog_stanine_z= st_z
(sem) se_cog_stanine= stanine (sem) se_cog_stanine_z= st_z
, by(P);

g sample= "restricted";
g percentile_type= 3;
sort P;
save \temp\tmpsmpl7, replace;


use temp\iqplateau_micro if rsmpl , clear;
g P= yrank_rspooled;

collapse (count) n= y (count) n_cog= stanine 
(mean) cog_stanine= stanine (mean) cog_stanine_z= st_z
(sem) se_cog_stanine= stanine (sem) se_cog_stanine_z= st_z
, by(P);

g sample= "restricted";
g percentile_type= 4;
sort P;
save \temp\tmpsmpl8, replace;


use  temp\iqplateau_micro , clear;
g P= wrank;

collapse (count) n= w (count) n_cog= stanine 
(mean) cog_stanine= stanine (mean) cog_stanine_z= st_z
(sem) se_cog_stanine= stanine (sem) se_cog_stanine_z= st_z
, by(P);

g sample= "full";
g percentile_type= 5;
sort P;
save \temp\tmpsmpl9, replace;


use  temp\iqplateau_micro if ismpl , clear;
g P= wrank;

collapse (count) n= w (count) n_cog= stanine 
(mean) cog_stanine= stanine (mean) cog_stanine_z= st_z
(sem) se_cog_stanine= stanine (sem) se_cog_stanine_z= st_z
, by(P);

g sample= "intermediate";
g percentile_type= 5;
sort P;
save \temp\tmpsmpl10, replace;


use  temp\iqplateau_micro if rsmpl , clear;
g P= wrank;

collapse (count) n= w (count) n_cog= stanine 
(mean) cog_stanine= stanine (mean) cog_stanine_z= st_z
(sem) se_cog_stanine= stanine (sem) se_cog_stanine_z= st_z
, by(P);

g sample= "restricted";
g percentile_type= 5;
sort P;
save \temp\tmpsmpl11, replace;


use temp\iqplateau_micro , clear;
g P= wrank_pooled;

collapse (count) n= w (count) n_cog= stanine 
(mean) cog_stanine= stanine (mean) cog_stanine_z= st_z
(sem) se_cog_stanine= stanine (sem) se_cog_stanine_z= st_z
, by(P);

g sample= "full";
g percentile_type= 6;
sort P;
save \temp\tmpsmpl12, replace;


use temp\iqplateau_micro if ismpl , clear;
g P= wrank_pooled;

collapse (count) n= w (count) n_cog= stanine 
(mean) cog_stanine= stanine (mean) cog_stanine_z= st_z
(sem) se_cog_stanine= stanine (sem) se_cog_stanine_z= st_z
, by(P);

g sample= "intermediate";
g percentile_type= 6;
sort P;
save \temp\tmpsmpl13, replace;


use temp\iqplateau_micro if rsmpl , clear;
g P= wrank_pooled;

collapse (count) n= w (count) n_cog= stanine 
(mean) cog_stanine= stanine (mean) cog_stanine_z= st_z
(sem) se_cog_stanine= stanine (sem) se_cog_stanine_z= st_z
, by(P);

g sample= "restricted";
g percentile_type= 6;
sort P;
save \temp\tmpsmpl14, replace;


use temp\iqplateau_micro if rsmpl , clear;
g P= wrank_rsmpl;

collapse (count) n= w (count) n_cog= stanine 
(mean) cog_stanine= stanine (mean) cog_stanine_z= st_z
(sem) se_cog_stanine= stanine (sem) se_cog_stanine_z= st_z
, by(P);

g sample= "restricted";
g percentile_type= 7;
sort P;
save \temp\tmpsmpl15, replace;


use temp\iqplateau_micro if rsmpl , clear;
g P= wrank_rspooled;

collapse (count) n= w (count) n_cog= stanine 
(mean) cog_stanine= stanine (mean) cog_stanine_z= st_z
(sem) se_cog_stanine= stanine (sem) se_cog_stanine_z= st_z
, by(P);

g sample= "restricted";
g percentile_type= 8;
sort P;
save \temp\tmpsmpl16, replace;


clear;

forvalues k= 1/16 {;
append using \temp\tmpsmpl`k';
};

label def plab
1 "Earnings percentile (within full sample cohort)"
2 "Earnings percentile (within full sample)"
3 "Earnings percentile (within restricted sample cohort)"
4 "Earnings percentile (within restricted sample)"
5 "Wage percentile (within full sample cohort)"
6 "Wage percentile (within full sample)"
7 "Wage percentile (within restricted sample cohort)"
8 "Wage percentile (within restricted sample)"
, replace;
lab val percentile_type plab;

order sample P percentile n n_cog cog_stanine_z cog_stanine se_cog_stanine_z se_cog_stanine; 

sort sample percentile P;
save h:\transfer\norway\alt_percentiles, replace;


use  temp\iqplateau_micro if stanine<., clear;
g PT_earnings= yrank;

forvalues a= 1/9 {;
g byte stan`a'= stanine==`a';
};

collapse (mean) stan1-stan9, by(PT_earnings);

sort PT_earnings;
save h:\transfer\norway\stanshares_vs_earnings, replace;


use  temp\iqplateau_micro , clear;
g PT_earnings= yrank;

collapse (sd) sd_cog_stanine= stanine (sd) sd_cog_stanine_z= st_z, by(PT_earnings); 

sort PT_earnings;
save h:\transfer\norway\cog-sd_vs_earn, replace;


use  temp\iqplateau_micro , clear;
g PT_earnings= yrank;

collapse (mean) earnings= y 
(mean) cog_stanine= stanine (mean) cog_stanine_z= st_z
(sem) se_cog_stanine= stanine (sem) se_cog_stanine_z= st_z
, by(PT_earnings);

sort PT_earnings;
save h:\transfer\norway\cog_vs_earnings, replace;


use  temp\iqplateau_micro , clear;
g PT_earnings= yrank;

replace stanine=99 if stanine==.;

xtile pstd= st_z, n(100);

collapse (mean) cog_stanine_z= st_z (mean) cog_stanine_q= pstd 
(mean) earnings= y (mean) PT_earnings= yrank (sem) se_earnings= y
(p50) p50_earnings= y (count) n= y, by(stanine);

keep stanine cog_* *earn* n;
replace stanine= . if stanine==99;
ren stanine cog_stanine;

sort cog_stanine;
save h:\transfer\norway\earn_vs_cog, replace;



*REPEAT FOR THOSE BORN IN THE 1950s, EARNINGS 35-45 AND 45-55;

use \data\demo\faste if kjonn=="1" & inrange(real(faar),1950,1961) & inlist(invkat,"A","C","F"), clear;
g byr= real(faar);
g dyr= real(dodsaar);
g noise= uniform();
g bmo= real(substr(faar_mnd,5,2));
drop if byr==1961 & bmo>3;

sort lopenr;
merge lopenr using \data\demo\bosted_wide, nokeep;
tab _m;
drop _m;

forvalues t= 1985/2020 {;
local t1= `t'+1;
*bosted as of 1 jan yr t+1;
g byte inor`t'= bosted`t1'!="";
};

forvalues a= 35/55 {;
g byte inor`a'= 0;
};

forvalues b= 1950/1961 {;
forvalues a= 35/55 {;
local t= `b'+`a';
replace inor`a'= 1 if inor`t'==1 & byr==`b';
};
};

egen yrsinor35_45= rsum(inor35-inor45);
egen yrsinor45_55= rsum(inor45-inor55);
keep if yrsinor35_45==11 | yrsinor45_55==11;

sort lopenr;
merge lopenr using \data\forsvar\evner, nokeep keep(ae);
tab _m;
drop _m;
g stanine= real(ae);
replace stanine= stanine-1 if stanine>1;
g byte hasiq= stanine<.;

sort lopenr;
merge lopenr using \data\inntekt\pgiv_wide, nokeep;
tab _m;
drop _m;
sort lopenr;
merge lopenr using \data\inntekt\wyrk_wide, nokeep;
tab _m;
drop _m;
sort lopenr;
merge lopenr using \data\inntekt\wlonn_wide, nokeep;
tab _m;
drop _m;


forvalues t= 1985/1992 {;
local p= `t'-1966;
g byte emp`t'= p_innt`t'>G[1,`p'] & p_innt`t'<.; 
};
forvalues t= 1993/2020 {;
local p= `t'-1966;
g byte emp`t'= wyrk`t'>G[1,`p'] & wyrk`t'<.; 
};

forvalues a= 35/55 {;
g y`a'= .;
};
forvalues a= 35/55 {;
g py`a'= .;
};
forvalues a= 35/55 {;
g emp`a'= 0;
};

forvalues b= 1950/1961 {;
forvalues a= 35/55 {;
local t= `b'+`a';
local p= `t'-1966;
if `t'<1993 {; replace y`a'= p_innt`t' if byr==`b'; };
if `t'>=1993 {; replace y`a'= wyrk`t' if byr==`b'; };
replace py`a'= P[1,2020-1966]*y`a'/P[1,`p'] if byr==`b';
replace emp`a'= emp`t' if byr==`b'; 
};
};

egen yrsemp35_45= rsum(emp35-emp45);
egen yrsemp45_55= rsum(emp45-emp55);

egen cumy1= rsum(py35-py45);
g y1= cumy1/11;
replace y1= noise if y1<=0;
replace y1= y1/10.7207;

egen cumy2= rsum(py45-py55);
g y2= cumy2/11;

replace y2= noise if y2<=0;
replace y2= y2/10.7207;

sort lopenr;
save temp\base_plateau_1950s, replace;


*rank measures;

forvalues b= 1950/1961 {;
use lopenr byr y1 yrsinor* using temp\base_plateau_1950s if byr==`b' & yrsinor35_45==11, clear;
xtile y1rank= y1, n(100);
save temp\tmp`b', replace;
};
clear;
forvalues b= 1950/1961 {;
append using temp\tmp`b';
};
sort lopenr;
save temp\plateau_y1rank_1950s, replace;

forvalues b= 1950/1961 {;
use lopenr byr y2 yrsinor* using temp\base_plateau_1950s if byr==`b' & yrsinor45_55==11, clear;
xtile y2rank= y2, n(100);
save temp\tmp`b', replace;
};
clear;
forvalues b= 1950/1961 {;
append using temp\tmp`b';
};
sort lopenr;
save temp\plateau_y2rank_1950s, replace;


use temp\base_plateau_1950s, clear;
sort lopenr;
merge lopenr using temp\plateau_y1rank_1950s, nokeep;
tab _m;
drop _m;
sort lopenr;
merge lopenr using temp\plateau_y2rank_1950s, nokeep;
tab _m;
drop _m;

g tmp1= y1 if yrsinor35_45==11;
xtile y1rank_pooled= tmp1, n(100);
drop tmp1;
g tmp1= y2 if yrsinor45_55==11;
xtile y2rank_pooled= tmp1, n(100);
drop tmp1;

sum stanine if byr==1950;
g st_z= (stanine-r(mean))/r(sd);

sort lopenr;
save temp\iqplateau_micro_1950s, replace;


use  temp\iqplateau_micro_1950s if y1rank<., clear;
g PT_earnings= y1rank;

collapse (count) n= y1 (count) n_cog= stanine 
(mean) cog_stanine= stanine (mean) cog_stanine_z= st_z
(sem) se_cog_stanine= stanine (sem) se_cog_stanine_z= st_z
, by(PT_earnings);

sort PT_earnings;
save h:\transfer\norway\cog_vs_earn3545_1950s, replace;


use  temp\iqplateau_micro_1950s if y2rank<., clear;
g PT_earnings= y2rank;

collapse (count) n= y2 (count) n_cog= stanine 
(mean) cog_stanine= stanine (mean) cog_stanine_z= st_z
(sem) se_cog_stanine= stanine (sem) se_cog_stanine_z= st_z
, by(PT_earnings);

sort PT_earnings;
save h:\transfer\norway\cog_vs_earn4555_1950s, replace;
