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

	
	
/* Run for Each Index __________________________________________________________*/

foreach index of local index_list {

	/* Drop Macros */
	macro drop lasso_ctls 
	macro drop lasso_ctls_num 
	macro drop lasso_ctls_int
	
	macro drop lasso_ctls_replacement
	macro drop lasso_ctls_num_replacement 
	macro drop lasso_ctls_int_replace
	
	macro drop helper_pval
	macro drop helper_ripval
	macro drop helper_lasso_pval
	macro drop helper_lasso_ripval
	
	macro drop test
	
	/* Define Matrix _______________________________________________________________*/
				
		/* Set Put Excel File Name */
		putexcel clear
		putexcel set "${as_tables}/pfm_as_analysis_${survey}.xlsx", sheet(`index', replace) modify
		
		qui putexcel A1 = ("variable")
		qui putexcel B1 = ("variablelabel")
		qui putexcel C1 = ("coef")
		qui putexcel D1 = ("se")
		qui putexcel E1 = ("pval")
		qui putexcel F1 = ("ripval")
		qui putexcel G1 = ("r2")
		qui putexcel H1 = ("N")
		qui putexcel I1 = ("lasso_coef")
		qui putexcel J1 = ("lasso_se")
		qui putexcel K1 = ("lasso_pval")
		qui putexcel L1 = ("lasso_ripval")
		qui putexcel M1 = ("lasso_r2")
		qui putexcel N1 = ("lasso_N")
		qui putexcel O1 = ("lasso_ctls")
		qui putexcel P1 = ("lasso_ctls_num")
		qui putexcel Q1 = ("treat_mean")
		qui putexcel R1 = ("treat_sd")
		qui putexcel S1 = ("ctl_mean")
		qui putexcel T1 = ("ctl_sd")
		qui putexcel U1 = ("vill_sd")
		qui putexcel V1 = ("min")
		qui putexcel W1 = ("max")
		qui putexcel X1 = ("test")
	
	
	
	
	/* Sandbox _____________________________________________________________________*/

	cap log close
	log using "${court_tables}/pfm_court_basic_results", replace


	foreach var of local em {

		di "**** OUTCOMES IS `var' ******"
			reg `var' treat_court_all i.village

		
	}


cap log close

