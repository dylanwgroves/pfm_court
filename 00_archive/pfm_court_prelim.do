	
/* Overview ______________________________________________________________________

Project: Wellspring Tanzania, Courts and Attitudes
Purpose: Analysis Prelimenary Work
Author: dylan groves, dylanwgroves@gmail.com
Date: 2020/01/01


	This mostly just subsets the data and does anything else necessary before
	running the analysis
________________________________________________________________________________*/


/* Introduction ________________________________________________________________*/
	
	clear all	
	clear matrix
	clear mata
	set more off
	global c_date = c(current_date)
	set seed 1956
	
	
/* Tempfiles ___________________________________________________________________*/	

	tempfile temp_partner
	tempfile temp_friend
	tempfile temp_all

	
/* Deal with Partner Survey ____________________________________________________*/

	use "${data}/03_final_data/pfm_appended_noprefix.dta", clear
	keep if p_svy_partner == 1
	keep p_* id_village_uid
	rename p_* *
	save `temp_partner'
	
	
/* Deal with Friend Survey ____________________________________________________*/

	use "${data}/03_final_data/pfm_appended_noprefix.dta", clear
	keep if f_svy_friend== 1
	keep f_* id_village_uid
	rename f_* *


/* Append Surveys _____________________________________________________*/

	append using `temp_partner', force
	replace id_resp_uid = id_friend_uid if id_resp_uid == ""

	save `temp_all', replace

	
	
	
/* Merge Transcript ____________________________________________________________*/

	import excel "${data}\02_mid_data\em_records\uliza_dylan_groves_partner_transcripts_20220301.xlsx", sheet("uliza_dylan_groves_partner_tran") firstrow clear
	replace courts = 0 if courts == .
	keep uid courts
	rename uid id_resp_uid
	
	merge 1:1 id_resp_uid using `temp_all', gen(merge_courtcount)
	
	replace courts = 0 if courts == .
		replace courts = . if svy_friend == 1
		
stop

/* Generate any necessary variables ____________________________________________*/

	/* Sample */
	replace svy_partner = 0 if svy_friend == 1
	
	replace pi_treat = "none" if svy_partner == 1
	encode pi_treat, gen(treat_pi)
	
	/* Outcomes */
	drop em_reject_index
	gen em_reject_index = (em_reject + em_reject_religion_dum + em_reject_money_dum)/3
	
	drop em_reject_all
	
	/* Treatments */
	gen treat = 0 if treat_court == "control"
		replace treat = 1 if treat_court == "treat_both"
		replace treat = 1 if treat_court == "treat_both"
		replace treat = 2 if treat_court == "treat_court"
		replace treat = 2 if treat_court == "treat_court"
		lab def treat 0 "Control" 1 "Court + AG" 2 "Court Only", replace
		lab val treat treat
		lab var treat "Court Treatment"
		
	gen treat_courtonly = 1 if treat == 2
		replace treat_courtonly = 0 if treat == 0
		lab var treat_courtonly "Court Treamtent (Court Only Dummy)"
		lab def treat_courtonly 0 "Control" 1 "Treat (Court)", replace
		lab val treat_courtonly treat_courtonly
			
	gen treat_courtag = 1 if treat == 1
		replace treat_courtag = 0 if treat == 0
		lab var treat_courtag "Court Treatment (Court/AG Dummy)"
		lab def treat_courtag 0 "Control" 1 "Treatment (Court/AG)", replace
		lab val treat_courtag treat_courtag
		
	gen treat_courtall = 1 if treat == 1 | treat == 2
		replace treat_courtall = 0 if treat == 0
		lab var treat_courtall "Court Treatment (all Treat Dummy)"
		lab def treat_courtall 0 "Control" 1 "Treatment (Court or Court/AG)", replace
		lab val treat_courtall treat_courtall
		
	drop treat_court treat_court_all treat_court_courtonly treat_court_agcourt treat_court_dum

	/* Drop dates before treatment was working*/
	*drop if (startdate < td(10,12,2020))
	
	/* Create village variable */
	encode id_village_uid, gen(village)
	

/* Fill missing baseline values ________________________________________________*/

	#d ;
	
	/* Lasso Covariates */
	global cov_lasso	resp_female 
						resp_muslim
						fm_reject
						fm_reject_long	
						resp_age
						svy_partner
						;
	#d cr
	
		foreach var of global cov_lasso {
			bys id_village_uid : egen vill_`var' = mean(`var')
			replace `var' = vill_`var' if `var' == . | `var' == .d | `var' == .r
		}
		
	replace svy_enum = 0 if svy_enum == .

/* Create Inverse Probability Weights __________________________________________*/

		gen ipw = .
			replace ipw = 2 if svy_partner == 1
			replace ipw = 4 if svy_partner == 0 & treat == 0
			replace ipw = 3	if svy_partner == 0 & (treat == 1 | treat == 2)
			

/* For Randomization Inference _________________________________________________*/
	
	forvalues i = 1/2000 {
	
		gen rand_`i' = runiform()
		
		gen treat_`i' = .
			replace treat_`i' = 0 if rand_`i' < 0.4	& svy_partner == 0
			replace treat_`i' = 1 if rand_`i' > 0.4 & rand_`i' < 0.7 & svy_partner == 0
			replace treat_`i' = 2 if rand_`i' > 0.7 & svy_partner == 0
			
			replace treat_`i' = 0 if rand_`i' < 1/3 & svy_partner == 1
			replace treat_`i' = 1 if rand_`i' > 1/3 & rand_`i' < 2/3 & svy_partner == 1
			replace treat_`i' = 2 if rand_`i' > 2/3 & svy_partner == 1
			
		gen ipw_courtonly_`i' = .
			replace ipw_courtonly_`i' = 2 if svy_partner == 1
			replace ipw_courtonly_`i' = 4 if svy_partner == 0 & treat == 0
			replace ipw_courtonly_`i' = 3	if svy_partner == 0 & (treat == 1 | treat == 2)

		gen treat_courtonly_`i' = .
			replace treat_courtonly_`i' = 0 if treat_`i' == 0 & svy_partner == 0
			replace treat_courtonly_`i' = 1 if treat_`i' == 2
			
			
		gen treat_courtag_`i' = .
			replace treat_courtag_`i' = 0 if treat_`i' == 0 & svy_partner == 0
			replace treat_courtag_`i' = 1 if treat_`i' == 1
		
		gen ipw_courtag_`i' = .
			replace ipw_courtag_`i' = 2 if svy_partner == 1
			replace ipw_courtag_`i' = 4 if svy_partner == 0 & treat == 0
			replace ipw_courtag_`i' = 3	if svy_partner == 0 & (treat == 1 | treat == 2)
			
		gen treat_courtvsag_`i' = .
			replace treat_courtvsag_`i' = 0 if treat_`i' == 2
			replace treat_courtvsag_`i' = 1 if treat_`i' == 0
			
		gen ipw_courtvsag_`i' = .
			replace ipw_courtvsag_`i' = 2 
			
	}
	
	
/* Drop PII ____________________________________________________________________*/

	cap drop b_fo_name b_resp_name b_cases_resp_name b_cases_hhh_name rd_resp_n id_resp_n enum_name resp_name_new resp_name_cl 


/* Save ________________________________________________________________________*/

	save "${data_court}/pfm_court_analysis.dta", replace
