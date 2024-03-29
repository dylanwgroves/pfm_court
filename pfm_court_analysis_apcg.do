/* Basics ______________________________________________________________________

	Project: Wellspring Tanzania, Court Influence
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
		//egen em_reject_all = rowmin(em_reject em_reject_money_dum em_reject_religion_dum)


	/* Define Globals and Locals ___________________________________________________*/
		#d ;
			
			/* Rerandomization count */
			global rerandcount	20
								;
					
			/* Set seed */
			set seed 			1956
								;
								
			/* Treatments */
			global treats		
								courtonly
								;
								/*
								courtonly
								courtag
								courtvsag
								*/
			
			/* Outcomes */
			global em 						
								em_reject_all
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
								reason_courts
								;
								/*

								*/	
			
			/* Covariates */	
			global cov_always	i.treat_pi
								;		
			
			/* Lasso Covariates */
			global cov_lasso	fm_reject
								resp_female
								resp_muslim
								resp_age
								i.village
								i.svy_enum
								;						
			
		#d cr

	*drop if startdate < mdy(10, 12, 2020)
		
	/* Move this to prelim */ 
	*replace treat_courtag = 0 if treat_courtonly == 1
	*replace treat_courtonly = 0 if treat_courtag == 1
	gen treat_courtvsag = 0 if treat_courtonly == 1
		replace treat_courtvsag = 1 if treat_courtag == 1
		
		
	foreach var of varlist fm_reject resp_female resp_muslim resp_age {
	
		egen std_`var' = std(`var')
		replace `var' = std_`var'
		drop std_`var'
	
	}

reg em_reject_all i.treat_courtonly##c.resp_female
	
	stop
foreach treat of global treats {

	global treat treat_`treat'

/* Run for Each Index __________________________________________________________*/

	/* Define Matrix ___________________________________________________________*/
				
		/* Set Put Excel File Name */
		putexcel clear
		putexcel set "${court_tables}/pfm_court_analysis_bjps.xlsx", sheet(`treat', replace) modify
		
		qui putexcel A1 = ("variable")
		qui putexcel B1 = ("variablelabel")
		
		qui putexcel C1 = ("coef_`treat'")
		qui putexcel D1 = ("se_`treat'")
		qui putexcel E1 = ("pval_`treat'")
		qui putexcel F1 = ("ripval_`treat'")
		qui putexcel G1 = ("r2")
		qui putexcel H1 = ("N")
		
		qui putexcel I1 = ("lasso_coef_`treat'")
		qui putexcel J1 = ("lasso_se_`treat'")
		qui putexcel K1 = ("lasso_pval_`treat'")
		qui putexcel L1 = ("lasso_ripval_`treat'")
		qui putexcel M1 = ("lasso_r2")
		qui putexcel N1 = ("lasso_N")
		
		qui putexcel O1 = ("treat_mean_courtonly")
		qui putexcel P1 = ("treat_sd_courtonly")

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
		
		* Set DV
		global dv `dv'
		
		qui ds `dv'
			global varname = "`r(varlist)'"  
			
		
		/* Set IPW */
		global ipw ipw_`treat'
		
		/* Outcome label 
		global varlabel : var label `dv'
		*/
		
		/* Control mean */
		qui sum `dv' if $treat == 0
			global ctl_mean `r(mean)'
			global ctl_sd `r(sd)'
			
		/* min and max */
		qui sum `dv' 
			global min `r(min)'
			global max `r(max)'
		
		/* Control village sd */
		preserve
		qui collapse (mean) $dv $treat, by(village)
		qui sum `dv'
			global vill_sd : di %6.3f `r(sd)'
		restore

		/* Run basic regression */
		qui sum $dv if $treat == 1
			global treat_mean `r(mean)'
			global treat_sd `r(sd)'
		
		reg $dv $treat ${cov_always} [pweight=ipw], robust					     				// This is the core regression
		
			matrix table = r(table)
			
			/* Save values from regression */
			global coef 	= table[1,1]    	//beta
			global se	 	= table[2,1]		//se
			global t  	 	= table[3,1]		//t
			global r2 		= `e(r2_a)' 		//r-squared
			global N 		= e(N) 				//N
			
			/* Set the test */
			if strpos("$treat", "treat_courtag") {
					global test twosided
			}
				
			if strpos("$treat", "treat_courtvsag") {
						global test onesidedneg
			}

			if strpos("$treat", "treat_courtonly") {
						global test onesided
			}
			
			do "${code}/pfm_court/01_helpers/pfm_helper_pval.do"
			global pval = ${helper_pval}
			
			do "${code}/pfm_court/01_helpers/pfm_helper_pval_ri.do"
			global ripval = ${helper_ripval}


/* Run lasso regression ________________________________________________________*/	
					
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
				reg $dv $treat ${lasso_ctls} ${cov_always} [pweight=ipw], robust 
				matrix table = r(table)
			}
			
			/* If lasso selected no covariates */
			if ${lasso_ctls_num} == 0 {		
				reg $dv $treat ${cov_always} [pweight=ipw]
				matrix table = r(table)
			}
			
			/* Save values from regression */
			global lasso_coef = table[1,1]    	//beta
			global lasso_se   = table[2,1]		//se
			global lasso_t    = table[3,1]		//t
			global lasso_r2   = `e(r2_a)' 		//r-squared
			global lasso_N 	  = e(N) 			//N
			
			/* Set the test */
			if strpos("$treat", "treat_courtag") {
					global test twosided
			}
				
			if strpos("$treat", "treat_courtvsag") {
						global test onesidedneg
			}

			if strpos("$treat", "treat_courtonly") {
						global test onesided
			}
					

			do "${code}/pfm_court/01_helpers/pfm_helper_pval_lasso.do"
			global lasso_pval = ${helper_lasso_pval}
			
			do "${code}/pfm_court/01_helpers/pfm_helper_pval_ri_lasso.do"
			global lasso_ripval = ${helper_lasso_ripval}

		
/* Export to Excel _____________________________________________________________*/ 

	qui putexcel A`row' = ("${varname}")
	qui putexcel B`row' = ("${variablelabel}")
	
	qui putexcel C`row' = ("${coef}")
	qui putexcel D`row' = ("${se}")
	qui putexcel E`row' = ("${pval}")
	qui putexcel F`row' = ("${ripval}")
	qui putexcel G`row' = ("${r2}")
	qui putexcel H`row' = ("${N}")
	
	qui putexcel I`row' = ("${lasso_coef}")
	qui putexcel J`row' = ("${lasso_se}")
	qui putexcel K`row' = ("${lasso_pval}")
	qui putexcel L`row' = ("${lasso_ripval}")
	qui putexcel M`row' = ("${lasso_r2}")
	qui putexcel N`row' = ("${lasso_N}")
	
	qui putexcel O`row' = ("${treat_mean}")
	qui putexcel P`row' = ("${treat_sd}")
	
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
}