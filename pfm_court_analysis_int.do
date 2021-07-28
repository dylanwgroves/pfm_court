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
	*do "${code}/pfm_court/pfm_court_prelim.do"


	/* Load Data ___________________________________________________________________*/	

		use "${data_court}/pfm_court_analysis.dta", clear


	/* Define Globals and Locals ___________________________________________________*/
		#d ;
			
			/* Rerandomization count */
			local rerandcount	100
								;
				
				
			/* Set seed */
			set seed 			1956
								;
								
			/* Outcomes */
			global em 						
								em_reject_index
								em_reject
								em_reject_money_dum 
								em_reject_religion_dum
								em_report
								em_norm_reject_dum
								em_report_norm
								em_record_shareany
								em_record_shareptix
								em_record_sharepfm
								;
								/*

								*/	
			
			/* Covariates */	
			global cov_always	svy_partner 
								i.treat_pi
								;		
			
			/* Lasso Covariates */
			global cov_lasso	fm_reject
								fm_reject_long
								resp_female
								resp_muslim
								resp_age
								i.village
								;						
			
		#d cr

	
	drop if startdate < mdy(12, 11, 2020)
		
	/* Move this to prelim */ 
	gen treat_courtag_interact = treat_courtag 
		replace treat_courtag_interact = 0 if treat_courtonly == 1
		
	gen treat_courtonly_interact = treat_courtonly 
		replace treat_courtonly_interact = 0 if treat_courtag == 1
		
	gen interact = treat_courtall*treat_courtag_interact

	reg em_reject treat_courtall treat_courtag_interact interact
	stop
	
/* Run for Each Index __________________________________________________________*/

	/* Define Matrix _______________________________________________________________*/
				
		/* Set Put Excel File Name */
		putexcel clear
		putexcel set "${court_tables}/pfm_court_analysis_interact.xlsx", replace
		
		qui putexcel A1 = ("variable")
		qui putexcel B1 = ("variablelabel")
		
		qui putexcel C1 = ("coef_all")
		qui putexcel D1 = ("se_all")
		qui putexcel E1 = ("pval_all")
		qui putexcel F1 = ("ripval_all")
		qui putexcel G1 = ("r2")
		qui putexcel H1 = ("N")
		
		qui putexcel I1 = ("lasso_coef_all")
		qui putexcel J1 = ("lasso_se_all")
		qui putexcel K1 = ("lasso_pval_all")
		qui putexcel L1 = ("lasso_ripval_all")
		qui putexcel M1 = ("lasso_r2")
		qui putexcel N1 = ("lasso_N")
		
		qui putexcel O1 = ("treat_mean_all")
		qui putexcel P1 = ("treat_sd_all")
		
		qui putexcel Q1 = ("coef_aginteract")
		qui putexcel R1 = ("se_aginteract")
		qui putexcel S1 = ("pval_aginteract")
		qui putexcel T1 = ("ripval_aginteract")
		
		qui putexcel U1 = ("lasso_coef_aginteract")	
		qui putexcel V1 = ("lasso_se_aginteract")
		qui putexcel W1 = ("lasso_pval_aginteract")
		qui putexcel X1 = ("lasso_ripval_aginteract")
		
		qui putexcel Y1 = ("lasso_ctls")
		qui putexcel Z1 = ("lasso_ctls_num")
		
		qui putexcel AA1 = ("ctl_mean")
		qui putexcel AB1 = ("ctl_sd")
		qui putexcel AC1 = ("vill_sd")
		qui putexcel AD1 = ("min")
		qui putexcel AE1 = ("max")
		qui putexcel AF1 = ("test")
	

local row = 2	
foreach dv of global em {		
	
/* Standard Regression _________________________________________________________*/

		qui ds `dv'
			global varname = "`r(varlist)'"  
			
		/* Outcome label 
		global varlabel : var label `dv'
		*/
		
		/* Control mean */
		qui sum `dv' if treat_courtall == 0
			global ctl_mean `r(mean)'
			global ctl_sd `r(sd)'
			
		/* min and max */
		qui sum `dv' 
			global min `r(min)'
			global max `r(max)'
		
		/* Control village sd */
		preserve
		qui collapse (mean) `dv' treat_courtall, by(village)
		qui sum `dv'
			global vill_sd : di %6.3f `r(sd)'
		restore

		/* Run basic regression */
		foreach treat in courtall courtag_interact {
		qui sum `dv' if treat_`treat' == 1
			global treat_mean_`treat' `r(mean)'
			global treat_sd_`treat' `r(sd)'
		}
		
		qui reg `dv' treat_courtall treat_courtag_interact ${cov_always}					     			// This is the core regression
			matrix table = r(table)
			
			/* Save values from regression */
			global coef_courtall = table[1,1]    	//beta
			global se_courtall 	 = table[2,1]		//se
			*global t_`treat'  	 = table[3,1]		//t
			global pval_courtall = table[4,1]/2		//pval
			
			global coef_courtag_interact = table[1,2]    	//beta
			global se_courtag_interact 	 = table[2,2]		//se
			*global t_`treat'  	 		 = table[3,2]		//t
			global pval_courtag_interact = table[4,2]/2		//pval
			
			global r2 	= `e(r2_a)' 		//r-squared
			global N 	= e(N) 				//N


/* Run lasso regression ____________________________________________________*/	
					
	/* Run and save lasso */
	qui lasso linear `dv' ${cov_lasso} 
		global lasso_ctls = e(allvars_sel)
		global lasso_ctls_num = e(k_nonzero_sel)
			
		/* Run regressions 																	// This are the LASSO regressions
		
			The regression will depend on whether lasso covariates have been
			selected. 

		*/
		
			/* If lasso selected covariates for both */
			if ${lasso_ctls_num} != 0  {
				qui reg `dv' treat_courtall treat_courtag_interact ${lasso_ctls} ${cov_always}    
				matrix table = r(table)
			}
			
			/* If lasso selected no covariates */
			if ${lasso_ctls_num} == 0 {		
				qui reg `dv' treat_courtall treat_courtag_interact ${cov_always}
				matrix table = r(table)
			}
			
			/* Save values from regression */
			global lasso_coef_courtall 		= table[1,1]    		//beta
			global lasso_se_courtall 	 	= table[2,1]		//se
			*global lasso_t_`treat'  	 	= table[3,1]		//t
			global lasso_pval_courtall 		= table[4,1]/2		//pval
			
			global lasso_coef_courtag_interact 	= table[1,2] //beta
			global lasso_se_courtag_interact 	= table[2,2]	//se
			*global lasso_t_`treat'  	 		= table[3,2]	//t
			global lasso_pval_courtag_interact 	= table[4,2]/2	//pval
		
			global lasso_r2 					= `e(r2_a)' 		//r-squared
			global lasso_N 						= e(N) 				//N

		
		/* One-sided p-value for predicted effects 								// THIS NEEDS TO BE ADJUSTED ACCORDING TO HYPOTHESIS
		if table[1,1] > 0 {
			global lasso_pval = ttail(e(df_r),abs(${lasso_t}))
			global help "One-tailed"
		}
		else if table[1,1] < 0 {
			global lasso_pval = 1-ttail(e(df_r),abs(${lasso_t}))
			global help "Two-tailed"
		}
		*/	
		
		
/* Export to Excel _________________________________________________________*/ 

	qui putexcel A`row' = ("${varname}")
	qui putexcel B`row' = ("${variablelabel}")
	
	qui putexcel C`row' = ("${coef_courtall}")
	qui putexcel D`row' = ("${se_courtall}")
	qui putexcel E`row' = ("${pval_courtall}")
	qui putexcel F`row' = ("${ripval_courtall}")
	qui putexcel G`row' = ("${r2}")
	qui putexcel H`row' = ("${N}")
	
	qui putexcel I`row' = ("${lasso_coef_courtall}")
	qui putexcel J`row' = ("${lasso_se_courtall}")
	qui putexcel K`row' = ("${lasso_pval_courtall}")
	qui putexcel L`row' = ("${lasso_ripval_courtall}")
	qui putexcel M`row' = ("${lasso_r2}")
	qui putexcel N`row' = ("${lasso_N}")
	
	qui putexcel O`row' = ("${treat_mean_courtall}")
	qui putexcel P`row' = ("${treat_sd_courtall}")
	
	qui putexcel Q`row' = ("${coef_courtag_interact}")
	qui putexcel R`row' = ("${se_courtag_interact}")
	qui putexcel S`row' = ("${pval_courtag_interact}")
	qui putexcel T`row' = ("${ripval_courtag_interact}")
	
	qui putexcel U`row' = ("${lasso_coef_courtag_interact}")
	qui putexcel V`row' = ("${lasso_se_courtag_interact}")
	qui putexcel W`row' = ("${lasso_pval_courtag_interact}")
	qui putexcel X`row' = ("${lasso_ripval_courtag_interact}")
	
	qui putexcel Y`row' = ("${lasso_ctls}")
	qui putexcel Z`row' = ("${lasso_ctls_num}")
	
	qui putexcel AA`row' = ("${ctl_mean}")
	qui putexcel AB`row' = ("${ctl_sd}")
	qui putexcel AC`row' = ("${vill_sd}")
	qui putexcel AD`row' = ("${min}")
	qui putexcel AE`row' = ("${max}")
	qui putexcel AF`row' = ("${test}")
	
	/* Update locals ___________________________________________________________*/
	
	local row = `row' + 1
	
}	