version 16


clear all
use "setup\dataset.dta",clear

set more off

**************************************************************
/////////////////////Data Preparation/////////////////////////
**************************************************************

***************************group every 5 year data******************************

// in dpd approach, consecutive obs are crucial since they are used to calculate
// the first-differenced equation and test for serial correlation. But in 
// incapacity data and health data, the obs show up every 5 years so I want to 
// use 5 year as one unit instead of 1 year.

label variable incapacity "ExpenditureRatio"
label variable health "ExpenditureRatio" 
tab year if incapacity!=.
tab year if health!=.

* starts from 1980 and ends at 2015

cap drop nwyear

gen int nwyear = inrange(year,1980,2020) + inrange(year,1985,2020) + ///
inrange(year,1990,2020) + inrange(year,1995,2020) + inrange(year,2000,2020) + ///
inrange(year,2005,2020) + inrange(year,2010,2020) + inrange(year,2015,2020)

recode nwyear (0 = .)

/* this is equivalen to 
gen int nwyear = .
replace nwyear = 1 if inrange(year,1980,1984)
replace nwyear = 2 if inrange(year,1985,1990)
replace nwyear = 3 if inrange(year,1990,1994)
replace nwyear = 4 if inrange(year,1995,1999)
replace nwyear = 5 if inrange(year,2000,2004)
replace nwyear = 6 if inrange(year,2005,2009)
replace nwyear = 7 if inrange(year,2010,2014)
replace nwyear = 8 if inrange(year,2015,2020)
*/

* label for each values in nwyear
label variable nwyear "every 5 years"
* define value labels for variable nwyear
label define newyear 1 "1980" 2 "1985" 3 "1990" 4 "1995" 5 "2000" 6 "2005" ///
                    7 "2010" 8 "2015"
* use -label value- to attach value labels newyear to variable nwyear
label value nwyear newyear

**********define local macro and calculate the appropriate number*************

                          /***Dependents****/


/*cause-specific mortality*/
* define macro for cause-specific mortality in a specific order
* unab is command for constructing macro by using symbol *.  
unab cause_specific : mo_*
dis "`cause_specific'" 

/*age-specific mortality*/
* rename the age group for mortality 
cap drop tm_child tm_teen tm_young tm_midage tm_senior tm_elder

gen tm_child = tm_below_1 + tm_1_to_4 + tm_5_to_14  
gen tm_teen = tm_15_to_24
gen tm_young = tm_25_to_34 
gen tm_midage = tm_35_to_54
gen tm_senior =  tm_55_to_74
gen tm_elder = tm_75_above
 
* rename the age group for pop 
cap drop pop_child pop_teen pop_young pop_midage pop_senior pop_elder

gen pop_child = pop_below_1 + pop_1_to_4 + pop_5_to_14
gen pop_teen = pop_15_to_24
gen pop_young = pop_25_to_34 
gen pop_midage = pop_35_to_54
gen pop_senior =  pop_55_to_74
gen pop_elder =  pop_75_above

* define macro for age-specific mortality
local age_specific tm_child tm_teen tm_young tm_midage tm_senior tm_elder 
dis "`age_specific'"

/*follow the ruhm's methodology by constructing the weighted observation*/

* define varlist of cause-specific, age-specific and aggregate mortality.
local mortality tm `cause_specific' `age_specific'
dis "`mortality'"

foreach v in `mortality' {
 
	cap drop wln_`v' ln_`v' rate_`v' avgln_`v'
	qui: gen rate_`v' = `v'/pop
	qui: gen ln_`v'= log(rate_`v')
	qui: gen wln_`v'= ln_`v'*sqrt(pop)
    qui: bysort country nwyear:egen avgln_`v' = mean(ln_`v') if nwyear<.
}


* define varlists of different kinds of weighted dependents and logrithm dependents  

local cause_specific_rates rate_mo_liver rate_mo_heart rate_mo_respiratory rate_mo_cancer ///
rate_mo_external rate_mo_suicide rate_mo_homicide rate_mo_traffic ///
rate_mo_accidental_poison rate_mo_smoke_fire_flamme rate_mo_fall rate_mo_other_external
dis "`cause_specific_rates'"

* use macro extended function to modify names of each term.  
local cause_specific_logonly: subinstr local cause_specific_rates "rate_" "ln_",all
dis "`cause_specific_logonly'"

local avgcause_specific_logonly
foreach v in `cause_specific_logonly'{
	local avgcause_specific_logonly `avgcause_specific_logonly' avg`v'
}
dis "`avgcause_specific_logonly'"

local cause_specific_weighted
foreach v in `cause_specific_logonly'{
	local cause_specific_weighted `cause_specific_weighted' w`v'
}
di "`cause_specific_weighted'"


local age_specific_rates rate_tm_child rate_tm_teen rate_tm_young rate_tm_midage rate_tm_senior rate_tm_elder 
dis "`age_specific_rates'"

local age_specific_logonly : subinstr local age_specific_rates "rate_" "ln_", all
di "`age_specific_logonly'"

local avgage_specific_logonly
foreach v in `age_specific_logonly'{
	local avgage_specific_logonly `avgage_specific_logonly' avg`v'
}
di "`avgage_specific_logonly'"

local age_specific_weighted
foreach v in `age_specific_logonly'{
	local age_specific_weighted `age_specific_weighted' w`v'
}
di "`age_specific_weighted'"


local dependents_rates rate_tm `cause_specific_rates' `age_specific_rates'
dis "`dependents_rates'"

local dependents_logonly ln_tm `cause_specific_logonly' `age_specific_logonly'
dis "`dependents_logonly'"

local dependents_weighted wln_tm `cause_specific_weighted' `age_specific_weighted'
dis "`dependents_weighted'"


* labelling
foreach v in `dependents_logonly'{
	if "`v'" == "ln_tm" {
		label variable `v' "Log(M)"
	}
	else{
		label variable `v' "`v'"
	}
	

}

                          /***Independents****/
						  
* labelling	the unemployment and gni_per					  
label variable unem "UnemploymentRate"
label variable gni_per "Log(GNI per capita)"
label variable year "Year"

/*education variable*/
* labelling
label variable educ_below_upper_secondary "Population rates of individuals with below upper secondary degree"
label variable educ_tertiary "Population rates of individuals with tertiary degree"
label variable educ_upper_secondary "Population rates of individuals with upper secondary degree"
* define macro for education level
unab education : educ_*
dis "`education'" 
* Avoid perfect multi-collineaity --> exclude one variable 
* Use Macro extended function for manipulating lists. 
* Note that macros after list cannot be cited by `' since we are not citing its 
* contents.
* Even if we have only one variable, we still have to define a macro for it. 
local temp educ_below_upper_secondary
local education : list education - temp
dis "`education'"

/*age group variable*/
local age_specific_pop pop_child pop_teen pop_young pop_midage pop_senior pop_elder
dis "`age_specific_pop'"
* Avoid perfect multi-collineaity --> exclude one variable
local temp pop_elder
local age_specific_p op : list age_specific_pop - temp
dis "`age_specific_pop'"

* calculate the population rate of each age group 
foreach v in `age_specific_pop' {
 
	cap drop `v'_rate 
	qui: gen `v'_rate =`v'/pop
	* extract the subtring of local v.
	local o = substr("`v'",5,.)
	label variable `v'_rate "Population rate of group `o' " 
}

*define macro for age group
unab age_group_rate : *_rate
dis "`age_group_rate'"

/* log(pop) */
cap drop ln_pop
gen ln_pop = log(pop)
label variable ln_pop "Log(Population)"

/*inflow rates and outflow rates*/ 
cap drop temp
gen temp = inflows
replace inflows = temp/pop
cap drop temp
gen temp = outflows
replace outflows = temp/pop
drop temp

label variable inflows "Ratio of inflow to population"
label variable outflows "Ratio of outflow to population"

/*covariates*/

global covariates gni_per `age_group_rate' `education'  
dis "$covariates"

global covariates_aug gni_per `age_group_rate' `education' ln_pop
dis "$covariates_aug"

global covariates_dgn gni_per `education'  
dis "$covariates_dgn"

global covariates_dgn_aug gni_per `education' inflows outflows
dis "$covariates_dgn_aug"

/*short run and long run unemployment*/

  * short_term
cap drop s_unem
gen s_unem = unem*(1 - long_unem/100)
label variable s_unem "ShortRun UnemploymentRate"
  * long_term
cap drop l_unem
gen l_unem = unem*(long_unem/100)
label variable l_unem "LongRun UnemploymentRate"

/*follow the ruhm's methodology by constructing the weighted observation*/

local independents unem s_unem l_unem $covariates inflows outflows health incapacity ln_pop
dis "`independents'"

foreach v in `independents' {
 
	cap drop `v'_w 
	qui: gen `v'_w=`v'*sqrt(pop)

}

* define macro for weighted independents
unab education_weighted : educ_*_w
unab age_group_weighted : pop_*_rate_w	
global covariates_weighted gni_per_w `education_weighted' `age_group_weighted'
global covariates_aug_weighted gni_per_w `education_weighted'  /// 
                               `age_group_weighted' inflows_w outflows_w 
global covariates_dgn_weighted gni_per_w `education_weighted'
global covariates_dgn_aug_weighted gni_per_w `education_weighted' ///
                               inflows_w outflows_w
                                

dis "`education_weighted'"
dis "`age_group_weighted'"
dis "$covariates_weighted"
dis "$covariates_aug_weighted"


                        /***average by 5 year***/
foreach v in `independents' {
	bysort country nwyear: egen avg`v' = mean(`v') if nwyear<.
}

// avg`age_group_rate' does not work since it just assigns the prefix a to the 
//	first variable in this macro 					
						
global avgcovariates avggni_per avgpop_child_rate avgpop_teen_rate ///
avgpop_young_rate avgpop_midage_rate avgpop_senior_rate avgeduc_tertiary ///
 avgeduc_upper_secondary  
dis "$avgcovariates"

global avgcovariates_aug $avgcovariates avgln_pop
dis "$avgcovariates_aug"

global avgcovariates_dgn avggni_per avgeduc_tertiary avgeduc_upper_secondary  
dis "$avgcovariates_dgn"

global avgcovariates_dgn_aug $avgcovariates_dgn avginflows avgoutflows
dis "$avgcovariates_dgn_aug"




* gen the weighted panel specific time trends for -xtoverid-
  
  * gen the dummies according to i.country by command xi 
  * if use -tab country,gen(D_country)-, stata creats 36 countries with base one kept.
  cap drop D_country_* 
  xi i.country, prefix(D_)
  * stata allows D_country_* used in regression command standing for varlist.
  unab countries : D_country_*  
  dis "`countries'"
  
  * multiply weight and define the macro for varlist 
  
  global specific_trd_weighted 
  global specific_trd
  
  foreach v in `countries' {
    cap drop trd_`v'_w trd_`v'
	qui: gen trd_`v'_w = `v'*nwyear*sqrt(pop)
	qui: gen trd_`v' = `v'*nwyear
	global specific_trd_weighted  $specific_trd_weighted trd_`v'_w
	global specific_trd  $specific_trd trd_`v'
  }
  
  di "$specific_trd"
  di "$specific_trd_weighted"

/* for xttest, the factor operator and omitted estimate variables are not allowed:

local temp trd_D_country_18 trd_D_country_24 
di "`temp'"
global specific_trd: list global(specific_trd) - local(temp)  
di "$specific_trd"
*/

        /***create the indicator for boom in economic condition****/

/*for overall unemployment*/  

* indicator for decline in unemployment
 * I used bysort or sort in above coding, and thus I have to sort data again by
 * -tsset- command. 
// xtset tell stata it's panel data but Time-series operators(tsset) work with 
// panel data as well as pure time-series data.
// The only difference is in how you tsset your data.  
// ts is for the command for L. operator.
tsset country year

cap drop delta_u boom
  gen delta_u = d.unem
  gen boom = cond(delta_u<. , cond(delta_u<0 , 1 , 0) , .)
  label define boombust 1"Boom" 0"Bust"
  label value boom boombust 
// In principle, inclusion of interation between dummy and unem separates variable
// unem into two variables according to the value of Dummy. Specifically, it
// askes stata in running regression to treat unem as it having another 
// parameter when D equal to 1. 
// Since I don't want to do lincom test (lincom unem + 1.boom#c.unem) after 
// estimation, I do this separation by myself. 

/*
* bust_unem
cap drop bst_unem
gen bst_unem = cond(boom==1,0,unem)

* boom_unem
cap drop bm_unem
gen bm_unem = cond(boom==0,0,unem)
*/  
  
/*for short/long-run unemployment*/     
cap drop delta_su boom_s delta_lu boom_l
  gen delta_su = d.s_unem
  gen delta_lu = d.l_unem
  gen boom_s = cond(delta_su<. , cond(delta_su<0 , 1 , 0) , .)
  gen boom_l = cond(delta_lu<. , cond(delta_lu<0 , 1 , 0) , .)
  label define lboombust 1"LongRunBoom" 0"LongRunBust"
  label define sboombust 1"ShortRunBoom" 0"ShortRunBust"
  label value boom_l lboombust 
  label value boom_s sboombust 
/*
* bust_shortrun_unem
cap drop bsts_unem
gen bsts_unem = cond(boom_s==1,0,s_unem)

* boom_shortrun_unem
cap drop bms_unem
gen bms_unem = cond(boom_s==0,0,s_unem)

* bust_longrun_unem
cap drop bstl_unem
gen bstl_unem = cond(boom_l==1,0,l_unem)

* boom_longrun_unem
cap drop bml_unem
gen bml_unem = cond(boom_l==0,0,l_unem)
*/  
/*for overall unemployment but based on 5 year unit*/
// note in tsset, -d2.- means diff in diff but -s2.- means the difference between
// two periods
cap drop delta_avgu avgboom
  gen delta_avgu = s5.avgunem
  gen avgboom = cond(delta_avgu<. , cond(delta_avgu<0 , 1 , 0) , .)
  label value avgboom boombust 	



