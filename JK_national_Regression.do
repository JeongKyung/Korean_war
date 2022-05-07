*****************************************************************************************
************ Regression : estimating the effects of conflict on cooperation *************
************ Date: 2021/05/26, Last edited by JK Won ************************************
*****************************************************************************************

use "C:/Users/user/Dropbox/korean_war/GIS_control/merging_samaeul_with_geocontrol_data/final_samaeul_data_with_geocontrol.dta", clear
cd "C:/Users/user/Dropbox/korean_war/JK"

*Village level public use(dummy) is averaged at the township level with the number of village household as the weight.
*set dist_to_attac less than 65 based on histogram of dist_to_attack
histogram dist_to_attack, bin(10)
*excluded "경상도" whose dist_to_attack measure is likely to be wrong
*"제주도" excluded as well.


****Table 1: Descriptive Statistics

eststo clear
estpost sum public_use dist_to_attack farmland_perhousehold farm_household_ratio pop14_grter_ratio  ///
slope_med elev_med csi_nz_med dist_to_water if sido_nm!="경상남도"&sido_nm!="경상북도"&sido_nm!="제주도"&dist_to_attack<=65
esttab using desc_stats_2.tex,replace /// 
refcat(public_use "\emph{Dependent Variable}" dist_to_attack "\vspace{0.1em} \\ \emph{Explanatory Variable}" ///
farmland_perhousehold "\vspace{0.1em} \\ \emph{Controls}",nolabel) cells("count mean sd min max") nostar unstack nonumber ///
compress nomtitle nonote noobs gap label f collabels("Obs" "Mean" "St.D" "Min" "Max")



****Table 3: OLS and FE Estimates of the effects of the conflict on cooperation

*generate some Samaeul control
gen farm_household_ratio=household_farm/household_total
gen pop14_grter_ratio=pop_14greater/pop_total
gen pop14_less_ratio=1-pop14_grter_ratio
gen dist_attack_sqrd=dist_to_attack^2


*check scatterplot
twoway (scatter public_use dist_to_attack if sido_nm!="경상남도"&sido_nm!="경상북도"&sido_nm!="제주도"&dist_to_attack<=65) ///
(lfit public_use dist_to_attack if sido_nm!="경상남도"&sido_nm!="경상북도"&sido_nm!="제주도"&dist_to_attack<=65)


*Run Regression
set more off
eststo clear

*(1) no Samaeul control, no fixed effect, no GIS controls, 

reg public_use dist_to_attack if sido_nm!="경상남도"&sido_nm!="경상북도"&sido_nm!="제주도"&dist_to_attack<=65, vce(cluster sig_cd) 
estimates store m1
estadd local CR "N"
estadd local FE "N"
estadd local GIS "N"

*(2) Samaeul control, no fixed effect, no GIS controls, 

reg public_use dist_to_attack farmland_perhousehold farm_household_ratio pop14_grter_ratio  ///
if sido_nm!="경상남도"&sido_nm!="경상북도"&sido_nm!="제주도"&dist_to_attack<=65, vce(cluster sig_cd)
estimates store m2
estadd local CR "Y"
estadd local FE "N"
estadd local GIS "N"

*(3) Samaeul control, fixed effect, no GIS controls,

areg public_use dist_to_attack farmland_perhousehold farm_household_ratio pop14_grter_ratio  ///
if sido_nm!="경상남도"&sido_nm!="경상북도"&sido_nm!="제주도"&dist_to_attack<=65, absorb(sig_cd) vce(cluster sig_cd)
estimates store m3
estadd local CR "Y"
estadd local FE "Y"
estadd local GIS "N"

*(4) Samaeul control, fixed effect, GIS controls

areg public_use dist_to_attack farmland_perhousehold farm_household_ratio pop14_grter_ratio  ///
slope_med elev_med csi_nz_med dist_to_water ///
if sido_nm!="경상남도"&sido_nm!="경상북도"&sido_nm!="제주도"&dist_to_attack<=65,absorb(sig_cd) vce(cluster sig_cd)

estimates store m4
estadd local CR "Y"
estadd local FE "Y"
estadd local GIS "Y"

esttab m1 m2 m3 m4 using table_3_3.tex,replace keep(dist_to_attack) b p ///
nomtitles mgroups("Dependent variable: public_use", pattern(1 0 0 0) ///
span prefix(\multicolumn{@span}{c}{) suffix(})) r2 ///
scalars("CR Controls" "FE County Fixed Effects" "GIS GIS controls")







****Table 4. WLS Version of Table 3

net search wls0 // install wls0 command
drop r
*motivation for using wls
reg public_use dist_to_attack if sido_nm!="경상남도"&sido_nm!="경상북도"&sido_nm!="제주도"&dist_to_attack<=65, vce(cluster sig_cd) 
predict r, resid
scatter r dist_to_attack if sido_nm!="경상남도"&sido_nm!="경상북도"&sido_nm!="제주도"&dist_to_attack<=65,yline(0) // evidence of heteroscedasticity


*Run WLS 
set more off
eststo clear

*(1) no Samaeul control, no fixed effect, no GIS controls, 

wls0 public_use dist_to_attack if sido_nm!="경상남도"&sido_nm!="경상북도"&sido_nm!="제주도"&dist_to_attack<=65, wvars(dist_to_attack) type(abse) noconst robust
estimates store m1
estadd local CR "N"
estadd local FE "N"
estadd local GIS "N"

*(2) Samaeul control, no fixed effect, no GIS controls, 

wls0 public_use dist_to_attack farmland_perhousehold farm_household_ratio pop14_grter_ratio  ///
if sido_nm!="경상남도"&sido_nm!="경상북도"&sido_nm!="제주도"&dist_to_attack<=65, wvars(dist_to_attack) type(abse) noconst robust
estimates store m2
estadd local CR "Y"
estadd local FE "N"
estadd local GIS "N"

*(3) Samaeul control, fixed effect, no GIS controls,

xi:wls0 public_use dist_to_attack farmland_perhousehold farm_household_ratio pop14_grter_ratio i.sig_cd ///
if sido_nm!="경상남도"&sido_nm!="경상북도"&sido_nm!="제주도"&dist_to_attack<=65, wvars(dist_to_attack) type(abse) noconst robust
estimates store m3
estadd local CR "Y"
estadd local FE "Y"
estadd local GIS "N"

*(4) Samaeul control, fixed effect, GIS controls

xi:wls0 public_use dist_to_attack farmland_perhousehold farm_household_ratio pop14_grter_ratio i.sig_cd ///
slope_med elev_med csi_nz_med dist_to_water ///
if sido_nm!="경상남도"&sido_nm!="경상북도"&sido_nm!="제주도"&dist_to_attack<=65, wvars(dist_to_attack) type(abse) noconst robust
estimates store m4
estadd local CR "Y"
estadd local FE "Y"
estadd local GIS "Y"

esttab m1 m2 m3 m4 using table_3_4.tex,replace keep(dist_to_attack) b p ///
nomtitles mgroups("Dependent variable: public_use", pattern(1 0 0 0) ///
span prefix(\multicolumn{@span}{c}{) suffix(})) r2 ///
scalars("CR Controls" "FE County Fixed Effects" "GIS GIS controls")


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
