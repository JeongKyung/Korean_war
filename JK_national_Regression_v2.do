*****************************************************************************************
************ Regression : estimating the effects of conflict on cooperation *************
************ Date: 2021/05/31, Last edited by JK Won ************************************
*****************************************************************************************

use "C:/Users/user/Dropbox/korean_war/GIS_control/merging_samaeul_with_geocontrol_data/final_samaeul_data_with_geocontrol.dta", clear
cd "C:/Users/user/Dropbox/korean_war/JK"

*Village level public use(dummy) is averaged at the township level with the number of village household as the weight.
*set dist_to_attac less than 65 based on histogram of dist_to_attack
histogram dist_to_attack, bin(10)
*excluded "경상도" whose dist_to_attack measure is likely to be wrong; "제주도" excluded as well.
*used different control variables based on correlation b/w vars.

****Table 1: Descriptive Statistics

eststo clear
estpost sum public_use dist_to_attack slope_med elev_med ltype_1_1 farmland_perhousehold localroad weighted_distance_hh   ///
if sido_nm!="경상남도"&sido_nm!="경상북도"&sido_nm!="제주도"&dist_to_attack<=65
esttab using desc_stats_v2.tex,replace /// 
refcat(public_use "\emph{Dependent Variable}" dist_to_attack "\vspace{0.1em} \\ \emph{Explanatory Variable}" ///
slope_med "\vspace{0.1em} \\ \emph{Controls}",nolabel) cells("count mean sd min max") nostar unstack nonumber ///
compress nomtitle nonote noobs gap label f collabels("Obs" "Mean" "St.D" "Min" "Max")


****Table 3: OLS and FE Estimates of the effects of the conflict on cooperation

*check scatterplot
twoway (scatter public_use dist_to_attack if sido_nm!="경상남도"&sido_nm!="경상북도"&sido_nm!="제주도"&dist_to_attack<=65) ///
(lfit public_use dist_to_attack if sido_nm!="경상남도"&sido_nm!="경상북도"&sido_nm!="제주도"&dist_to_attack<=65)


*Run Regression
set more off
eststo clear

*(1) no GIS controls, no fixed effect, no GIS controls, 

reg public_use dist_to_attack if sido_nm!="경상남도"&sido_nm!="경상북도"&sido_nm!="제주도"&dist_to_attack<=65, vce(cluster sig_cd) 
estimates store m1
estadd local GIS "N"
estadd local FE "N"
estadd local CR "N"

*(2) GIS controls, no fixed effect, no Samaeul controls , 

reg public_use dist_to_attack slope_med elev_med  ///
if sido_nm!="경상남도"&sido_nm!="경상북도"&sido_nm!="제주도"&dist_to_attack<=65, vce(cluster sig_cd)
estimates store m2
estadd local GIS "Y"
estadd local FE "N"
estadd local CR "N"

*(3) GIS controls, fixed effect, no Samaeul controls,

areg public_use dist_to_attack slope_med elev_med ///
if sido_nm!="경상남도"&sido_nm!="경상북도"&sido_nm!="제주도"&dist_to_attack<=65, absorb(sig_cd) vce(cluster sig_cd)
estimates store m3
estadd local GIS "Y"
estadd local FE "Y"
estadd local CR "N"

*(4) GIS controls, fixed effect, Samaeul controls

areg public_use dist_to_attack slope_med elev_med ltype_1_1 farmland_perhousehold localroad weighted_distance_hh  ///
if sido_nm!="경상남도"&sido_nm!="경상북도"&sido_nm!="제주도"&dist_to_attack<=65,absorb(sig_cd) vce(cluster sig_cd)

estimates store m4
estadd local GIS "Y"
estadd local FE "Y"
estadd local CR "Y"

esttab m1 m2 m3 m4 using table_3_v2.tex,replace keep(dist_to_attack) b p ///
nomtitles mgroups("Dependent variable: public_use", pattern(1 0 0 0) ///
span prefix(\multicolumn{@span}{c}{) suffix(})) r2 ///
scalars("GIS GIS controls" "FE County Fixed Effects" "CR Controls")


****Table 4. WLS Version of Table 3

*motivation for using wls

reg public_use dist_to_attack if sido_nm!="경상남도"&sido_nm!="경상북도"&sido_nm!="제주도"&dist_to_attack<=65, vce(cluster sig_cd) 
predict r, resid
scatter r dist_to_attack if sido_nm!="경상남도"&sido_nm!="경상북도"&sido_nm!="제주도"&dist_to_attack<=65,yline(0) // evidence of heteroscedasticity


*Run WLS 
set more off
eststo clear

*(1) no GIS controls, no fixed effect, no GIS controls, 

wls0 public_use dist_to_attack if sido_nm!="경상남도"&sido_nm!="경상북도"&sido_nm!="제주도"&dist_to_attack<=65, wvars(dist_to_attack) type(abse) noconst robust
estimates store m1
estadd local GIS "N"
estadd local FE "N"
estadd local CR "N"

*(2) GIS controls, no fixed effect, no Samaeul controls , 

wls0 public_use dist_to_attack slope_med elev_med  ///
if sido_nm!="경상남도"&sido_nm!="경상북도"&sido_nm!="제주도"&dist_to_attack<=65, wvars(dist_to_attack) type(abse) noconst robust
estimates store m2
estadd local GIS "Y"
estadd local FE "N"
estadd local CR "N"

*(3) GIS controls, fixed effect, no Samaeul controls,

xi:wls0 public_use dist_to_attack slope_med elev_med i.sig_cd ///
if sido_nm!="경상남도"&sido_nm!="경상북도"&sido_nm!="제주도"&dist_to_attack<=65, wvars(dist_to_attack) type(abse) noconst robust
estimates store m3
estadd local GIS "Y"
estadd local FE "Y"
estadd local CR "N"

*(4) GIS controls, fixed effect, Samaeul controls

xi:wls0 public_use dist_to_attack slope_med elev_med i.sig_cd ltype_1_1 farmland_perhousehold localroad weighted_distance_hh ///
if sido_nm!="경상남도"&sido_nm!="경상북도"&sido_nm!="제주도"&dist_to_attack<=65, wvars(dist_to_attack) type(abse) noconst robust
estimates store m4
estadd local GIS "Y"
estadd local FE "Y"
estadd local CR "Y"

esttab m1 m2 m3 m4 using table_3_wls_v2.tex,replace keep(dist_to_attack) b p ///
nomtitles mgroups("Dependent variable: public_use", pattern(1 0 0 0) ///
span prefix(\multicolumn{@span}{c}{) suffix(})) r2 ///
scalars("GIS GIS controls" "FE County Fixed Effects" "CR Controls")


/**WLS Attempt 2

*(1) no Samaeul control, no fixed effect, no GIS controls, 

reg public_use dist_to_attack if sido_nm!="경상남도"&sido_nm!="경상북도"&sido_nm!="제주도"&dist_to_attack<=65
predict r1, resid
reg r1 dist_to_attack if sido_nm!="경상남도"&sido_nm!="경상북도"&sido_nm!="제주도"&dist_to_attack<=65,nocon
predict yhat1,xb
reg public_use dist_to_attack if sido_nm!="경상남도"&sido_nm!="경상북도"&sido_nm!="제주도"&dist_to_attack<=65 [aweight=yhat1],vce(cluster sig_cd)

*(2) Samaeul control, no fixed effect, no GIS controls, 

reg public_use dist_to_attack farmland_perhousehold farm_household_ratio pop14_grter_ratio ///
if sido_nm!="경상남도"&sido_nm!="경상북도"&sido_nm!="제주도"&dist_to_attack<=65,nocon
predict r2, resid
reg r2 dist_to_attack if sido_nm!="경상남도"&sido_nm!="경상북도"&sido_nm!="제주도"&dist_to_attack<=65,nocon
predict yhat2,xb
reg public_use dist_to_attack if sido_nm!="경상남도"&sido_nm!="경상북도"&sido_nm!="제주도"&dist_to_attack<=65 [aweight=yhat2],vce(cluster sig_cd)

*(3) Samaeul control, fixed effect, no GIS controls,

areg public_use dist_to_attack farmland_perhousehold farm_household_ratio pop14_grter_ratio ///
if sido_nm!="경상남도"&sido_nm!="경상북도"&sido_nm!="제주도"&dist_to_attack<=65,nocon
predict r3, resid
reg r3 dist_to_attack if sido_nm!="경상남도"&sido_nm!="경상북도"&sido_nm!="제주도"&dist_to_attack<=65,nocon
predict yhat3,xb
reg public_use dist_to_attack if sido_nm!="경상남도"&sido_nm!="경상북도"&sido_nm!="제주도"&dist_to_attack<=65 [aweight=yhat3]




*(4) Samaeul control, fixed effect, GIS controls
