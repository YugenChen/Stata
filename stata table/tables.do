

* run the static models and micro based dynamic models withou its outputs 
* this is the same as 
*    qui do "setup\regression analysis.do"
*  or 
*    do "setup\regression analysis.do"
*    cls //  clear results window

 run "setup\regression analysis.do"
 

********************************************************************************
/////////////////////////make a table to summarize ////////////////////// 
********************************************************************************
 
separate unem if 1980<year & year<1985, by(year) gen(unemployment)
* tab country if 1980<year & year<1985 & unem!= .

eststo summary02: estpost tabstat unemployment????, by(country) ///
statistics(mean) columns(statistics) nototal  quietly

* Such table only has one model (typical in summary tables) and one column which
* denotes the mean. But using esttab's unstack option makes it several columns 
* indicating 7 countries. Even in this case, collabel option will still think there
* is only one column. 

capture program drop Sm02TbSt

qui: ///
program define Sm02TbSt

esttab summary02 , ///
///  
title(Unemployment Rate (7 Countries, 1981-1984)) ///
nonumbers nomtitles ///
///
nonumbers nomtitles ///
 ///
cell("mean(fmt(%6.3f))") ///
unstack ///
///
label coeflabels(unemployment1981 "1981" ///
unemployment1982 "1982" unemployment1983 "1983" unemployment1984 "1984" )  ///
collabel(" ") ///
///
noobs ///
/// 
addnotes(Note: ......) 



end

Sm02TbSt


cap program drop Sm02TbLtx

qui: ///
program define Sm02TbLtx

esttab summary02 ///
using "table.tex", replace ///
///  
prehead(\begin{table}[htbp] ///
\centering  ///
\begin{threeparttable} ///
\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi} ///
\caption{Unemployment Rate (7 Countries, 1981-1984)\label{tab0}} ///
\begin{tabular}{p{1cm}*{@span}{c}}  \hline\hline ) ///
///
nonumbers nomtitles ///
posthead( \hline) ///
cell("mean(fmt(%6.3f))") ///
unstack ///
///
label coeflabels(unemployment1981 "1981" ///
unemployment1982 "1982" unemployment1983 "1983" unemployment1984 "1984" )  ///
collabel(" ") ///
///
noobs ///
/// 
postfoot(\hline\hline \end{tabular} ///
\begin{tablenotes}[flushleft]       ///
      \small \item \textit{\footnotesize Note: ....... }\\     ///
\end{tablenotes} \end{threeparttable} \end{table} ) ///
fragment

end

Sm02TbLtx

********************************************************************************
//////make a table to summarize the comparison bwtween with and without specific
//////trends equation in pols, fe and re//////////////////////////////////////// 
********************************************************************************

				/***** Table shown in stata window *****/

				
eststo summary: estpost sum ln_tm unem s_unem l_unem $covariates ln_pop health incapacity, quietly 
				
				
capture program drop SmTbSt

qui: ///
program define SmTbSt

			
* cell is estout option not the esttab option 
esttab summary , ///
///
title("Summary statistics of regression variables (36 countires, 1979-2016)") ///
nonumbers nomtitles ///
///
cell("mean(fmt(%6.2f))  sd(fmt(%6.2f)) min(fmt(%4.2f)) max(fmt(%4.2f))") ///
collabels("Mean" "Std.-Dev." "Min" "Max" ) ///
///
label  ///
coeflabels(health "Health programme net Expenditure Ratio" ///
incapacity "Incapacity programme net Expenditure Ratio") ///
///
noobs  ///
///
addnotes("Note: This analysis uses the unbalanced panel data. Log(M) is the logarithm of mortality rate which is dependent variable in regressions and the regressors are tabulated below the Log(M). Number of deaths and population data are collected from World Health Organization (WHO) Mortality Database, Log(GNI per capita) from World Bank national accounts database, unemployment rates (short-run, long-run(longer than 12 months), and aggergate unemployment) , ratio of education levels in population and the ratio of health-related protection programme net expenditure to GDP from OECD database.") 
   
* in the statistics table, there is one model and the mean, std, min and max are 4 columns within this model
* so it is poitless to use option mlabels; rather option collabels should be used.


end

SmTbSt


									/***** Table in latex *****/ 

* I only use the rows of table produced by stata.
* This means I have to specify the table-making in latex and copy and paste the title and notes 

capture program drop SmTbLtx

qui: ///
program define SmTbLtx


esttab summary ///
using "table0.tex", replace ///
///  
prehead(\begin{table}[htbp] ///
\centering  ///
\begin{threeparttable} ///
\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi} ///
\caption{Summary statistics of regression variables (36 countries, 1979-2016)\label{tab0}} ///
\begin{tabular}{p{6cm}*{@span}{c}}  \hline\hline ) ///
///
nonumbers nomtitles ///
cell("mean(fmt(%6.2f))  sd(fmt(%6.2f)) min(fmt(%4.2f)) max(fmt(%4.2f))") ///
collabels("Mean" "Std. Dev." "Min" "Max", ///
                         prefix({) suffix(}) )  /// adding { and } does not make any difference 
///
label coeflabels(health "Health programme net Expenditure Ratio" ///
incapacity "Incapacity programme net Expenditure Ratio")  ///
///
noobs ///
/// 
postfoot(\hline\hline \end{tabular} ///
\begin{tablenotes}[flushleft]       ///
      \small \item \textit{\footnotesize Note: This analysis uses the unbalanced panel data. Data source of Log(Mortality), Log(Population) and population rates of each age group is WHO Mortality database. Log(GNI (constant 2010 USD) per capita) data is from World Bank national accounts data while the data for rest of variables come from OECD database. Short run unemployment is defined as being unemployed for less than 12 months and long-run one is defined as longer than 12 months.}\\     ///
\end{tablenotes} \end{threeparttable} \end{table} )
 
  
 
* option fragment hard-code the table's environment and have esttab just produce the table rows rather than a table  
* option collabels is used to label the collumn name. 
*  @M returns the # of models but in statistics table, there is only one model. So I use @span intead which returns one
*     more column but it is fine. 


end 

SmTbLtx

********************************************************************************
//////make a table to summarize the comparison bwtween with and without specific
//////trends equation in pols, fe and re//////////////////////////////////////// 
********************************************************************************


				/***** Table shown in stata window *****/

capture program drop XtTbSt

qui: ///
program define XtTbSt

				
esttab ///
          fe_bsl pls_bsl re_bsl fe_bsl_wtt pls_bsl_wtt re_bsl_wtt ///
, ///
title("FE,POLS,RE estimates for baseline equation (36 countires, 1981-2016)") ///
///
keep(unem) ///
///
label ///
///
b(%9.5f) se(%9.4f) star(* 0.1 ** 0.05 *** 0.01) ///
///
scalars("pstt Country specific time-trend included" ///
        "gtt General time-trend included" ///
		"est Estimator" /// 
        "corr Correlation between fixed effects and country specifc fitted dependent variable" ///
        "sigma_u Variance of fixed effect" ///
		"sigma_e Variance of idiosyncratic error" ) ///
obslast ///
sfmt(%9.2f)	///	
/// 						   
nonotes addnotes("Note: The dependent variable is logarithm of mortality and additional regressors include unemployment, education level, age, and log GNI per capita. Fixed effects include the unobserved and observed country specific time-invariant characteristics. Cluster-robust standard errors are reported in the parenthesis. *, **, *** denotes for .1, .005 and .001 significance respectively.")  


end


XtTbSt
									/***** Table in latex *****/ 

capture program drop XtTbLtx

qui: ///
program define XtTbLtx

esttab ///
          fe_bsl pls_bsl re_bsl fe_bsl_wtt pls_bsl_wtt re_bsl_wtt ///
using "table1.tex", replace ///
///
prehead( \begin{table}[htbp] \centering \begin{threeparttable} ///
\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}  ///
\caption{FE,POLS,RE estimates (in \%) for baseline equation Eq \ref{eq:static} (36 Countries, 1981-2016)\label{tab1}} ///
\begin{tabular}{p{3.5cm}*{@M}{c}}  \hline\hline )  ///   @M returns the # of models
///
keep(unem) ///
///
label ///
b(%9.5f) se(%9.4f) star(* 0.1 ** 0.05 *** 0.01) ///
///
scalars("pstt Country specific time-trend included" ///
        "gtt General time-trend included" ///
		"est Estimator" /// 
        "corr Correlation between fixed effects and country specifc fitted dependent variable" ///
        "sigma_u Variance of fixed effect" ///
		"sigma_e Variance of idiosyncratic error" ) ///
obslast  sfmt(%9.2f) ///
///
postfoot(\hline\hline \end{tabular}  ///
\begin{tablenotes}[flushleft]     /// 
\small \item \textit{\footnotesize Note: The dependent variable is logarithm of mortality and regressors include unemployment, education level, age, and log GNI per capita. Fixed effects here refer to the unobserved and observed country specific time-invariant characteristics. Cluster-robust standard errors are reported in the parenthesis. *, **, *** denotes for .1, .005 and .001 significance respectively.}\\  ///
\end{tablenotes} \end{threeparttable} \end{table} )



/*

	
	The begin and end table environment is specified by the options -prehead- and -postfoot- which override the title and footnote 
	in the table (-nonotes- is redundant here). This is not concerned since I would directly write title and footnote in latex. 
	
	Another issue is the usage of -prehead- and -postfoot- also eliminates other unnecessary lines in the tex output from stata which 
	means the option -fragment- is unnecessary as well in this case. These unnecessary lines are what esttab produce to make table but 
	these are not threeparttable environment. 

*/

end


XtTbLtx


********************************************************************************
/////////////////////////Static Models table////////////////////////////////////
********************************************************************************
 
				/***** Table shown in stata window *****/ 

capture program drop StTbSt

qui: ///
program define StTbSt

				
esttab ///
           fe_bsl_aswf1 fe_bsl_aswf2 fe_bsl_asy fe_bsl ,   ///	  
title("Fixed effect estimates for static models with Asymmetric effects and Heterogeneous effects\label{tab2}") ///
mgroups( "Asymmetry" "Non-Asymmetry", ///
         pattern (1 0 0 1) ///
		lhs("Model Specification") ) ///
mlabels("Heterogeneity" "Heterogeneity" "Non-Heterogeneity" "\citet{ruhmoecd}") ///
///
keep( /// 
1.boom#c.unem 0.boom#c.unem /// // asy 
unem /// // base
1.boom#c.health#c.unem c.health#c.unem ) /// // asy + hetero 
order( /// 
1.boom#c.unem 0.boom#c.unem /// 
unem /// 
1.boom#c.health#c.unem c.health#c.unem ) /// 
///
label interaction(" X ")  ///
rename( ///
1.boom#c.incapacity#c.unem  1.boom#c.health#c.unem /// 
c.incapacity#c.unem c.health#c.unem ) ///
/// 
b(%9.5f) se(%9.4f) star(* 0.1 ** 0.05 *** 0.01) ///
///
wrap  nogaps ///
///
scalars("pstt Country specific time-trend" ///
		"asy Asymmetric effect" ///
		"stts Expenditure ratio of social program" ///
		"smpl Time unit in panel") ///
obslast  sfmt(%9.2f) /// 
///						   
nonotes addnotes("Note: Dependent variable is logarithm of mortality rates and regressors include unemployment, education level, age, log GNI per capita and panel-specific trends. The expenditure ratio of social program indicates the source of heterogeneity: it can be related to the incapacity or health programme and measured by the relative expenditure of such programme to contemporary GDP. Cluster-robust standard errors are reported in the parenthesis. *, **, *** denotes for .1, .005 and .001 significance respectively.")  

* collabels option writes the same thing for all models. 
* collabels("?" "??"), "?" is for the first and "??" the second. Since each model only has one columns, you only see "?"

* wrap option wraps the long text when it is possible.
* Ex: in the regression table, each variable has two rows-- one for estimate and one for se. 
*     in this case, the long variable text can be wrapped into two lines.    

end


StTbSt


									/***** Table in latex *****/ 
 

capture program drop StTbLtx

qui: ///
program define StTbLtx

 
esttab ///
           fe_bsl_aswf1 fe_bsl_aswf2 fe_bsl_asy fe_bsl  ///
using "table2.tex", replace ///
///
prehead( \begin{table}[htbp] \centering \begin{threeparttable} ///
\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi} ///
\caption{FE estimates (in \%) for static models (36 Countries, 1981-2016)\label{tab2}} ///
\begin{tabular}{p{5cm}*{@M}{c}}  \hline\hline  ) ///   
///
mgroups( "Heterogeneity Eq. 1" "None Heterogeneity" "Gerdtham and Rhum(2006)", ///
         pattern (1 0 0 1) ///
		 span prefix(\multicolumn{@span}{c}{) suffix(}) ///
		 erepeat(\cmidrule(lr){@span}) /// add underlines for super column tile
		lhs("Model Specification") ) ///
mtitle("Heterogeneity" "Heterogeneity" "Non-Heterogeneity" "\citet{ruhmoecd}") ///
///
keep( /// 
1.boom#c.unem 0.boom#c.unem /// // asy 
unem /// // base
1.boom#c.health#c.unem c.health#c.unem ) /// // asy + hetero 
order( /// 
0.boom#c.unem 1.boom#c.unem /// 
unem /// 
c.health#c.unem 1.boom#c.health#c.unem) /// 
///
label  ///
coeflabels(1.boom#c.health#c.unem "$\triangle \times $ ExpenditureRatio $\times$ UnemploymentRate ") ///
rename( ///
1.boom#c.incapacity#c.unem  1.boom#c.health#c.unem /// 
c.incapacity#c.unem c.health#c.unem ) ///
///
b(%9.5f) se(%9.4f) star(* 0.1 ** 0.05 *** 0.01) ///   
///
nogaps wrap ///
///
scalars("pstt Country specific time-trend" ///
		"asy Asymmetric effect" ///
		"stts Expenditure ratio of social program" ///
		"smpl Time unit in panel") ///
obslast  sfmt(%9.2f) /// 
///						   
postfoot(\hline\hline \end{tabular} \begin{tablenotes}[flushleft] ///
\small \item \textit {\footnotesize Note: Dependent variable is logarithm of mortality rates and covariates include education level, age, log GNI per capita and panel-specific trends. Regressors having coefficient of interest are listed in the table. Boom and Bust are used to label when boom indicator dummy takes value of 1 and 0 respectively, and $\triangle$ captures the difference between Boom and Bust. The expenditure ratio is the relative expenditure of such programme to contemporary GDP. Estimation uses the unbalanced panel data from 36 OECD countries and average time span is 15.9 years. Cluster-robust standard errors are reported in the parenthesis. *, **, *** denotes for .1, .005 and .001 significance respectively.}\\  ///
\end{tablenotes} \end{threeparttable} \end{table}) 

* nogaps works for regression table rather than statistics table 


end 

StTbLtx


********************************************************************************
/////////////////////Micro based Dynamic Models table///////////////////////////
********************************************************************************


					/***** Table shown in stata window *****/

capture program drop MiTbSt

qui: ///
program define MiTbSt

					
esttab ///
		   fe_bsl_aswf1 fe_bsl_asdnwf1   ///
		   fe_bsl_aswf2  fe_bsl_asdnwf2,  ///
title("FE estimates for decomposition models with Asymmetric effects and Heterogeneous effects (36 counties, 1981-2016) \label{tab3}") ///
///
keep( /// 
unem 1.boom#c.health#c.unem c.health#c.unem  /// // asy + hetero 
s_unem 1.boom_s#c.s_unem#c.health c.health#c.s_unem  /// // asy + hetero + short run
l_unem 1.boom_l#c.l_unem#c.health c.health#c.l_unem ) /// // asy + hetero + long run
order( ///  
unem 1.boom#c.health#c.unem c.health#c.unem  /// 
s_unem 1.boom_s#c.s_unem#c.health c.health#c.s_unem  /// // 
l_unem 1.boom_l#c.l_unem#c.health c.health#c.l_unem ) /// // 
///
refcat(unem "---Static:" ///
s_unem "---Short Run:" l_unem "---Long Run:",nolabel) /// 
label interaction(" X ") ///
rename( ///
1.boom#c.incapacity#c.unem 1.boom#c.health#c.unem /// asy + hetero
c.incapacity#c.unem c.health#c.unem ///
1.boom_s#c.s_unem#c.incapacity 1.boom_s#c.s_unem#c.health /// asy + hetero + short run 
c.incapacity#c.s_unem  c.health#c.s_unem ///
1.boom_l#c.l_unem#c.incapacity 1.boom_l#c.l_unem#c.health  /// asy + hetero + long run 
c.incapacity#c.l_unem c.health#c.l_unem ) ///
///
b(%9.5f) se(%9.4f)  star(* 0.1 ** 0.05 *** 0.01) ///
///
wrap nogaps ///
///
scalars("est Estimator" ///
		"pstt Country specific time-trend" ///
        "gtd General time(year) dummies" ///
		"asy Asymmetric effect" ///
		"stts Expenditure ratio of social program" ///
		"dny Dynamicism" ///
		"smpl Time unit in panel") ///
obslast  sfmt(%9.2f) /// 
///						   
nonotes addnotes("Note: The dependent variable is logarithm of mortality and regressors include unemployment, education level, age, log GNI per capita and panel-specific trends. The expenditure ratio of social program indicates the source of heterogeneity: it can be related to the incapacity or health programme and measured by the relative expenditure of such programme to contemporary GDP. Dynamism of decomposition stands for decomposition of unemployment into short and long run. Cluster-robust standard errors are reported in the parenthesis. *, **, *** denotes for .1, .005 and .001 significance respectively.") 			


end


MiTbSt


											/***** Table in latex *****/ 
	
capture program drop MiTbLtx

qui: ///
program define MiTbLtx


		
esttab ///
		   fe_bsl_aswf1 fe_bsl_asdnwf1   ///
		   fe_bsl_aswf2  fe_bsl_asdnwf2 ///
  using "table3.tex", replace ///
///
prehead(\begin{table}[htbp] \centering \begin{threeparttable}  ///
\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}  ///
\caption{FE estimates (in \%) for static model Eq \ref{eq:static} and dynamic decomposition model Eq \ref{eq:dynamicde} (36 Countries, 1981-2016)\label{tab3}} ///
\begin{tabular}{p{5cm}*{@M}{c}}  \hline\hline) ///   
///
keep( /// 
unem 1.boom#c.health#c.unem c.health#c.unem  /// // asy + hetero 
s_unem 1.boom_s#c.s_unem#c.health c.health#c.s_unem  /// // asy + hetero + short run
l_unem 1.boom_l#c.l_unem#c.health c.health#c.l_unem ) /// // asy + hetero + long run
order( ///  
unem c.health#c.unem 1.boom#c.health#c.unem /// 
s_unem c.health#c.s_unem  1.boom_s#c.s_unem#c.health /// // 
l_unem c.health#c.l_unem 1.boom_l#c.l_unem#c.health ) /// // 
///
refcat(unem "\\ \textit{---Static}:" ///
s_unem "\\ \textit{---Short Run}:" l_unem "\\ \textit{---Long Run}:",nolabel) /// 
label ///
coeflabels(  ///
1.boom#c.health#c.unem  "$\triangle \times $ ExpenditureRatio $\times$ UnemploymentRate"     ///
1.boom_s#c.s_unem#c.health "$\triangle \times $ ExpenditureRatio $\times$ ShortRun UnemploymentRate" ///
1.boom_l#c.l_unem#c.health "$\triangle \times $ ExpenditureRatio $\times$ LongRun UnemploymentRate") ///
rename( ///
1.boom#c.incapacity#c.unem 1.boom#c.health#c.unem /// asy + hetero
c.incapacity#c.unem c.health#c.unem ///
1.boom_s#c.s_unem#c.incapacity 1.boom_s#c.s_unem#c.health /// asy + hetero + short run 
c.incapacity#c.s_unem  c.health#c.s_unem ///
1.boom_l#c.l_unem#c.incapacity 1.boom_l#c.l_unem#c.health  /// asy + hetero + long run 
c.incapacity#c.l_unem c.health#c.l_unem ) ///
/// 
b(%9.5f) se(%9.4f) star(* 0.1 ** 0.05 *** 0.01) ///
///
nogaps wrap /// 
///
scalars("est Estimator" ///
		"pstt Country specific time-trend" ///
        "gtd General time(year) dummies" ///
		"asy Asymmetric effect" ///
		"stts Expenditure ratio of social program" ///
		"dny Dynamicism" ///
		"smpl Time unit in panel") ///
obslast  sfmt(%9.2f) /// 
///						   
postfoot(\hline\hline \end{tabular}  ///
\begin{tablenotes}[flushleft] ///
\small \item \textit{\footnotesize Note: The dependent variable is logarithm of mortality and covariates include education level, age, log GNI per capita and panel-specific trends. Regressors having coefficient of interest are listed in the table. Boom and Bust, ShortRun Boom and ShortRun Bust, LongRun Boom and LongRun Bust are used to label value 1 and 0 respectively of boom indicator dummy in corresponding context. For example, boom indicator is obtained from unemployment in static model and short-run, long-run unemployment in dynamic decomposition model. $\triangle$ captures the difference between Boom and Bust in corresponding setting. The expenditure ratio is the relative expenditure of such programme to contemporary GDP. Dynamism of decomposition stands for decomposition of unemployment into short and long run. Estimation uses the unbalanced panel data from 36 OECD countries and average time span is 15.9 years. Cluster-robust standard errors are reported in the parenthesis. *, **, *** denotes for .1, .005 and .001 significance respectively.}\\  ///
\end{tablenotes} \end{threeparttable} \end{table} ) 	
			

end


MiTbLtx			
			
* note the labels for the avg variables are defined only in the dpd frame thus 
* we have to switch back to dpd.
frame change dpd 

********************************************************************************
/////////////////////Macro based Dynamic Models table///////////////////////////
********************************************************************************

capture program drop MaTbSt

qui: ///
program define MaTbSt


esttab ///     
		fe_bsl_aswf1  ///       // Static for Incapacity
		fe_bsl_asdgwf1 ///      // DIFF GMM 
		fe_bsl_asdglsdvwf1 ///  // LSDV with DIFF GMM as initial 
		fe_bsl_assgwf1 ///      // SYS GMM
		fe_bsl_assglsdvwf1 ///  // LSDV with SYS GMM as initial
		fe_bsl_aswf2 ///        // Static for health
		fe_bsl_asdgwf2 ///      // DIFF GMM 
		fe_bsl_asdglsdvwf2 ///  // LSDV with DIFF GMM as initial 
		fe_bsl_assgwf2 ///      // SYS GMM
		fe_bsl_assglsdvwf2 ///  // LSDV with SYS GMM as initial
,  ///
title("Estimates for Koyck lag models with Asymmetric effects and Heterogeneous effects (36 counties, 1981-2016) \label{tab4}") ///
///
keep( ///
unem  1.boom#c.health#c.unem c.health#c.unem /// static 
avgunem avgboom_avghealth_avgunem avghealth_avgunem ) /// // LSDV estimations which serves as reference across model match 
order(  ///
unem   c.health#c.unem 1.boom#c.health#c.unem ///
avgunem  avghealth_avgunem avgboom_avghealth_avgunem ) ///
///
refcat(unem "---Static:" avgunem "---Contemporary effects:" ,nolabel) ///
label interaction(" X ") ///
/// note we need to match the same variable across 4 dynamic models (inc v.s. hlth; gmm, lsdv) ///
/// two static models (inc v.s. hlth)  /// 
rename( /// 
1.boom#c.incapacity#c.unem 1.boom#c.health#c.unem /// static
c.incapacity#c.unem c.health#c.unem ///
1.avgboom#c.avgincapacity#c.avgunem avgboom_avghealth_avgunem /// // GMM regressions for incapacity
c.avgincapacity#c.avgunem avghealth_avgunem /// 
1.avgboom#c.avghealth#c.avgunem avgboom_avghealth_avgunem /// // GMM regressions for health
c.avghealth#c.avgunem avghealth_avgunem /// 
avgboom_avgincapacity_avgunem avgboom_avghealth_avgunem  /// // LSDV estimations
avgincapacity_avgunem avghealth_avgunem ) ///
///
b(%9.5f) se(%9.4f) star(* 0.1 ** 0.05 *** 0.01) ///
///
wrap nogaps ///
///
noobs ///
///
postfoot( )

* long run

esttab ///
		fe_bsl_aswf1  ///           // Static for Incapacity
		fe_bsl_asdgwf1_pst ///      // DIFF GMM 
		fe_bsl_asdglsdvwf1_pst ///  // LSDV with DIFF GMM as initial 
		fe_bsl_assgwf1_pst ///      // SYS GMM
		fe_bsl_assglsdvwf1_pst ///  // LSDV with SYS GMM as initial
		fe_bsl_aswf2 ///            // Static for health
		fe_bsl_asdgwf2_pst ///      // DIFF GMM 
		fe_bsl_asdglsdvwf2_pst ///  // LSDV with DIFF GMM as initial 
		fe_bsl_assgwf2_pst ///      // SYS GMM
		fe_bsl_assglsdvwf2_pst ///  // LSDV with SYS GMM as initial
	 ,   ///
prehead( ) ///  get rid of double lines
nonumbers nomtitles ///
///
posthead( ) /// get rid of one line
///
keep(u healthXu bXhealthXu) /// post estimation results
order( u  healthXu bXhealthXu ) ///
///
refcat(u "---Accumulative effects:" ,nolabel) ///
rename( ///
incapacityXu healthXu  ///  //post estimation results
bXincapacityXu bXhealthXu ) ///
coeflabels( /// these variables are created by nlcom and are not the variables in dataset 
			u "UnemploymentRate" ///
			bXhealthXu "Boom X ExpenditureRatio X UnemploymentRate" /// 
			healthXu "ExpenditureRatio X UnemploymentRate" ) ///
///
b(%9.5f) se(%9.4f) star(* 0.1 ** 0.05 *** 0.01) ///
///
wrap nogaps ///
///
scalars("est Estimator" /// 
		"initial Initial consistent estimates used in bias correction for LSDV" ///
		"pstt Country specific time-trend" ///
        "gtd General time(year) dummies" ///
		"asy Asymmetric effect" ///
		"stts Expenditure ratio of social program" ///
		"dny Dynamicism" ///
		"smpl Time unit in panel") ///
obslast  sfmt(%9.2f) /// 
///						   
nonotes addnotes("Note: The dependent variable is logarithm of mortality and regressors include the first lagged logarithm of mortality rates, unemployment, education level, age, log GNI per capita and general time(year) dummies. The expenditure ratio of social program indicates the source of heterogeneity: it can be related to the incapacity or health programme and measured by the relative expenditure of such programme to contemporary GDP. Dynamism is specified as Koyck lag model where the direct estimates (say $\beta$) from regression stand for contemporary effects and the corresponding accumulative effect is equal to $\beta/(1-\alpha)-\beta$ where $\alpha$ is the estimates of lagged dependent variable. Kiviet (1995) specifies more large sample bias in LSDV which includes two terms of at most order $T^{-1}$ and $(NT)^{-1}$ respectively. Cluster-robust standard errors for GMM estimators and Bootstrap standard errors with repetion of 50 times standard errors for LSDV estimators are reported in the parenthesis. *, **, *** denotes for .1, .005 and .001 significance respectively.") 
	 

 end


MaTbSt

									/***** Table in latex *****/ 

									
capture program drop MaTbLtx

qui: ///
program define MaTbLtx


esttab ///     
		fe_bsl_aswf1  ///       // Static for Incapacity
		fe_bsl_asdgwf1 ///      // DIFF GMM 
		fe_bsl_asdglsdvwf1 ///  // LSDV with DIFF GMM as initial 
		fe_bsl_assgwf1 ///      // SYS GMM
		fe_bsl_assglsdvwf1 ///  // LSDV with SYS GMM as initial
		fe_bsl_aswf2 ///        // Static for health
		fe_bsl_asdgwf2 ///      // DIFF GMM 
		fe_bsl_asdglsdvwf2 ///  // LSDV with DIFF GMM as initial 
		fe_bsl_assgwf2 ///      // SYS GMM
		fe_bsl_assglsdvwf2 ///  // LSDV with SYS GMM as initial
using "table4.tex", replace ///
///
prehead(\begin{landscape} ///
\begin{table} \centering \begin{threeparttable} /// 
\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi} ///
\caption{GMM and bias-corrected LSDV Estimates (in \%) for dynamic Koyck lag model Eq \ref{eq:dynamicdpd} (36 Countries, 1981-2016)\label{tab4}} ///
\begin{tabular}{p{6cm}*{@M}{C{1.5cm}}} \hline\hline) ///   
///
keep( ///
unem  1.boom#c.health#c.unem c.health#c.unem /// static 
avgunem avgboom_avghealth_avgunem avghealth_avgunem ) /// // LSDV estimations which serves as reference in across model match 
order(  ///
unem  1.boom#c.health#c.unem c.health#c.unem ///
avgunem avgboom_avghealth_avgunem avghealth_avgunem ) ///
///
refcat(unem "\textit{---Static}:" avgunem "\textit{---Contemporary effects}:" ,nolabel) ///
label ///
coeflabels ( ///
avgboom_avghealth_avgunem "Boom $\times$ ExpenditureRatio $\times$ UnemploymentRate"  ///
avghealth_avgunem "ExpenditureRatio $\times$ UnemploymentRate"   /// 
) ///
/// note we need to match the same variable across 4 dynamic models (inc v.s. hlth; gmm, lsdv) ///
/// two static models (inc v.s. hlth)  /// 
rename( /// 
1.boom#c.incapacity#c.unem 1.boom#c.health#c.unem /// static
c.incapacity#c.unem c.health#c.unem ///
1.avgboom#c.avgincapacity#c.avgunem avgboom_avghealth_avgunem /// // GMM regressions for incapacity
c.avgincapacity#c.avgunem avghealth_avgunem /// 
1.avgboom#c.avghealth#c.avgunem avgboom_avghealth_avgunem /// // GMM regressions for health
c.avghealth#c.avgunem avghealth_avgunem /// 
avgboom_avgincapacity_avgunem avgboom_avghealth_avgunem  /// // LSDV estimations
avgincapacity_avgunem avghealth_avgunem ) ///
///
b(%9.5f) se(%9.4f) star(* 0.1 ** 0.05 *** 0.01) ///
///
nogaps wrap ///
///
noobs ///
///
fragment   
* I want to get rid of unnecessary lines at the end by -fragment- without option -postfoot-, which means
* I still can get the same by using postfoot(). 
* Note -fragment- does not override -prehead- 

/*
 Note here i use two appended tex to produce table.  
*/


* long run 
esttab ///
		fe_bsl_aswf1  ///           // Static for Incapacity
		fe_bsl_asdgwf1_pst ///      // DIFF GMM 
		fe_bsl_asdglsdvwf1_pst ///  // LSDV with DIFF GMM as initial 
		fe_bsl_assgwf1_pst ///      // SYS GMM
		fe_bsl_assglsdvwf1_pst ///  // LSDV with SYS GMM as initial
		fe_bsl_aswf2 ///            // Static for health
		fe_bsl_asdgwf2_pst ///      // DIFF GMM 
		fe_bsl_asdglsdvwf2_pst ///  // LSDV with DIFF GMM as initial 
		fe_bsl_assgwf2_pst ///      // SYS GMM
		fe_bsl_assglsdvwf2_pst ///  // LSDV with SYS GMM as initial
///
using "table4.tex", append ///
///
nonumbers nomtitles /// get rid of these 
///
posthead( ) /// * there is one \hline after model titles can be erased only by -posthead-
///
keep(u healthXu bXhealthXu) /// post estimation results
order( u bXhealthXu healthXu ) ///
///
refcat(u " \textit{---Accumulative effects}:" ,nolabel) ///
rename( ///
incapacityXu healthXu  ///  //post estimation results
bXincapacityXu bXhealthXu ) ///
coeflabels( /// these variables are created by nlcom and are not the variables in dataset 
			u "UnemploymentRate" ///
			bXhealthXu "Boom $\times$ ExpenditureRatio $\times$ UnemploymentRate" /// 
			healthXu "ExpenditureRatio $\times$ UnemploymentRate" ) ///
///
b(%9.5f) se(%9.4f) star(* 0.1 ** 0.05 *** 0.01) ///
///
nogaps wrap /// 
///
scalars("est Estimator" /// 
		"initial Initial consistent estimates used in bias correction for LSDV" ///
		"pstt Country specific time-trend" ///
        "gtd General time(year) dummies" ///
		"asy Asymmetric effect" ///
		"stts Expenditure ratio of social program" ///
		"dny Dynamicism" ///
		"smpl Time unit in panel") ///
obslast  sfmt(%9.2f) ///
///
postfoot(\hline\hline \end{tabular} \begin{tablenotes}[flushleft] ///
\small \item \textit{\footnotesize Note: The dependent variable is logarithm of mortality and covariates include the first lagged logarithm of mortality rates, education level, age, log GNI per capita and panel-specific trends. Regressors having coefficient of interest are listed in the table. Boom and Bust are used to label value 1 and 0 respectively of boom indicator dummy; $\triangle$ captures the difference between Boom and Bust. The expenditure ratio is the relative expenditure of such programme to contemporary GDP. In Koyck lag model, the direct estimates (say $\beta$) from regression stand for contemporary effects and the corresponding accumulative effect $\ddot{\beta}$ is equal to $\beta/(1-\eta)-\beta$ where $\eta$ is the estimates of lagged dependent variable. Estimation in static model (Eq \ref{eq:static}) uses the unbalanced panel data from 36 OECD countries and average time span is 15.9 years while 36 OECD countries and average time span is 4.5 years in dynamic Koyck model (Eq \ref{eq:dynamicdpd}). Difference & System GMM estimator do not exploit all lags and the reasonable lag length (up to 4th lag of $lnM_{it}$ for IVs for $lnM_{i,t-1}$ in Difference GMM and 2nd lag for IVs for $lnM_{i,t-1}$ in System GMM) is chosen according to Sanderson-Windmeijer individual conditional underidentification test for weak IVs. The rest regressors instrument by themselves. \cite{kiviet1995} specifies more accurate bias in LSDV which includes two terms of at most order $T^{-1}$, and $(NT)^{-1}$, respectively. 2nd-Step cluster-robust standard errors for GMM estimators and Bootstrap standard errors with repetition of 50 times standard errors for LSDV estimators are reported in the parenthesis. *, **, *** denotes for .1, .005 and .001 significance respectively.}\\ \\ ///
\end{tablenotes} \end{threeparttable} \end{table} ///
\end{landscape}) /// 
fragment
* -fragment- the same as the above, but here those unnecessary lines are in the beginning rather than the ending. 



end

MaTbLtx


********************************************************************************
// table of two panels in stata window
********************************************************************************

capture program drop TwPnTbSt

qui: ///
program define TwPnTbSt


**** Panel A 
noisily: ///
esttab ///     
		fe_bsl_aswf1  ///       // Static for Incapacity
		fe_bsl_asdgwf1 ///      // DIFF GMM 
		fe_bsl_asdglsdvwf1 ///  // LSDV with DIFF GMM as initial 
		fe_bsl_assgwf1 ///      // SYS GMM
		fe_bsl_assglsdvwf1 ///  // LSDV with SYS GMM as initial		
,  ///
title(Estimates for Koyck lag models with Asymmetric effects and Heterogeneous effects (36 counties, 1981-2016)) ///
posthead("{hline @width}" "Panel A: Incapacity Programme" "") ///   i use "" to insert blank lines and {hline @width} for solid lines 
///
keep( ///
unem  1.boom#c.incapacity#c.unem c.incapacity#c.unem /// static 
avgunem avgboom_avgincapacity_avgunem avgincapacity_avgunem ) /// // LSDV estimations which serves as reference in across model match 
order(  ///
unem  1.boom#c.incapacity#c.unem c.incapacity#c.unem ///
avgunem avgboom_avgincapacity_avgunem avgincapacity_avgunem ) ///
///
refcat(unem "---Static:"  avgunem "---Contemporary effects:" ,nolabel) ///
label interaction(" X ") ///
coeflabels ( ///
avgboom_avgincapacity_avgunem "Boom X ExpenditureRatio X UnemploymentRate"  ///
avgincapacity_avgunem "ExpenditureRatio X UnemploymentRate"   /// 
) ///
/// note we need to match the same variable across 4 dynamic models (inc v.s. hlth; gmm, lsdv) ///
/// two static models (inc v.s. hlth)  /// 
rename( /// 
1.avgboom#c.avgincapacity#c.avgunem avgboom_avgincapacity_avgunem /// // GMM regressions for incapacity
c.avgincapacity#c.avgunem avgincapacity_avgunem ) ///
///
b(%9.5f) se(%9.4f) star(* 0.1 ** 0.05 *** 0.01) ///
///
wrap nogaps ///
///
postfoot( ) // get rid of footnotes and one horizontal line 


**** Panel B
	
esttab ///     
		fe_bsl_aswf2 ///        // Static for health
		fe_bsl_asdgwf2 ///      // DIFF GMM 
		fe_bsl_asdglsdvwf2 ///  // LSDV with DIFF GMM as initial 
		fe_bsl_assgwf2 ///      // SYS GMM
		fe_bsl_assglsdvwf2 ///  // LSDV with SYS GMM as initial
, ///
nonumbers nomtitles ///
///
posthead("{hline @width}" "Panel B: Health Programme" "") ///
///
keep( ///
unem  1.boom#c.health#c.unem c.health#c.unem /// static 
avgunem avgboom_avghealth_avgunem avghealth_avgunem ) /// // LSDV estimations which serves as reference in across model match 
order(  ///
unem  1.boom#c.health#c.unem c.health#c.unem ///
avgunem avgboom_avghealth_avgunem avghealth_avgunem ) ///
///
refcat(unem "---Static" avgunem "---Contemporary effects" ,nolabel) ///
label interaction(" X ") ///
coeflabels ( ///
avgboom_avghealth_avgunem "Boom X ExpenditureRatio X UnemploymentRate"  ///
avghealth_avgunem "ExpenditureRatio X UnemploymentRate"   /// 
) ///
/// note we need to match the same variable across 4 dynamic models (inc v.s. hlth; gmm, lsdv) ///
/// two static models (inc v.s. hlth)  /// 
rename( /// 
1.avgboom#c.avghealth#c.avgunem avgboom_avghealth_avgunem /// // GMM regressions for health
c.avghealth#c.avgunem avghealth_avgunem ) ///
///
b(%9.5f) se(%9.4f) star(* 0.1 ** 0.05 *** 0.01) ///
///
wrap nogaps ///
///
fragment


**** Panel C
	
esttab ///     
		fe_bsl_aswf2 ///        // Static for health
		fe_bsl_asdgwf2 ///      // DIFF GMM 
		fe_bsl_asdglsdvwf2 ///  // LSDV with DIFF GMM as initial 
		fe_bsl_assgwf2 ///      // SYS GMM
		fe_bsl_assglsdvwf2 ///  // LSDV with SYS GMM as initial
, ///
prehead( ) ///
nonumbers nomtitles ///
///
posthead( ) ///
///
drop(*) ///
///
wrap nogaps ///
///
scalars("est Estimator" /// 
		"initial Initial consistent estimates used in bias correction for LSDV" ///
		"smpl Time unit in panel") ///
noobs sfmt(%9.2f) ///
///
nonotes addnotes("11111111111111111111111111111111")


* {hline @width} for solid lines; @hline for dash lines 



end 

TwPnTbSt




********************************************************************************
// table of two panels in latex
********************************************************************************

capture program drop TwPnTbLtx

qui: ///
program define TwPnTbLtx


**** Panel A 

esttab ///     
		fe_bsl_aswf1  ///       // Static for Incapacity
		fe_bsl_asdgwf1 ///      // DIFF GMM 
		fe_bsl_asdglsdvwf1 ///  // LSDV with DIFF GMM as initial 
		fe_bsl_assgwf1 ///      // SYS GMM
		fe_bsl_assglsdvwf1 ///  // LSDV with SYS GMM as initial		
using "table4_1.tex", replace ///
///
prehead(\begin{table} \centering \begin{threeparttable} /// 
\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi} ///
\caption{GMM and bias-corrected LSDV Estimates (in \%) for dynamic Koyck lag model Eq \ref{eq:dynamicdpd} (36 Countries, 1981-2016)\label{tab4}} ///
\begin{tabular}{p{6cm}*{@M}{C{1.5cm}}}  \hline\hline) /// specify the width for each column C{1.5cm} 
///
posthead("\hline \\ \multicolumn{@span}{c}{\textbf{Panel A: Incapacity Programme}} \\\\") ///
///
keep( ///
unem  1.boom#c.incapacity#c.unem c.incapacity#c.unem /// static 
avgunem avgboom_avgincapacity_avgunem avgincapacity_avgunem ) /// // LSDV estimations which serves as reference in across model match 
order(  ///
unem  1.boom#c.incapacity#c.unem c.incapacity#c.unem ///
avgunem avgboom_avgincapacity_avgunem avgincapacity_avgunem ) ///
///
refcat(unem "\textit{---Static}:" avgunem "\textit{---Contemporary effects}:" ,nolabel) ///
label ///
coeflabels ( ///
avgboom_avgincapacity_avgunem "Boom $\times$ ExpenditureRatio $\times$ UnemploymentRate"  ///
avgincapacity_avgunem "ExpenditureRatio $\times$ UnemploymentRate"   /// 
) ///
/// note we need to match the same variable across 4 dynamic models (inc v.s. hlth; gmm, lsdv) ///
/// two static models (inc v.s. hlth)  /// 
rename( /// 
1.avgboom#c.avgincapacity#c.avgunem avgboom_avgincapacity_avgunem /// // GMM regressions for incapacity
c.avgincapacity#c.avgunem avgincapacity_avgunem ) ///
///
b(%9.5f) se(%9.4f) star(* 0.1 ** 0.05 *** 0.01) ///
///
nogaps wrap ///
///
fragment

**** Panel B

esttab ///     
		fe_bsl_aswf2 ///        // Static for health
		fe_bsl_asdgwf2 ///      // DIFF GMM 
		fe_bsl_asdglsdvwf2 ///  // LSDV with DIFF GMM as initial 
		fe_bsl_assgwf2 ///      // SYS GMM
		fe_bsl_assglsdvwf2 ///  // LSDV with SYS GMM as initial
using "table4_1.tex", append ///
///
nonumbers nomtitles ///
/// 
posthead("\hline \\ \multicolumn{@span}{c}{\textbf{Panel B: Health Programme}} \\\\") ///
///
keep( ///
unem  1.boom#c.health#c.unem c.health#c.unem /// static 
avgunem avgboom_avghealth_avgunem avghealth_avgunem ) /// // LSDV estimations which serves as reference in across model match 
order(  ///
unem  1.boom#c.health#c.unem c.health#c.unem ///
avgunem avgboom_avghealth_avgunem avghealth_avgunem ) ///
///
refcat(unem "\textit{---Static}:" avgunem "\textit{---Contemporary effects}:" ,nolabel) ///
label ///
coeflabels ( ///
avgboom_avghealth_avgunem "Boom $\times$ ExpenditureRatio $\times$ UnemploymentRate"  ///
avghealth_avgunem "ExpenditureRatio $\times$ UnemploymentRate"   /// 
) ///
/// note we need to match the same variable across 4 dynamic models (inc v.s. hlth; gmm, lsdv) ///
/// two static models (inc v.s. hlth)  /// 
rename( /// 
1.avgboom#c.avghealth#c.avgunem avgboom_avghealth_avgunem /// // GMM regressions for health
c.avghealth#c.avgunem avghealth_avgunem ) ///
///
b(%9.5f) se(%9.4f) star(* 0.1 ** 0.05 *** 0.01) ///
///
nogaps wrap ///
///
fragment /// 



**** Panel C

esttab ///     
		fe_bsl_aswf2 ///        // Static for health
		fe_bsl_asdgwf2 ///      // DIFF GMM 
		fe_bsl_asdglsdvwf2 ///  // LSDV with DIFF GMM as initial 
		fe_bsl_assgwf2 ///      // SYS GMM
		fe_bsl_assglsdvwf2 ///  // LSDV with SYS GMM as initial
using "table4_1.tex", append ///
///
nonumbers nomtitles ///
/// 
posthead( ) ///
///
drop(*) ///
///
nogaps wrap ///
///
scalars("est \\Estimator" ///  * I insert one blank line by \\ 
		"initial Initial consistent estimates used in bias correction for LSDV" ///
		"smpl Time unit in panel") ///
noobs sfmt(%9.2f) ///
///
postfoot(\hline\hline \end{tabular} \begin{tablenotes}[flushleft] ///
\small \item \textit{\footnotesize Note: The dependent variable is logarithm of mortality and covariates include the first lagged logarithm of mortality rates, education level, age, log GNI per capita and panel-specific trends. Regressors having coefficient of interest are listed in the table. Boom and Bust are used to label value 1 and 0 respectively of boom indicator dummy; $\triangle$ captures the difference between Boom and Bust. The expenditure ratio is the relative expenditure of such programme to contemporary GDP. In Koyck lag model, the direct estimates (say $\beta$) from regression stand for contemporary effects and the corresponding accumulative effect $\ddot{\beta}$ is equal to $\beta/(1-\eta)-\beta$ where $\eta$ is the estimates of lagged dependent variable. Estimation in static model (Eq \ref{eq:static}) uses the unbalanced panel data from 36 OECD countries and average time span is 15.9 years while 36 OECD countries and average time span is 4.5 years in dynamic Koyck model (Eq \ref{eq:dynamicdpd}). Difference & System GMM estimator do not exploit all lags and the reasonable lag length (up to 4th lag of $lnM_{it}$ for IVs for $lnM_{i,t-1}$ in Difference GMM and 2nd lag for IVs for $lnM_{i,t-1}$ in System GMM) is chosen according to Sanderson-Windmeijer individual conditional underidentification test for weak IVs. The rest regressors instrument by themselves. \cite{kiviet1995} specifies more accurate bias in LSDV which includes two terms of at most order $T^{-1}$, and $(NT)^{-1}$, respectively. 2nd-Step cluster-robust standard errors for GMM estimators and Bootstrap standard errors with repetition of 50 times standard errors for LSDV estimators are reported in the parenthesis. *, **, *** denotes for .1, .005 and .001 significance respectively.}\\ \\ ///
\end{tablenotes} \end{threeparttable} \end{table} ) /// 
fragment



* -prehead- option can override title in stata window presentation wihtout @title. 
*  Ex: prehead("Panel A: Incapacity Programme" @title) /// 
*          however in the latex presentation, -prehead- can used to add upper-level of supper-column 

*  Latex: *{@M}{C{1.5cm}} means repeat C{1.5cm} @M times and note it is C{1.5cm} instead of c{1.5cm} 


end 

TwPnTbLtx


********************************************************************************
///////////////Weak iv tests for DIFF GMM and SYS GMM estimators////////////////
********************************************************************************

					/***** Table shown in stata window *****/

capture program drop WivPnTbSt

qui: ///
program define WivPnTbSt

* separate by the gmm  
local dg $dgmmwivincp $dgmmwkivhlth
local sg $sysgmmwivincp $sysgmmwivhlth


foreach v in "dg" "sg" {

    local Temp = cond("`v'"=="dg","Difference GMM","System GMM")
	
	esttab ``v'' , ///
    title("Sanderson-Windmeijer individual conditional underidentification tests for weak IV in `Temp' estimators\label{tab7}") ///
	prehead(@title)  ///
	///
	nomtitles nonumbers ///
	///
	posthead( ) ///
	///
	drop(*) /// 
	///
	wrap nogaps ///
	///
	scalars( "stts Expenditure ratio of social program" ///
			 "max_lag Maximum lag length" ///
			 /// "gmm GMM" ///  
			 "hansenp P-value of robust Hansen test" ///
			 "hansen_df dof of robust hansen test" ///
			 "j Number of IVs" /// 
			 "smpl Time unit in panel") ///
	obslast  sfmt(%6.2f) /// 
	///						   
	nonotes addnotes("Note: Dependent variable is the first lagged logarithm of mortality rates which is endogenoud regressor in Dynamic panel data model and regressors include unemployment, education level, age, log GNI per capita and general time dummies. The expenditure ratio of social program indicates the source of heterogeneity: it can be related to the incapacity or health programme and measured by the relative expenditure of such programme to contemporary GDP. Windmeijer(2018) shows in linear equation specification the robust Hansen test is equivalent to Sanderson-Windmeijer individual conditional underidentification tests for weak IV. ") 
	
	* above e-class scalars there is one line so  the line under the title is unnecessary. 
	* -prehead(@title)- is used to keep and title but eliminate the line under the title.
}

end 

WivPnTbSt


				/***** Table shown in Latex *****/

capture program drop WivPnTbLxt

qui: ///
program define WivPnTbLxt

* separate by the gmm  
local dg $dgmmwivincp $dgmmwkivhlth
local sg $sysgmmwivincp $sysgmmwivhlth


foreach v in "dg" "sg" {

    local Temp = cond("`v'"=="dg","Difference GMM","System GMM")
	
	esttab ``v'' ///
    using "table7weakiv_`v'.tex", replace ///
	///
	prehead( \begin{landscape}  ///
    \begin{table} \centering \begin{threeparttable} ///
    \def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi} ///
	\caption{Sanderson-Windmeijer individual conditional underidentification tests for weak IV in Difference GMM estimators (36 countries, 1979-2016)\label{tab7.1}} ///
    \begin{tabular}{p{3cm}*{@M}{c}} ) ///
	///
	nomtitles nonumbers ///
	///
	drop(*) /// 
	/// 
	nogaps wrap ///
	///
	scalars( "stts Expenditure ratio of social program" ///
			 "max_lag Maximum lag length" ///
			 /// "gmm GMM" ///  
			 "hansenp P-value of robust Hansen test" ///
			 "hansen_df dof of robust hansen test" ///
			 "j Number of IVs" /// 
			 "smpl Time unit in panel") ///
	obslast  sfmt(%6.2f) /// 
	///						   
postfoot(\hline\hline \end{tabular} \begin{tablenotes}[flushleft] ///
\small \item \textit{\footnotesize Note: Dependent variable is the first lagged logarithm of mortality rates which is endogenoud regressor in Dynamic panel data model and regressors include unemployment, education level, age, log GNI per capita and general time dummies. The expenditure ratio of social program indicates the source of heterogeneity: it can be related to the incapacity or health programme and measured by the relative expenditure of such programme to contemporary GDP. Windmeijer(2018) shows in linear equation specification the robust Hansen test is equivalent to Sanderson-Windmeijer individual conditional underidentification tests for weak IV. }\\ \\ ///
\end{tablenotes} \end{threeparttable} \end{table} ///
\end{landscape}) 
	
}

end 

WivPnTbLxt

****  The below is just examples of making tables by loops 

qui{

/*

********************************************************************************
//LSDV bias corrected estimators loops over different bounding orders and initial estimates
********************************************************************************

foreach v in "dgmm" "sgmm"{

	* check whether it is incapacity or health
	local Temp = cond("`v'"=="dgmm","Difference GMM","System GMM")
	
	esttab 	$`v' ///
	/// , ///
	using "regression results\table5_`v'.tex", ///
	title("Bias-corrected LSDV estimates in asymmetric Koyck lag models with initial `Temp' estimate\label{tab5}") ///
	nonumbers ///
	keep(avgunem avgboom_avghealth_avgunem avghealth_avgunem ) ///
	order(avgunem avgboom_avghealth_avgunem avghealth_avgunem ) ///
	refcat(avgunem "Contemporary effects:"  ,nolabel) ///
	label ///
	rename( ///
	avgboom_avgincapacity_avgunem avgboom_avghealth_avgunem ///
	avgincapacity_avgunem avghealth_avgunem) /// 
	coeflabels( avgunem "UnemploymentRate" ///
			avgboom_avghealth_avgunem "Boom $\times$ ExpenditureRatio $\times$ UnemploymentRate" ///
			avghealth_avgunem "ExpenditureRatio $\times$ UnemploymentRate" ) ///
	///
	b(%9.5f) star(* 0.1 ** 0.05 *** 0.01) ///
	se(%9.4f)  ///
	///
	scalars("stts Expenditure ratio of social program" ///
		"initial The initial estimates used for bias correction" ///
		"border Number of large sample bias approximation terms" /// 
		"smpl Time unit in panel") ///
	obslast  sfmt(%9.2f) /// 
	///						   
nonotes addnotes("Note: The dependent variable is logarithm of mortality and regressors include the first lagged logarithm of mortality rates, unemployment, education level, age, log GNI per capita and general time dummies. The expenditure ratio of social program indicates the source of heterogeneity: it can be related to the incapacity or health programme and measured by the relative expenditure of such programme to contemporary GDP. Large sample bias in LSDV can be approximated by three ways: one term of at most order of $T^{-1}$, two terms of at most order of $T^{-1}$ and $(NT)^{-1}$ respectively, and three terms of at most order of $T^{-1}$, $(NT)^{-1}$, and $N^(-1)*T^{-2}$ respectively, (Nickell, 1981; Kiviet, 1995,1999). Bootstrap standard errors with repetition of 50 times are reported in the parenthesis. *, **, *** denotes for .1, .005 and .001 significance respectively.")  ///
nogaps replace

}

* long run 
foreach v in "dgmm_pst" "sgmm_pst"{

	* check whether it is incapacity or health
	local Temp = cond("`v'"=="dgmm_pst","Difference GMM","System GMM")
	local name = cond("`v'"=="dgmm_pst","dgmm","sgmm")
	
	esttab 	$`v' ///
	/// , replace ///
	using "regression results\table5_`name'.tex", append ///
	nonumbers ///
	keep(u bXhealthXu healthXu) ///
	order(u bXhealthXu healthXu) ///
	refcat(u "Accumulative effects:"  ,nolabel) ///	
	rename( ///
	bXincapacityXu bXhealthXu ///
	incapacityXu healthXu) /// 
	b(%9.5f) star(* 0.1 ** 0.05 *** 0.01) ///
	se(%9.4f)  ///
    coeflabels( /// these variables are created by nlcom and are not the variables in dataset 
			u "UnemploymentRate" ///
			bXhealthXu "Boom $\times$ ExpenditureRatio $\times$ UnemploymentRate" /// 
			healthXu "ExpenditureRatio $\times$ UnemploymentRate" ) ///
	///
	nogaps

}



********************************************************************************
//////////DIFFGMM SYSGMM estimators loops over different lag lengths////////////
********************************************************************************
* separate by the gmm  
local dg $dinc_maxlag $dhlth_maxlag
local sg $sysinc_maxlag $syshlth_maxlag

foreach v in "dg" "sg"{

	* check whether it is dg or sg
	local Temp = cond("`v'"=="dg","Difference GMM","System GMM")
	
	esttab ``v'' ///
	///, ///
    using "regression results\gmmtable6_`v'.tex", ///
	title("Two-step `Temp' estimates in asymmetric Koyck lag models\label{tab6}") ///
	nonumbers ///
	keep(avgunem 1.avgboom#c.avghealth#c.avgunem c.avghealth#c.avgunem) ///
	order(avgunem 1.avgboom#c.avghealth#c.avgunem c.avghealth#c.avgunem) ///
	refcat(avgunem "Contemporary effects:"  ,nolabel) ///
	label ///
	rename( ///
	1.avgboom#c.avgincapacity#c.avgunem 1.avgboom#c.avghealth#c.avgunem ///
	c.avgincapacity#c.avgunem c.avghealth#c.avgunem) ///
	b(%9.5f) star(* 0.1 ** 0.05 *** 0.01) ///
	se(%9.4f) ///
	scalars( "stts Expenditure ratio of social program" ///
			 "max_lag Maximum lag length" ///
			 /// "gmm GMM" ///
			 "hansenp P-value of robust hansen test" ///
			 "ar2p AR(2) P-value" ///
			 "j Number of IVs" /// 
			 "smpl Time unit in panel") ///
	obslast  sfmt(%6.2f) /// 
	///						   
nonotes addnotes("Note: The dependent variable is logarithm of mortality and regressors include the first lagged logarithm of mortality rates, unemployment, education level, age, log GNI per capita and general time dummies. The expenditure ratio of social program indicates the source of heterogeneity: it can be related to the incapacity or health programme and measured by the relative expenditure of such programme to contemporary GDP. Two-step GMM robust standard errors are reported in the parenthesis. *, **, *** denotes for .1, .005 and .001 significance respectively.")  ///
nogaps	replace
	
}

// long run 
* separate by the gmm  
local dg $dinc_maxlag_pst $dhlth_maxlag_pst
local sg $sysinc_maxlag_pst $syshlth_maxlag_pst

foreach v in "dg" "sg"{

	* check whether it is dg or sg
	local Temp = cond("`v'"=="dg","Difference GMM","System GMM")
	
	esttab ``v'' ///
	///, replace ///
    using "regression results\table6gmm_`v'.tex", append ///
	nonumbers ///
	keep(u bXhealthXu healthXu) ///
	order(u bXhealthXu healthXu) ///
	refcat(u "Accumulative effects:"  ,nolabel) ///
	label ///
	rename( ///
	bXincapacityXu bXhealthXu ///
	incapacityXu healthXu) ///
	b(%9.5f) star(* 0.1 ** 0.05 *** 0.01) ///
	se(%9.4f) ///
	coeflabels( /// these variables are created by nlcom and are not the variables in dataset 
			u "UnemploymentRate" ///
			bXhealthXu "Boom $\times$ ExpenditureRatio $\times$ UnemploymentRate" /// 
			healthXu "ExpenditureRatio $\times$ UnemploymentRate" ) ///
    ///
	nogaps	  
	
}





frame change default

/*******************************************************************************
                                   -estpost-
*******************************************************************************/

// estpost posts results from various Stata commands in e() so that they can be 
// tabulated using esttab or estout. Type ereturn list after estpost to list 
// the elements saved in e().



/*******************************************************************************
                                   -esttab-
*******************************************************************************/

// If there are some bugs with -esttab-, try update the -estout- from ssc since 
// -esttab- mainly uses -estout-. -which esttab- returns the version of it.
// for -esttab- options:
// title(string)      specify a title for the table
// mtitles[(list)]    specify model titles to appear in table header
// indicate() option indicates for each model whether certain variables
//   are present in the model. For example, indicate("Year Fe=yd*") gives string 
//   "Yes" in row by name of Year Fe for the model where there is any variable's 
//   name starting from yd. 
// addnotes("Line 1" "Line 2") adds the notes line 
// nonotes suppress the default notes of the table
// interaction(string) specifies the string to be used as a delimiter for interaction terms. 
//   The default is interaction(" # ").
// numbers includes a row containing consecutive model numbers in the table header. 
//   This is the default. Specify nonumbers to suppress printing the model numbers.
// alignment(center) works if you want the output format is latex or ... 
// coeflabels(name label [...]) uses the label defined in the bracket for the 
//   regressors instead of var name
// label uses previously stored label for all things in the table. 
// obslast can place the N at the last row in the table
// se(%w.df) askes to display se in place of t-statistics and the %f format 
//            means the result should be of w digit width including sign and
//            decimal point; d is the # of digits to appear to the right of the
//            decimal point. 
// p-value and se option cannot be used simultaneouly
// If dont't what should be written down in -drop/keep- option, try -coeflegend- in regression command
// option to reveal it.
// Command -estadd-:
// estadd local asymetric_effect "Yes", replace
//  etsto ....
//  esttab ... , scalars("asymetric_effect asymetric effect") title() mtitle()
//                        "local name + space + label for display"
// note -stats- is estout option which takes precedence over esttab option -scalar- 
// -nogaps- can suppress the extra spacing 
// -rename- can match coefficients across models: renmae(altmpg mpg altweight weight) produces the table where
//   altmpg's coefficients are in the same row of mpg and the variable legend "altmpg" changes to "mpg";
//   altweight's coefficients are in the same row of weight and the variable legend "altweight" changes to "weight"  
//   Note esttab will automatically omit the rows for altmpg and altweight as long as you don't use -keep- to let 
//   them show up.
// -refact-  adds rows in table. refact(mpg "This is:" , nolabel) produces table where mpg row is beneath the row
//   for "This is:" and -nolabel- suboption makes rest of entries in this row blank.   

*/
}
