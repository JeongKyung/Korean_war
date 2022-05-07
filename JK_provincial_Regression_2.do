*****************************************************************************************
************ Regression 3 : OLS and FE Regression by province ***************************
************ Date: 2021/05/31, Last edited by JK Won ************************************
*****************************************************************************************

*Village level public use(dummy) is averaged at the township level with the number of village household as the weight.
*set dist_to_attac less than 65 based on histogram of dist_to_attack of each province

use "C:/Users/user/Dropbox/korean_war/GIS_control/merging_samaeul_with_geocontrol_data/final_samaeul_data_with_geocontrol.dta", clear
cd "C:/Users/user/Dropbox/korean_war/JK"

*generate some Samaeul control
gen farm_household_ratio=household_farm/household_total
gen pop14_grter_ratio=pop_14greater/pop_total
gen pop14_less_ratio=1-pop14_grter_ratio
	
*Run Loop
set more off

local sidolist 31 32 33 34 35 36
local sidoname 경기도 강원도 충청북도 충청남도 전라북도 전라남도
local num: word count `sidolist'

forvalues n=1/`num'{
	local i: word `n' of `sidolist'
	local j: word `n' of `sidoname'
	
	eststo clear

	****Table 1: Descriptive Statistics

	
	
	estpost sum public_use dist_to_attack slope_med elev_med csi_nz_med dist_to_water island dist_Gwangju-dist_Seoul ///
	farmland_perhousehold farm_household_ratio pop14_grter_ratio if sido_cd=="`i'"&dist_to_attack<=65
	esttab using desc_stats_v2_`j'.tex,replace /// 
	refcat(public_use "\emph{Dependent Variable}" dist_to_attack "\vspace{0.1em} \\ \emph{Explanatory Variable}" ///
	slope_med "\vspace{0.1em} \\ \emph{Controls}",nolabel) cells("count mean sd min max") nostar unstack nonumber ///
	compress nomtitle nonote noobs gap label f collabels("Obs" "Mean" "St.D" "Min" "Max")


	****Table 3: OLS and FE Estimates of the effects of the conflict on cooperation

	*Run Regression
	
	*(1)no GIS controls, no fixed effect, no other control 

	reg public_use dist_to_attack if sido_cd=="`i'"&dist_to_attack<=65, vce(cluster sig_cd) 
	estimates store m1
	estadd local GIS "N"
	estadd local FE "N"
	estadd local CR "N"

	*(2)GIS controls, no fixed effect, no other control

	reg public_use dist_to_attack slope_med elev_med csi_nz_med dist_to_water island dist_Gwangju-dist_Seoul  ///
	if sido_cd=="`i'"&dist_to_attack<=65, vce(cluster sig_cd)
	estimates store m2
	estadd local GIS "Y"
	estadd local FE "N"
	estadd local CR "N"

	*(3)GIS controls, fixed effect, no other control

	areg public_use dist_to_attack slope_med elev_med csi_nz_med dist_to_water island dist_Gwangju-dist_Seoul ///
	if sido_cd=="`i'"&dist_to_attack<=65, absorb(sig_cd) vce(cluster sig_cd)
	estimates store m3
	estadd local GIS "Y"
	estadd local FE "Y"
	estadd local CR "N"

	*(4)GIS controls, fixed effect, other control

	areg public_use dist_to_attack slope_med elev_med csi_nz_med dist_to_water island dist_Gwangju-dist_Seoul ///
	farmland_perhousehold farm_household_ratio pop14_grter_ratio ///
	if sido_cd=="`i'"&dist_to_attack<=65,absorb(sig_cd) vce(cluster sig_cd)

	estimates store m4
	estadd local GIS "Y"
	estadd local FE "Y"
	estadd local CR "Y"

	esttab m1 m2 m3 m4 using table_3_v2_`j'.tex,replace keep(dist_to_attack) b p ///
	nomtitles mgroups("Dependent variable: public_use", pattern(1 0 0 0) ///
	span prefix(\multicolumn{@span}{c}{) suffix(})) r2 ///
	scalars("GIS GIS controls" "FE County Fixed Effects" "CR Controls")
	}

*Table5. Dist_to_attack's correlation with observed characteristics


	
/****Table 4. WLS Version of Table 3

net search wls0 // install wls0 command
drop r
*motivation for using wls
reg public_use dist_to_attack slope_med elev_med csi_nz_med dist_to_water island if sido_nm=="전라남도"&dist_to_attack<=50, vce(cluster sig_cd) 
predict r, resid
scatter r dist_to_attack if sido_nm=="전라남도"&dist_to_attack<=50,yline(0) // evidence of heteroscedasticity


*Run WLS 
set more off
eststo clear

*(1)no GIS controls, no fixed effect, no other control 

wls0 public_use dist_to_attack if sido_nm=="전라남도"&dist_to_attack<=50, wvars(dist_to_attack) type(abse) noconst robust
estimates store m1
estadd local GIS "N"
estadd local FE "N"
estadd local CR "N"

*(2)GIS controls, no fixed effect, no other control

wls0 public_use dist_to_attack slope_med elev_med csi_nz_med dist_to_water island  ///
if sido_nm=="전라남도"&dist_to_attack<=50, wvars(dist_to_attack) type(abse) noconst robust
estimates store m2
estadd local GIS "Y"
estadd local FE "N"
estadd local CR "N"

*(3)GIS controls, fixed effect, no other control

xi:wls0 public_use dist_to_attack slope_med elev_med csi_nz_med dist_to_water island i.sig_cd ///
if sido_nm=="전라남도"&dist_to_attack<=50, wvars(dist_to_attack) type(abse) noconst robust
estimates store m3
estadd local GIS "Y"
estadd local FE "Y"
estadd local CR "N"

*(4)GIS controls, fixed effect, other control

xi:wls0 public_use dist_to_attack slope_med elev_med csi_nz_med dist_to_water island i.sig_cd ///
farmland_perhousehold farm_household_ratio pop14_grter_ratio ///
if sido_nm=="전라남도"&dist_to_attack<=50, wvars(dist_to_attack) type(abse) noconst robust
estimates store m4
estadd local GIS "Y"
estadd local FE "Y"
estadd local CR "Y"


esttab m1 m2 m3 m4 using table_3_6.tex,replace keep(dist_to_attack) b p ///
nomtitles mgroups("Dependent variable: public_use", pattern(1 0 0 0) ///
span prefix(\multicolumn{@span}{c}{) suffix(})) r2 ///
scalars("GIS GIS controls" "FE County Fixed Effects" "CR Controls")

