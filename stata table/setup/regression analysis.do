
                                /*  A technical note */
/* 
	When combining capture and drop, never say something like capture drop var1 var2 var3.
Remember that Stata commands do either exactly what you say or nothing at all. We might think
that our command would be guaranteed to eliminate var1, var2, and var3 from the data if they
exist. It is not. Imagine that var3 did not exist in the data. drop would then do nothing. It would
not drop var1 and var2 as well.     

   Be careful when there is any variable following -cap drop- such as temp may exist but not others.                                                  

*/
			
			
/*

I am not quite sure but you might want to check out (search first, and then install) outreg2, esttab, and tabout, respectively.

you can ssc install corr2docx, sum2docx, and reg2docx, respectively, and see their help file for further instruction.

Do you know if sum2docx has an option that allows reporting missing values along with the descriptives?

You can install asdoc from SSC.
*/			
		

do "setup\data preparation.do"
		
* new frame for dpd 
cap frame drop dpd
frame copy default dpd 
 

set more off

  
********************************************************************************
///////Between variations are dropped when panel specific trends included///////
********************************************************************************

                          /* Baseline */
// reason of calling it baseline is this equation specification is from basis 
// paper Ruhm (2000).  
					  
eststo fe_bsl: xtreg ln_tm unem $covariates i.country#c.year, ///
                           fe vce(cluster country)
qui: estadd local pstt "Yes", replace
qui: estadd local gtt "Omitted", replace
qui: estadd local gtd "No", replace
qui: estadd local asy "No", replace
qui: estadd local dny "No", replace
qui: estadd local mgr "No",replace
qui: estadd local smpl "1 year", replace 
qui: estadd local stts "No", replace
qui: estadd local est "FE", replace

eststo pls_bsl: reg ln_tm unem $covariates i.country#c.year, ///
                            vce(cluster country)
qui: estadd local pstt "Yes", replace
qui: estadd local gtt "Omitted", replace
qui: estadd local mgr "No",replace
qui: estadd local est "POLS", replace

eststo re_bsl: xtreg ln_tm unem $covariates i.country#c.year, ///
                           re vce(cluster country)
qui: estadd local pstt "Yes", replace
qui: estadd local gtt "Omitted", replace
qui: estadd local mgr "No",replace
qui: estadd local est "RE", replace

               /*  Without the specific trends */
			   
eststo fe_bsl_wtt: xtreg ln_tm unem $covariates year, fe vce(cluster country)
qui: estadd local pstt "No", replace
qui: estadd local gtt "Yes", replace
qui: estadd local mgr "No",replace
qui: estadd local est "FE", replace

eststo pls_bsl_wtt: reg ln_tm unem $covariates year, vce(cluster country)                            
qui: estadd local pstt "No", replace
qui: estadd local gtt "Yes", replace
qui: estadd local mgr "No",replace
qui: estadd local est "POLS", replace

eststo re_bsl_wtt: xtreg ln_tm unem $covariates year, re vce(cluster country)                           
qui: estadd local gtt "Yes", replace
qui: estadd local pstt "No", replace
qui: estadd local mgr "No",replace 
qui: estadd local est "RE", replace



 		  
						   
/*                   F statistics cannot be calculated 

  One reason :  For some reason (could be singleton dummies (dummy trap), could be something else (one regressor has zero or omitted estimates)), the G matrix, the filling of the robust VCE sandwich DGD is not full rank. This isn't necessarily a problem for tests of individual parameters, but not for an F stat for the model. It looks like that's not going to be possible, because an F stat for the model means a joint test of all the regressors, and that can't be done because #regressors > rank(G). 
  
  One reason : Stata does not calculate an F-statistic after a clustered regression because the clustered regression uses Huber variances, which are calculated without assuming that the observations are independent and homoskedastic (ie equally variable). The F-test statistic is calculated using the assumption that observations are independent and homoskedastic, and is therefore not appropriate for use in a clustered regression analysis. To carry out multi-dimensional hhypothesis tests for a clustered regression model, use the -test- command.
   the model test with clustered or survey data is distributed as F(k,d-k+1) or chi2(k), where k is the number of constraints and d=number of clusters or d=number of PSUs minus the number of strata. Because the rank of the VCE is at most d and the model test reserves 1 degree of freedom for the constant, at most d-1 constraints can be tested, so k must be less than d. The model that you just fit does not meet this requirement.
   
*/




**************************************************************
///////////Estimation results in static models////////////////
**************************************************************

// Baseline model in my research is the static one with asymetry specified 

                         /* Asymmetrity */

// asy in unem
 
eststo fe_bsl_asy: xtreg ln_tm boom#c.unem $covariates i.country#c.year, ///
            fe vce(cluster country)
qui: estadd local pstt "Yes", replace
qui: estadd local gtd "No", replace
qui: estadd local dny "No", replace
qui: estadd local stts "No", replace
qui: estadd local smpl "1 year", replace 
qui: estadd local asy "Yes", replace
qui: estadd local est "FE", replace

// asy in unem + coefficient's relation with welfare status

eststo fe_bsl_aswf1: xtreg ln_tm unem ///
            boom#c.incapacity#c.unem  c.incapacity#c.unem ///
            $covariates i.country#c.year, fe vce(cluster country)
qui: estadd local dny "No", replace
qui: estadd local stts "Incapacity", replace
qui: estadd local pstt "Yes", replace
qui: estadd local gtd "No", replace
qui: estadd local smpl "1 year", replace 
qui: estadd local asy "Yes", replace
qui: estadd local est "FE", replace

eststo fe_bsl_aswf2: xtreg ln_tm unem boom#c.health#c.unem c.health#c.unem ///
            $covariates i.country#c.year, fe vce(cluster country)
qui: estadd local dny "No", replace
qui: estadd local stts "Health", replace
qui: estadd local pstt "Yes", replace
qui: estadd local gtd "No", replace
qui: estadd local smpl "1 year", replace
qui: estadd local asy "Yes", replace
qui: estadd local est "FE", replace



**************************************************************
///////////Estimation results in dynamic models////////////////
**************************************************************
 

                /* Asymmetrity + long and short run decomposition */
				  
eststo fe_bsl_asdn: xtreg ln_tm ///
            boom_s#c.s_unem boom_l#c.l_unem ///
            $covariates i.country#c.year, fe vce(cluster country)
qui: estadd local asy "Yes", replace
qui: estadd local pstt "Yes", replace
qui: estadd local gtd "No", replace
qui: estadd local stts "No", replace
qui: estadd local dny "Decomposition", replace
qui: estadd local smpl "1 year", replace
qui: estadd local est "FE", replace 

// + coefficient's relation with welfare status

eststo fe_bsl_asdnwf1: xtreg ln_tm ///
            s_unem boom_s#c.s_unem#c.incapacity c.incapacity#c.s_unem  ///
            l_unem boom_l#c.l_unem#c.incapacity c.incapacity#c.l_unem  ///
			$covariates i.country#c.year  , fe vce(cluster country)
qui: estadd local dny "Decomposition", replace
qui: estadd local stts "Incapacity", replace
qui: estadd local pstt "Yes", replace
qui: estadd local gtd "No", replace
qui: estadd local asy "Yes", replace
qui: estadd local smpl "1 year", replace
qui: estadd local est "FE", replace 

eststo fe_bsl_asdnwf2: xtreg ln_tm ///
            s_unem boom_s#c.s_unem#c.health c.health#c.s_unem  ///
            l_unem boom_l#c.l_unem#c.health c.health#c.l_unem  ///
			$covariates i.country#c.year  , fe vce(cluster country)
qui: estadd local dny "Decomposition", replace  
qui: estadd local stts "Health", replace   
qui: estadd local pstt "Yes", replace  
qui: estadd local gtd "No", replace
qui: estadd local asy "Yes", replace 
qui: estadd local smpl "1 year", replace 
qui: estadd local est "FE", replace

                 /* Asymmetrity + dynamic panel data*/
			   
frame change dpd

* copy variable labels before collapse
foreach v of var *{
	
	* copy label of v into macto lv
	local l`v' : variable label `v'
	* if original does not have label then use its name as label
	if`"`l`v''"' == ""{
		local l`v' "`v'"
	}
	
} 


local index nwyear Countries
qui: describe, varlist 
local allvar `r(varlist)'
local allvar: list allvar - index
//di "`allvar'"  
collapse (max) `allvar', by(Countries nwyear)
tsset country nwyear  
keep if nwyear<.

* attach the saved labels after collapse
foreach v of var avg*{
	
	* avg variable in regression
	local o = substr("`v'",4,.)
	label var `v' "`l`o''"
	
	* original variable label 
	label variable `o' "`l`o''"

}
label value avgboom boombust
label value boom boombust
label value nwyear newyear

* create dummy for nwyear
cap drop d_nwyear*
xi i.nwyear, prefix(d_)

			/* DPD as dynamic + asy + relation with welfare status */
			
                       // Differnce GMM // 

// dynamic
eststo fe_bsl_asdg: xtabond2 L(0/1).avgln_tm avgboom#c.avgunem ///
               L(0/1).($avgcovariates) d_nwyear* , ///
gmm(avgln_tm, laglimits(2 7) ) ///
iv( d_nwyear*  ,equation(level) ) /// 
iv(avgboom#c.avgunem L(1/2).($avgcovariates), passthru) ///
               nolevel robust small twostep  artests(7) 

	* nonlinear combination to obtain the long run estimates  
	nlcom (_b[0.avgboom#c.avgunem]/(1-_b[l.avgln_tm])-_b[0.avgboom#c.avgunem]) ///
	(_b[1.avgboom#c.avgunem]/(1-_b[l.avgln_tm])-_b[1.avgboom#c.avgunem])

	
// dynamic + hetero wrt incapacity 
eststo fe_bsl_asdgwf1: xtabond2 L(0/1).avgln_tm ///
               avgunem avgboom#c.avgincapacity#c.avgunem c.avgincapacity#c.avgunem ///
               L(0/1).($avgcovariates) d_nwyear* , ///
gmm(avgln_tm , laglimits(2 3)) ///
iv( d_nwyear*  ,equation(level)) /// 
iv(avgunem avgboom#c.avgincapacity#c.avgunem c.avgincapacity#c.avgunem L(0/1).($avgcovariates), passthru) ///
               nolevel robust small  twostep artests(7) 
qui: estadd local dny "Koyck lag", replace
qui: estadd local stts "Incapacity", replace
qui: estadd local pstt "No", replace
qui: estadd local gtd "Yes", replace
qui: estadd local asy "Yes", replace
qui: estadd local smpl "5 year", replace 
qui: estadd local est "Difference GMM", replace

	* nonlinear combination to obtain the long run estimates  
	eststo fe_bsl_asdgwf1_pst:  ///
	nlcom (u:_b[avgunem]/(1-_b[l.avgln_tm]) - _b[avgunem]) ///
	(incapacityXu: _b[c.avgincapacity#c.avgunem]/(1-_b[l.avgln_tm])-_b[c.avgincapacity#c.avgunem]) ///
	(bXincapacityXu: _b[1.avgboom#c.avgincapacity#c.avgunem]/(1-_b[l.avgln_tm])-_b[1.avgboom#c.avgincapacity#c.avgunem]),post  

  
// dynamic + hetero wrt health
eststo fe_bsl_asdgwf2: xtabond2 L(0/1).avgln_tm ///
               avgunem avgboom#c.avghealth#c.avgunem c.avghealth#c.avgunem ///
               L(0/1).($avgcovariates) d_nwyear* , ///
gmm(avgln_tm , laglimits(2 4)) ///
iv( d_nwyear*  ,equation(level)) /// 
iv(avgunem avgboom#c.avghealth#c.avgunem c.avghealth#c.avgunem L(0/1).($avgcovariates), passthru) ///
               nolevel robust small  twostep artests(7) 
qui: estadd local dny "Koyck lag", replace
qui: estadd local stts "Health", replace
qui: estadd local pstt "No", replace
qui: estadd local gtd "Yes", replace
qui: estadd local asy "Yes", replace
qui: estadd local smpl "5 year", replace 
qui: estadd local est "Difference GMM", replace

	* nonlinear combination to obtain the long run estimates 
	eststo fe_bsl_asdgwf2_pst:  ///
	nlcom (u:_b[avgunem]/(1-_b[l.avgln_tm]) - _b[avgunem]) ///
	(healthXu: _b[c.avghealth#c.avgunem]/(1-_b[l.avgln_tm])-_b[c.avghealth#c.avgunem]) ///
	(bXhealthXu: _b[1.avgboom#c.avghealth#c.avgunem]/(1-_b[l.avgln_tm])-_b[1.avgboom#c.avghealth#c.avgunem]), post
	
 
	
                            // system GMM //

eststo fe_bsl_assgwf1: xtabond2 L(0/1).avgln_tm ///
               avgunem avgboom#c.avgincapacity#c.avgunem c.avgincapacity#c.avgunem ///
               L(0/1).$avgcovariates d_nwyear* ,  ///
gmm(avgln_tm , laglimits(2 2)) ///
iv( d_nwyear*  ,equation(level)) /// 
iv(avgunem avgboom#c.avgincapacity#c.avgunem c.avgincapacity#c.avgunem L(0/1).$avgcovariates ) ///
robust small  twostep artests(7) 
qui: estadd local dny "Koyck lag", replace
qui: estadd local stts "Incapacity", replace
qui: estadd local pstt "No", replace
qui: estadd local gtd "Yes", replace
qui: estadd local asy "Yes", replace
qui: estadd local smpl "5 year", replace 
qui: estadd local est "System GMM", replace

	* nonlinear combination to obtain the long run estimates 
	eststo fe_bsl_assgwf1_pst : ///
	nlcom (u:_b[avgunem]/(1-_b[l.avgln_tm]) - _b[avgunem]) ///
	(incapacityXu: _b[c.avgincapacity#c.avgunem]/(1-_b[l.avgln_tm])-_b[c.avgincapacity#c.avgunem]) ///
	(bXincapacityXu: _b[1.avgboom#c.avgincapacity#c.avgunem]/(1-_b[l.avgln_tm])-_b[1.avgboom#c.avgincapacity#c.avgunem]), post

eststo fe_bsl_assgwf2: xtabond2 L(0/1).avgln_tm ///
               avgunem avgboom#c.avghealth#c.avgunem c.avghealth#c.avgunem ///
               L(0/1).$avgcovariates d_nwyear* ,  ///
gmm(avgln_tm , laglimits(2 2)) ///
iv( d_nwyear*  ,equation(level)) /// 
iv(avgunem avgboom#c.avghealth#c.avgunem c.avghealth#c.avgunem L(0/1).$avgcovariates ) ///
robust small  twostep artests(7) 
qui: estadd local dny "Koyck lag", replace
qui: estadd local stts "Health", replace
qui: estadd local pstt "No", replace
qui: estadd local gtd "Yes", replace
qui: estadd local asy "Yes", replace
qui: estadd local smpl "5 year", replace 
qui: estadd local est "System GMM", replace

	* nonlinear combination to obtain the long run estimates  
	eststo fe_bsl_assgwf2_pst : ///
	nlcom (u:_b[avgunem]/(1-_b[l.avgln_tm]) - _b[avgunem]) ///
	(healthXu: _b[c.avghealth#c.avgunem]/(1-_b[l.avgln_tm])-_b[c.avghealth#c.avgunem]) ///
	(bXhealthXu: _b[1.avgboom#c.avghealth#c.avgunem]/(1-_b[l.avgln_tm])-_b[1.avgboom#c.avghealth#c.avgunem]), post
	
	
	                         // LSDV corrected bias //
							 
* create factor variables
cap drop avgboom_avgincapacity_avgunem avgincapacity_avgunem
gen avgboom_avgincapacity_avgunem = avgboom*avgincapacity*avgunem
gen avgincapacity_avgunem = avgincapacity*avgunem

cap drop avgboom_avghealth_avgunem avghealth_avgunem
gen avgboom_avghealth_avgunem = avgboom*health*avgunem
gen avghealth_avgunem = avghealth*avgunem

* label the regressors of interests
label variable avgboom_avgincapacity_avgunem "Boom X ExpenditureRatio X UnemploymentRate"
label variable avgincapacity_avgunem "ExpenditureRatio X UnemploymentRate"
label variable avgboom_avghealth_avgunem "Boom X ExpenditureRatio X UnemploymentRate"
label variable avghealth_avgunem "ExpenditureRatio X UnemploymentRate"

local L_avgcovariates
foreach v in $avgcovariates {

    cap drop L_`v'
	gen L_`v' = L.`v'
	
	local L_avgcovariates `L_avgcovariates' L_`v'

}
   
   
foreach v in "dg" "sg"{

	* specify the inital as ab (diff gmm) estimate or bb (sys gmm) estimate 
	local initial = cond("`v'"=="dg", "ab","bb") 
	local Initial = cond("`v'"=="dg", "Difference GMM","System GMM")
	
	forvalues i = 1/2{
	
		* specify the programme
		
		local temp = cond(`i'==1, "incapacity","health")
		local Temp = cond(`i'==1, "Incapacity","Health")
	
		* I exclude option vcov(50) in order to speed up the process
		
		eststo fe_bsl_as`v'lsdvwf`i': xtlsdvc avgln_tm avgunem ///
			avgboom_avg`temp'_avgunem avg`temp'_avgunem ///
            $avgcovariates `L_avgcovariates' d_nwyear* , ///
			initial(`initial') level(90)  bias(2) 
		qui: estadd local dny "Koyck lag", replace
		qui: estadd local stts "`Temp'", replace
		qui: estadd local pstt "No", replace
		qui: estadd local gtd "Yes", replace
		qui: estadd local asy "Yes", replace
		qui: estadd local smpl "5 year", replace 
		qui: estadd local initial "`Initial'", replace 
		qui: estadd local est "bias-corrected LSDV", replace 
		* nonlinear combination to obtain the long run estimates  
		eststo fe_bsl_as`v'lsdvwf`i'_pst : /// 
		nlcom (u:_b[avgunem]/(1-_b[l.avgln_tm]) - _b[avgunem]) ///
		(`temp'Xu: _b[avg`temp'_avgunem]/(1-_b[l.avgln_tm])-_b[avg`temp'_avgunem]) ///
		(bX`temp'Xu: _b[avgboom_avg`temp'_avgunem]/(1-_b[l.avgln_tm])-_b[avgboom_avg`temp'_avgunem]), post
	
		
	}


}



**************************************************************
///////////////////Appendix regressions///////////////////////
**************************************************************


/* LSDV bias corrected estimators loops over different bounding orders and initial estimates */

local dgmm
local sgmm
local dgmm_pst
local sgmm_pst

forvalues j = 1/2 {
	
	* specify the programme
	local temp = cond(`j'==1, "incapacity","health")
	local Temp = cond(`j'==1, "Incapacity","Health")
			
	foreach v in "dg" "sg"{
	
		* specify the inital as ab (diff gmm) estimate or bb (sys gmm) estimate 
		local initial = cond("`v'"=="dg", "ab","bb") 
		local Initial = cond("`v'"=="dg", "Difference GMM","System GMM")
		
		forvalues i = 1/3{
			
			* I exclude option vcov(50) in order to speed up the process
		
		    qui: eststo `v'b`i'wf`j': xtlsdvc avgln_tm avgunem ///
			avgboom_avg`temp'_avgunem avg`temp'_avgunem ///
            $avgcovariates `L_avgcovariates' d_nwyear* , ///
			initial(`initial') level(90) bias(`i') 
			
			qui: estadd local stts "`Temp'", replace
			qui: estadd local smpl "5 year", replace 
			qui: estadd local initial "`Initial'", replace 
			qui: estadd local border "`i'", replace 
			
			local `v'mm ``v'mm' `v'b`i'wf`j'
			
			* nonlinear combination to obtain the long run estimates  
			eststo `v'b`i'wf`j'_pst : /// 
			nlcom (u:_b[avgunem]/(1-_b[l.avgln_tm]) - _b[avgunem]) ///
			(`temp'Xu: _b[avg`temp'_avgunem]/(1-_b[l.avgln_tm])-_b[avg`temp'_avgunem]) ///
			(bX`temp'Xu: _b[avgboom_avg`temp'_avgunem]/(1-_b[l.avgln_tm])-_b[avgboom_avg`temp'_avgunem]), post
			
			local `v'mm_pst ``v'mm_pst' `v'b`i'wf`j'_pst
		} 
	}
}
* note at the end of this session, all local macros disapper 
global dgmm `dgmm'
global sgmm `sgmm'
global dgmm_pst `dgmm_pst'
global sgmm_pst `sgmm_pst'


       /* DIFFGMM SYSGMM estimators loops over different lag lengths */

* specify the maximum of the max_lag for loop
qui: sum nwyear
local max_max_lag = r(max) - 1

* set mata prefernce speed over space
mata: mata set matafavor speed, perm

* define macro for 4 types of estimations 
local dinc_maxlag
local dhlth_maxlag
local sysinc_maxlag
local syshlth_maxlag

local dinc_maxlag_pst
local dhlth_maxlag_pst
local sysinc_maxlag_pst
local syshlth_maxlag_pst
	
* loop 
forvalues i = 2/`max_max_lag' {

	local idiff = `i' + 1
	
	while (`idiff'<=`max_max_lag') { 
	
	qui: eststo dinc_maxlag`idiff': xtabond2 L(0/1).avgln_tm ///
               avgunem avgboom#c.avgincapacity#c.avgunem c.avgincapacity#c.avgunem ///
               L(0/1).($avgcovariates) d_nwyear* , ///
	gmm(avgln_tm , laglimits(2 `idiff')) ///
	iv( d_nwyear*  ,equation(level)) /// 
	iv(avgunem avgboom#c.avgincapacity#c.avgunem c.avgincapacity#c.avgunem L(0/1).($avgcovariates), passthru) ///
               nolevel robust small  twostep artests(7) 
			   
	qui: estadd local max_lag "`idiff'", replace
	qui: estadd local gmm "Difference", replace
	qui: estadd local stts "Incapacity", replace
	qui: estadd local smpl "5 year", replace 
	
	* nonlinear combination to obtain the long run estimates  
	eststo dinc_maxlag`idiff'_pst : /// 
	nlcom (u:_b[avgunem]/(1-_b[l.avgln_tm]) - _b[avgunem]) ///
	(incapacityXu: _b[c.avgincapacity#c.avgunem]/(1-_b[l.avgln_tm])-_b[c.avgincapacity#c.avgunem]) ///
	(bXincapacityXu: _b[1.avgboom#c.avgincapacity#c.avgunem]/(1-_b[l.avgln_tm])-_b[1.avgboom#c.avgincapacity#c.avgunem]), post
		
	
	qui: eststo dhlth_maxlag`idiff': xtabond2 L(0/1).avgln_tm ///
               avgunem avgboom#c.avghealth#c.avgunem c.avghealth#c.avgunem ///
               L(0/1).($avgcovariates) d_nwyear* , ///
	gmm(avgln_tm , laglimits(2 `idiff')) ///
	iv( d_nwyear*  ,equation(level)) /// 
	iv(avgunem avgboom#c.avghealth#c.avgunem c.avghealth#c.avgunem L(0/1).($avgcovariates), passthru) ///
               nolevel robust small  twostep artests(7) 
			   
	qui: estadd local max_lag "`idiff'", replace
	qui: estadd local gmm "Difference", replace
	qui: estadd local stts "Health", replace
	qui: estadd local smpl "5 year", replace 
	
	* nonlinear combination to obtain the long run estimates  
	eststo dhlth_maxlag`idiff'_pst : /// 
	nlcom (u:_b[avgunem]/(1-_b[l.avgln_tm]) - _b[avgunem]) ///
	(healthXu: _b[c.avghealth#c.avgunem]/(1-_b[l.avgln_tm])-_b[c.avghealth#c.avgunem]) ///
	(bXhealthXu: _b[1.avgboom#c.avghealth#c.avgunem]/(1-_b[l.avgln_tm])-_b[1.avgboom#c.avghealth#c.avgunem]), post
	
	
	local dinc_maxlag `dinc_maxlag' dinc_maxlag`idiff'
	local dhlth_maxlag `dhlth_maxlag' dhlth_maxlag`idiff'
	local dinc_maxlag_pst `dinc_maxlag_pst' dinc_maxlag`idiff'_pst
	local dhlth_maxlag_pst `dhlth_maxlag_pst' dhlth_maxlag`idiff'_pst
	
		* jump out the while loop
		continue,break
	} 

	qui: eststo sysinc_maxlag`i': xtabond2 L(0/1).avgln_tm ///
               avgunem avgboom#c.avgincapacity#c.avgunem c.avgincapacity#c.avgunem ///
               L(0/1).$avgcovariates d_nwyear* ,  ///
	gmm(avgln_tm , laglimits(2 `i')) ///
	iv( d_nwyear*  ,equation(level)) /// 
	iv(avgunem avgboom#c.avgincapacity#c.avgunem c.avgincapacity#c.avgunem L(0/1).$avgcovariates ) ///
	robust small  twostep artests(7) 
	
	qui: estadd local max_lag "`i'", replace
	qui: estadd local gmm "System", replace
	qui: estadd local stts "Incapacity", replace
	qui: estadd local smpl "5 year", replace 
	
	* nonlinear combination to obtain the long run estimates  
	eststo sysinc_maxlag`i'_pst : /// 
	nlcom (u:_b[avgunem]/(1-_b[l.avgln_tm]) - _b[avgunem]) ///
	(incapacityXu: _b[c.avgincapacity#c.avgunem]/(1-_b[l.avgln_tm])-_b[c.avgincapacity#c.avgunem]) ///
	(bXincapacityXu: _b[1.avgboom#c.avgincapacity#c.avgunem]/(1-_b[l.avgln_tm])-_b[1.avgboom#c.avgincapacity#c.avgunem]), post

	qui: eststo syshlth_maxlag`i': xtabond2 L(0/1).avgln_tm ///
               avgunem avgboom#c.avghealth#c.avgunem c.avghealth#c.avgunem ///
               L(0/1).$avgcovariates d_nwyear* ,  ///
	gmm(avgln_tm , laglimits(2 `i')) ///
	iv( d_nwyear*  ,equation(level)) /// 
	iv(avgunem avgboom#c.avghealth#c.avgunem c.avghealth#c.avgunem L(0/1).$avgcovariates ) ///
	robust small  twostep artests(7) 
	
	qui: estadd local max_lag "`i'", replace
	qui: estadd local gmm "System", replace
	qui: estadd local stts "Health", replace
	qui: estadd local smpl "5 year", replace 
	
	* nonlinear combination to obtain the long run estimates  
	eststo syshlth_maxlag`i'_pst : /// 
	nlcom (u:_b[avgunem]/(1-_b[l.avgln_tm]) - _b[avgunem]) ///
	(healthXu: _b[c.avghealth#c.avgunem]/(1-_b[l.avgln_tm])-_b[c.avghealth#c.avgunem]) ///
	(bXhealthXu: _b[1.avgboom#c.avghealth#c.avgunem]/(1-_b[l.avgln_tm])-_b[1.avgboom#c.avghealth#c.avgunem]), post
	
	local sysinc_maxlag `sysinc_maxlag' sysinc_maxlag`i'
	local syshlth_maxlag `syshlth_maxlag' syshlth_maxlag`i'
	local sysinc_maxlag_pst `sysinc_maxlag_pst' sysinc_maxlag`i'_pst
	local syshlth_maxlag_pst `syshlth_maxlag_pst' syshlth_maxlag`i'_pst
	
}

global dinc_maxlag `dinc_maxlag'
global dhlth_maxlag `dhlth_maxlag'
global sysinc_maxlag `sysinc_maxlag'
global syshlth_maxlag `syshlth_maxlag'
global dinc_maxlag_pst `dinc_maxlag_pst'
global dhlth_maxlag_pst `dhlth_maxlag_pst'
global sysinc_maxlag_pst `sysinc_maxlag_pst'
global syshlth_maxlag_pst `syshlth_maxlag_pst'


         /* Weak iv tests for DIFF GMM and SYS GMM estimators */

* specify the maximum of the max_lag for loop
		 
* define macro for 4 types of estimations 
local dgmmwivincp
local dgmmwkivhlth
local sysgmmwivincp
local sysgmmwivhlth

* loops
forvalues i = 2/`max_max_lag' {

	* diff GMM requires one more period for overidentification compared to system GMM
	local idiff = `i' + 1
	
	while (`idiff'<=`max_max_lag') { 
	
		* diff gmm + incapacity 
		qui: eststo dgmmwivincp`idiff': xtabond2 L(1).avgln_tm ///
               avgunem avgboom#c.avgincapacity#c.avgunem c.avgincapacity#c.avgunem ///
               L(0/1).($avgcovariates) d_nwyear* , ///
		gmm(avgln_tm , laglimits(2 `idiff')) ///
		iv( d_nwyear*  ,equation(level)) /// 
		iv(avgunem avgboom#c.avgincapacity#c.avgunem c.avgincapacity#c.avgunem L(0/1).($avgcovariates), passthru) ///
               nolevel robust small  twostep nodiffsargan

		qui: estadd local gmm "Difference", replace
		qui: estadd local stts "Incapacity", replace
		qui: estadd local max_lag "`idiff'", replace
		qui: estadd local smpl "5 year", replace 
	
		local  dgmmwivincp `dgmmwivincp' dgmmwivincp`idiff' 

	
		* diff gmm + health
		qui: eststo dgmmwkivhlth`idiff': xtabond2 L(1).avgln_tm ///
               avgunem avgboom#c.avghealth#c.avgunem c.avghealth#c.avgunem ///
               L(0/1).($avgcovariates) d_nwyear* , ///
		gmm(avgln_tm , laglimits(2 `idiff')) ///
		iv( d_nwyear*  ,equation(level)) /// 
		iv(avgunem avgboom#c.avghealth#c.avgunem c.avghealth#c.avgunem L(0/1).($avgcovariates), passthru) ///
               nolevel robust small  twostep nodiffsargan

		qui: estadd local gmm "Difference", replace
		qui: estadd local stts "Health", replace
		qui: estadd local max_lag "`idiff'", replace
		qui: estadd local smpl "5 year", replace 
	
		local dgmmwkivhlth `dgmmwkivhlth' dgmmwkivhlth`idiff'	
		
		* jump out the while loop
		continue,break
	} 

	* sys gmm + incapacity		
	
	qui: eststo sysgmmwivincp`i': xtabond2 L.avgln_tm ///
               avgunem avgboom#c.avgincapacity#c.avgunem c.avgincapacity#c.avgunem ///
               L(0/1).$avgcovariates d_nwyear* ,  ///
	gmm(avgln_tm , laglimits(2 `i')) ///
	iv( d_nwyear*  ,equation(level)) /// 
	iv(avgunem avgboom#c.avgincapacity#c.avgunem c.avgincapacity#c.avgunem L(0/1).$avgcovariates ) ///
	robust small  twostep nodiffsargan
    
	qui: estadd local gmm "System", replace
	qui: estadd local stts "Incapacity", replace
	qui: estadd local max_lag "`i'", replace
	qui: estadd local smpl "5 year", replace 
	
	local sysgmmwivincp `sysgmmwivincp' sysgmmwivincp`i'


	* sys gmm + health

	qui: eststo sysgmmwivhlth`i': xtabond2 L.avgln_tm ///
               avgunem avgboom#c.avghealth#c.avgunem c.avghealth#c.avgunem ///
               L(0/1).$avgcovariates d_nwyear* ,  ///
	gmm(avgln_tm , laglimits(2 `i')) ///
	iv( d_nwyear*  ,equation(level)) /// 
	iv(avgunem avgboom#c.avghealth#c.avgunem c.avghealth#c.avgunem L(0/1).$avgcovariates ) ///
	robust small  twostep nodiffsargan
			   
	qui: estadd local gmm "System", replace
	qui: estadd local stts "Health", replace
	qui: estadd local max_lag "`i'", replace
	qui: estadd local smpl "5 year", replace 
	
	local sysgmmwivhlth `sysgmmwivhlth' sysgmmwivhlth`i'

}

global dgmmwivincp `dgmmwivincp'
global dgmmwkivhlth `dgmmwkivhlth'
global sysgmmwivincp `sysgmmwivincp'
global sysgmmwivhlth `sysgmmwivhlth'



frame change default


