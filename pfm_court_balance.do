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
			global balancevars						
								fm_reject 
								fm_reject_long
								resp_female
								resp_muslim
								resp_age 
								prej_thermo_out_rel 
								prej_thermo_out_eth
								resp_married
								values_conformity
								resp_yrsinvill
								resp_villknow
								ge_kids_idealnum
								ge_kids_idealage
								resp_religiousschool 
								values_tzovertribe_dum
								prej_kidmarry_index
								prej_yesnbr_index
								ptixpref_rank_ag ptixpref_rank_crime 
								ptixpref_rank_efm ptixpref_rank_edu 
								ptixpref_rank_justice ptixpref_rank_electric 
								ptixpref_rank_sanit ptixpref_rank_roads 
								ptixpref_rank_health
								;
			
			/* Covariates */	
			global cov_always	svy_partner 
								i.treat_pi
								;		
			
			/* Lasso Covariates 
			global cov_lasso	fm_reject
								fm_reject_long
								resp_female
								resp_muslim
								resp_age
								i.village
								;						
			*/
		#d cr

	
	drop if startdate < mdy(12, 11, 2020)
	
	replace treat_courtonly = 0 if treat_courtag == 1
	replace treat_courtag = 0 if treat_courtonly == 1

/* Run for Each Index __________________________________________________________*/

	/* Define Matrix _______________________________________________________________*/
				
		/* Set Put Excel File Name */
		putexcel clear
		putexcel set "${court_tables}/pfm_court_balance.xlsx", replace
		
		qui putexcel A1 = ("variable")
		qui putexcel B1 = ("variablelabel")
		
		qui putexcel C1 = ("jointpvalue")
		
		qui putexcel D1 = ("coef_courtonly")
		qui putexcel E1 = ("se_courtonly")
		qui putexcel F1 = ("pval_courtonly")
		qui putexcel G1 = ("ripval_courtonly")

		qui putexcel H1 = ("treat_mean_courtonly")
		qui putexcel I1 = ("treat_sd_courtonly")
		
		qui putexcel J1 = ("coef_courtag")
		qui putexcel K1 = ("se_courtag")
		qui putexcel L1 = ("pval_courtag")
		qui putexcel M1 = ("ripval_courtag")
		
		qui putexcel N1 = ("treat_mean_courtag")
		qui putexcel O1 = ("treat_sd_courtag")
		
		qui putexcel P1 = ("r2")
		qui putexcel Q1 = ("N")
		
		qui putexcel R1 = ("ctl_mean")
		qui putexcel S1 = ("ctl_sd")

		qui putexcel T1 = ("min")
		qui putexcel U1 = ("max")
	

local row = 2	
foreach dv of global balancevars {		
	
/* Standard Regression _________________________________________________________*/

		qui ds `dv'
			global variable = "`r(varlist)'"  
			
		/* Outcome label */
			global varlabel : var label `dv'
		
		
		/* Control mean */
		qui sum `dv' if treat_courtall == 0
			global ctl_mean = `r(mean)'
			global ctl_sd = `r(sd)'
			
	
		/* Court mean */
		qui sum `dv' if treat_courtonly == 1
			global treat_mean_courtonly = `r(mean)'
			global treat_sd_courtonly = `r(sd)'
			
		/* AG mean */
		qui sum `dv' if treat_courtag == 1
			global treat_mean_courtag = `r(mean)'
			global treat_sd_courtag = `r(mean)'
			
		/* min and max */
		qui sum `dv' 
			global min `r(min)'
			global max `r(max)'
		
		/* Run basic regression */
		qui reg `dv' treat_courtonly treat_courtag 					     		// This is the core regression
			matrix table = r(table)
			
			/* Save values from regression */
			global coef_courtonly = table[1,1]    	//beta
			global sd_courtonly = table[2,1]
			global pval_courtonly = table[4,1]
			
			global coef_courtag = table[1,2]
			global sd_courtag = table[2,2]
			global pval_courtag = table[4,2]
			
			qui testparm treat_courtonly treat_courtag 
				global jointpvalue = `r(p)'

			global r2 	= `e(r2_a)' 		//r-squared
			global N 	= e(N) 				//N

/* Run lasso regression ____________________________________________________
					
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
*/			
		
/* Export to Excel _________________________________________________________*/ 

		qui putexcel A`row' = ("${variable}")
		qui putexcel B`row' = ("${variablelabel}")
		
		qui putexcel C`row' = ("${jointpvalue}")
		
		qui putexcel D`row' = ("${coef_courtonly}")
		qui putexcel E`row' = ("${se_courtonly}")
		qui putexcel F`row' = ("${pval_courtonly}")
		qui putexcel G`row' = ("${ripval_courtonly}")

		qui putexcel H`row' = ("${treat_mean_courtonly}")
		qui putexcel I`row' = ("${treat_sd_courtonly}")
		
		qui putexcel J`row' = ("${coef_courtag}")
		qui putexcel K`row' = ("${se_courtag}")
		qui putexcel L`row' = ("${pval_courtag}")
		qui putexcel M`row' = ("${ripval_courtag}")
		
		qui putexcel N`row' = ("${treat_mean_courtag}")
		qui putexcel O`row' = ("${treat_sd_courtag}")
		
		qui putexcel P`row' = ("${r2}")
		qui putexcel Q`row' = ("${N}")
		
		qui putexcel R`row' = ("${ctl_mean}")
		qui putexcel S`row' = ("${ctl_sd}")

		qui putexcel T`row' = ("${min}")
		qui putexcel U`row' = ("${max}")

	
	/* Update locals ___________________________________________________________*/
	
	local row = `row' + 1
	
}	