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
	
	stop

/* Run for Each Index __________________________________________________________*/

	/* Define Matrix _______________________________________________________________*/
				
		/* Set Put Excel File Name */
		putexcel clear
		putexcel set "${court_tables}/pfm_court_analysis_new.xlsx", replace
		
		qui putexcel A1 = ("variable")
		qui putexcel B1 = ("variablelabel")
		
		qui putexcel C1 = ("coef_all")
		qui putexcel D1 = ("se_all")
		qui putexcel E1 = ("pval_all")
		qui putexcel F1 = ("ripval_all")
		qui putexcel G1 = ("r2_all")
		qui putexcel H1 = ("N_all")
		
		qui putexcel I1 = ("lasso_coef_all")
		qui putexcel J1 = ("lasso_se_all")
		qui putexcel K1 = ("lasso_pval_all")
		qui putexcel L1 = ("lasso_ripval_all")
		qui putexcel M1 = ("lasso_r2_all")
		qui putexcel N1 = ("lasso_N_all")
		
		qui putexcel O1 = ("treat_mean_all")
		qui putexcel P1 = ("treat_sd_all")
		qui putexcel Q1 = ("treat_N_all")
		
		qui putexcel Q1 = ("coef_courtonly")
		qui putexcel R1 = ("se_courtonly")
		qui putexcel S1 = ("pval_courtonly")
		qui putexcel T1 = ("ripval_courtonly")
		qui putexcel U1 = ("r2_courtonly")
		
		qui putexcel W1 = ("lasso_coef_courtonly")
		qui putexcel X1 = ("lasso_se_courtonly")
		qui putexcel Y1 = ("lasso_pval_courtonly")
		qui putexcel Z1 = ("lasso_ripval_courtonly")
		qui putexcel AA1 = ("lasso_r2_courtonly")
		qui putexcel AB1 = ("lasso_N_courtonly")
		
		qui putexcel AC1 = ("treat_mean_courtonly")
		qui putexcel AD1 = ("treat_sd_courtonly")
		
		qui putexcel AE1 = ("coef_courtag")
		qui putexcel AF1 = ("se_courtag")
		qui putexcel AG1 = ("pval_courtag")
		qui putexcel AH1 = ("ripval_courtag")
		qui putexcel AI1 = ("r2_courtag")
		qui putexcel AJ1 = ("N_courtag")
		
		qui putexcel AK1 = ("lasso_coef_courtag")
		qui putexcel AL1 = ("lasso_se_courtag")
		qui putexcel AM1 = ("lasso_pval_courtag")
		qui putexcel AN1 = ("lasso_ripval_courtag")
		qui putexcel AO1 = ("lasso_r2_courtag")
		qui putexcel AP1 = ("lasso_N_courtag")
		
		qui putexcel AQ1 = ("treat_mean_courtag")
		qui putexcel AR1 = ("treat_sd_courtag")
		
		qui putexcel AS1 = ("lasso_ctls")
		qui putexcel AT1 = ("lasso_ctls_num")
		
		qui putexcel AU1 = ("ctl_mean")
		qui putexcel AV1 = ("ctl_sd")	
		qui putexcel AW1 = ("ctl_N")
		qui putexcel AX1 = ("vill_sd")
		qui putexcel AY1 = ("min")
		qui putexcel AZ1 = ("max")
		qui putexcel BA1 = ("test")
		qui putexcel BB1 = ("N_courtonly_sample")
		qui putexcel BC1 = ("N_courtag_sample")
		qui putexcel BD1 = ("N_courtall_sample")

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
			global ctl_N `r(N)'
			
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
		foreach treat in courtall courtonly courtag {
		
		qui sum `dv' if treat_`treat' == 1
			global treat_mean_`treat' `r(mean)'
			global treat_sd_`treat' `r(sd)'
			global N_`treat'_sample `r(N)'
		
			qui reg `dv' treat_`treat' ${cov_always}					     			// This is the core regression
				matrix table = r(table)
				
				/* Save values from regression */
				global coef_`treat' = table[1,1]    	//beta
				global se_`treat' 	= table[2,1]		//se
				*global t_`treat'  	= table[3,1]		//t
				global pval_`treat'	= table[4,1]/2		//pval
				
				global r2_`treat' 	= `e(r2_a)' 		//r-squared
				global N_`treat' 	= e(N) 				//N
				
		}

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
			foreach treat in courtall courtonly courtag {
			
			if ${lasso_ctls_num} != 0  {
				qui reg `dv' treat_`treat' ${lasso_ctls} ${cov_always}    
				matrix table = r(table)
			}
			
			/* If lasso selected no covariates */
			if ${lasso_ctls_num} == 0 {		
				qui reg `dv' treat_`treat' ${cov_always}
				matrix table = r(table)
			}
			
		/* Save values from regression */
		global lasso_coef_`treat' 	= table[1,1]    	//beta
		global lasso_se_`treat'	    = table[2,1]		//se
		*global lasso_t_c 			= table[3,1]		//t
		global lasso_pval_`treat'   = table[4,1]/2		//pval
		
		global lasso_r2_`treat' 	= `e(r2_a)' 		//r-squared
		global lasso_N_`treat' 		= e(N) 				//N
		}
		
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
	qui putexcel G`row' = ("${r2_courtall}")
	qui putexcel H`row' = ("${N_courtall}")
	
	qui putexcel I`row' = ("${lasso_coef_courtall}")
	qui putexcel J`row' = ("${lasso_se_courtall}")
	qui putexcel K`row' = ("${lasso_pval_courtall}")
	qui putexcel L`row' = ("${lasso_ripval_courtall}")
	qui putexcel M`row' = ("${lasso_r2_courtall}")
	qui putexcel N`row' = ("${lasso_N_courtall}")
	
	qui putexcel O`row' = ("${treat_mean_courtall}")
	qui putexcel P`row' = ("${treat_sd_courtall}")
	
	qui putexcel Q`row' = ("${coef_courtonly}")
	qui putexcel R`row' = ("${se_courtonly}")
	qui putexcel S`row' = ("${pval_courtonly}")
	qui putexcel T`row' = ("${ripval_courtonly}")
	qui putexcel U`row' = ("${r2_courtonly}")
	qui putexcel V`row' = ("${N_courtonly}")
	
	qui putexcel W`row' = ("${lasso_coef_courtonly}")
	qui putexcel X`row' = ("${lasso_se_courtonly}")
	qui putexcel Y`row' = ("${lasso_pval_courtonly}")
	qui putexcel Z`row' = ("${lasso_ripval_courtonly}")
	qui putexcel AA`row' = ("${lasso_r2_courtonly}")
	qui putexcel AB`row' = ("${lasso_N_courtonly}")
	
	qui putexcel AC`row' = ("${treat_mean_courtonly}")
	qui putexcel AD`row' = ("${treat_sd_courtonly}")
	
	qui putexcel AE`row' = ("${coef_courtag}")
	qui putexcel AF`row' = ("${se_courtag}")
	qui putexcel AG`row' = ("${pval_courtag}")
	qui putexcel AH`row' = ("${ripval_courtag}")
	qui putexcel AI`row' = ("${r2_courtag}")
	qui putexcel AJ`row' = ("${N_courtag}")
	
	qui putexcel AK`row' = ("${lasso_coef_courtag}")
	qui putexcel AL`row' = ("${lasso_se_courtag}")
	qui putexcel AM`row' = ("${lasso_pval_courtag}")
	qui putexcel AN`row' = ("${lasso_ripval_courtag}")
	qui putexcel AO`row' = ("${lasso_r2_courtag}")
	qui putexcel AP`row' = ("${lasso_N_courtag}")
	
	qui putexcel AQ`row' = ("${treat_mean_courtag}")
	qui putexcel AR`row' = ("${treat_sd_courtag}")
	
	qui putexcel AS`row' = ("${lasso_ctls}")
	qui putexcel AT`row' = ("${lasso_ctls_num}")
	
	qui putexcel AU`row' = ("${ctl_mean}")
	qui putexcel AV`row' = ("${ctl_sd}")
	qui putexcel AW`row' = ("${ctl_N}")
	qui putexcel AX`row' = ("${vill_sd}")
	qui putexcel AY`row' = ("${min}")
	qui putexcel AZ`row' = ("${max}")
	qui putexcel BA`row' = ("${test}")
	qui putexcel BB`row' = ("${N_courtonly_sample}")
	qui putexcel BC`row' = ("${N_courtag_sample}")
	qui putexcel BD`row' = ("${N_courtall_sample}")

	/* Update locals ___________________________________________________________*/
	
	local row = `row' + 1
	
}	