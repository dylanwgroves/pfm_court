/* Basics ______________________________________________________________________

Project: Wellspring Tanzania, Audio Screening
Purpose: Analysis
Author: dylan groves, dylanwgroves@gmail.com
Date: 2020/12/23
________________________________________________________________________________*/


/* Introduction ________________________________________________________________*/
	
	clear all	
	clear matrix
	clear mata
	set more off
	global c_date = c(current_date)

	
/* Run Prelim File _____________________________________________________________*/ // comment out if you dont need to rerun prelim cleaning	

	*do "${code}/pfm_.master/00_setup/pfm_paths_master.do"
	do "${code}/pfm_court/pfm_court_prelim.do"


	/* Load Data ___________________________________________________________________*/	

		use "${data_court}/pfm_court_analysis.dta", clear


	/* Define Globals and Locals ___________________________________________________*/
		#d ;
			
			/* Sandbox */															// Set if you just want to see the immediate results without export
			local sandbox		1
								;
			
			
			/* Rerandomization count */
			local rerandcount	500
								;
				
				
			/* Set seed */
			set seed 			1956
								;
								
			/* Outcomes */
			local em 						
								em_reject
								em_reject_index 
								em_report
								em_norm_reject
								em_report_norm
								em_record_shareptix
								;
			
			/* Covariates */	
			global cov_always	as_treat
								
								;		
			
			/* Lasso Covariates */
			global cov_lasso	fm_reject
								fm_reject_long
								resp_female
								resp_muslim
								resp_age
								svy_partner 
								i.treat_pi
								;						
			
			/* Statitistics of interest */
			local stats_list 	coefficient											//1
								se													//2
								ripval												//3
								pval												//4
								controls_num										//5
								r2													//6
								N 													//7
								basic_coefficient									//8
								basic_se											//9
								basic_ripval										//10
								basic_pval											//11
								basic_r2											//12
								basic_N												//13
								ctl_mean											//14
								ctl_sd												//15
								treat_mean											//16
								treat_sd											//17
								vill_sd												//18													
								min													//19
								max													//20
								;
		#d cr

	encode id_village_uid, gen(village)

	/* Sandbox _____________________________________________________________________*/

	cap log close
	log using "${court_tables}/pfm_court_basic_results", replace


	foreach var of local em {

		di "**** OUTCOMES IS `var' ******"
			reg `var' treat_court_all i.village

		
	}


cap log close

