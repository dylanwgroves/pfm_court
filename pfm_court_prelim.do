	
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

	tempfile temp_attend

	
/* Load Data ___________________________________________________________________*/	

	use "${data}/03_final_data/pfm_appended_prefix.dta", clear

	
/* Subset Data _________________________________________________________________*/	
	
	/* Get correct sample */
	keep if sample == "as"
	drop ne_*
	rename as_* *																// Get rid of prefix
	
	/* Primary Analysis is only with people who own a radio */					
	keep if  endline_as == 1
	rename treat treat_as
	
/* Generate any necessary variables ____________________________________________*/

	gen treat = 0 if p_treat_court == "control"
		replace treat = 1 if p_treat_court == "treat_both"
		replace treat = 2 if p_treat_court == "treat_court"
		lab def treat_court 0 "Control" 1 "Court + AG" 2 "Court Only"
		lab val treat treat_court
		lab var treat "Court Treatment"
			
	gen treat_court = 1 if treat == 2
		replace treat_court = 0 if treat == 0
		lab var treat_court "Court Treamtent (Court Only Dummy)"
		
	gen treat_ag = 1 if treat == 1
		replace treat_ag = 0 if treat == 0
		lab var treat_ag "Court Treatment (Court/AG Dummy)"
		
	gen treat_any = 1 if treat == 1 | treat == 2
		replace treat_any = 0 if treat == 0
		lab var treat_any "Court Treatment (Any Treat Dummy)"
		
	gen p_aware = p_ptixknow_em_aware
	
/* Fill missing baseline values ________________________________________________*/

		#d ;
		/* Lasso Covariates */
		global cov_lasso	resp_female 
							resp_muslim
							b_resp_religiosity
							b_values_likechange 
							b_values_techgood 
							b_values_respectauthority 
							b_values_trustelders 
							b_fm_reject
							b_ge_raisekids 
							b_ge_earning 
							b_ge_leadership 
							b_ge_noprefboy 
							b_media_tv_any 
							b_media_news_never 
							b_radio_any 
							b_resp_lang_swahili 
							b_resp_literate 
							b_resp_standard7 
							b_resp_nevervisitcity 
							b_resp_married 
							b_resp_hhh 
							b_resp_numkid
							;
		#d cr
		
			foreach var of global cov_lasso {
				bys id_village_uid : egen vill_`var' = mean(`var')
				replace `var' = vill_`var' if `var' == . | `var' == .d | `var' == .r
 			}

			
/* Drop PII ____________________________________________________________________*/

	drop b_fo_name b_resp_name b_cases_resp_name b_cases_hhh_name rd_resp_n id_resp_n enum_name resp_name_new resp_name_cl 


/* Save ________________________________________________________________________*/

	save "${data_court}/pfm_court_analysis.dta", replace
