	
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
	
/* Tempfiles ___________________________________________________________________*/	

	tempfile temp_partner
	tempfile temp_friend

	
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


/* Generate any necessary variables ____________________________________________*/

	/* Sample */
	replace svy_partner = 0 if svy_friend == 1
	
	replace pi_treat = "none" if svy_partner == 1
	encode pi_treat, gen(treat_pi)
	
	/* Outcomes */
	drop em_reject_index
	gen em_reject_index = (em_reject_religion_dum + em_reject_money_dum)/2
	
	drop em_reject_all
	egen em_reject_all = rowmax(em_reject_religion_dum em_reject_money_dum)
	

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
		
	gen treat_ag = 1 if treat == 1
		replace treat_ag = 0 if treat == 0
		lab var treat_ag "Court Treatment (Court/AG Dummy)"
		lab def treat_ag 0 "Control" 1 "Treatment (Court/AG)", replace
		lab val treat_ag treat_ag
		
	gen treat_any = 1 if treat == 1 | treat == 2
		replace treat_any = 0 if treat == 0
		lab var treat_any "Court Treatment (Any Treat Dummy)"
		lab def treat_any 0 "Control" 1 "Treatment (Court or Court/AG)", replace
		lab val treat_any treat_any
		
	/* Drop dates */
	drop if (startdate < td(15,12,2020))
	

/* Fill missing baseline values ________________________________________________*/

		#d ;
		
		/* Lasso Covariates */
		global cov_lasso	resp_female 
							resp_muslim
							;
		#d cr
		
			foreach var of global cov_lasso {
				bys id_village_uid : egen vill_`var' = mean(`var')
				replace `var' = vill_`var' if `var' == . | `var' == .d | `var' == .r
 			}

			
/* Drop PII ____________________________________________________________________*/

	cap drop b_fo_name b_resp_name b_cases_resp_name b_cases_hhh_name rd_resp_n id_resp_n enum_name resp_name_new resp_name_cl 


/* Save ________________________________________________________________________*/

	save "${data_court}/pfm_court_analysis.dta", replace
