	
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
	rename s17q8 audio
	
	global source_as "X:\Box Sync\19_Community Media Endlines\07_Questionnaires & Data\07_AS\05_data_encrypted\02_survey\01_raw\media"
	
	*make folders	
	cap mkdir "X:\Dropbox\Wellspring Tanzania Papers\wellspring_01_master\01_data\02_mid_data\em_records\partner\"
	
	count
	local num = r(N)

	forvalues x = 1/`num' {

		preserve
		
			keep if _n == `x'
			
			levelsof id_resp_uid, local(sb_uid)
				global uid `sb_uid'
					
			replace audio = subinstr(audio, "media\", "", .)
			
				*capture original file name
				levelsof audio, local(sb_file)
				global file `sb_file'
				
			cap copy 	"X:\Dropbox\Wellspring Tanzania Papers\wellspring_01_master\01_data\02_mid_data\em_records\partner\${uid}.wav" ///
							
				macro drop uid
				macro drop file
				macro drop typefile 
				
		restore
	
			}


stop
	
	
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

			
/* Drop PII ____________________________________________________________________*/

	cap drop b_fo_name b_resp_name b_cases_resp_name b_cases_hhh_name rd_resp_n id_resp_n enum_name resp_name_new resp_name_cl 


/* Save ________________________________________________________________________*/

	save "${data_court}/pfm_court_analysis.dta", replace
