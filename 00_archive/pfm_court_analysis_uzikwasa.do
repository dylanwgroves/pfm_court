/* Basics ______________________________________________________________________

Project: Wellspring Tanzania, Womens Political Participation
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

	
/* Run Prelim File _____________________________________________________________ // comment out if you dont need to rerun prelim cleaning	
*/
	*do "${code}/pfm_.master/00_setup/pfm_paths_master.do"
	do "${code}/pfm_court/pfm_court_prelim.do"

	
/* Load Data ___________________________________________________________________*/	

	use "${data_court}/pfm_court_analysis.dta", clear


/* Define Globals and Locals ___________________________________________________*/
	#d ;
		
		/* Set seed */
		set seed 			1956
							;
							
		/* Outcomes */
		local outcomes		em_reject
							em_reject_all
							em_reject_index
							em_reject_religion_dum 
							em_reject_money_dum
							em_norm_reject_dum
							em_report
							em_report_norm
							em_record_shareptix
							em_record_sharepfm
							;
		
		/* Covariates */	
		global cov_always	i.pi_treat
							fm_reject
							;		
							
		/* Statitistics of interest */
		local stats_list 	
							ctl_mean											
							ctl_sd	
							ctl_n
							court_mean											
							court_sd	
							court_n
							court_coef 
							court_se 
							court_pval
							both_mean
							both_sd 
							both_n
							both_coef
							both_se 
							both_pval
							min													
							max													
							;

#d cr

rename treat treat_old
recode treat_old (1 = 2 "Court") ///
				 (2 = 1 "Both"), ///
				 gen(treat)


	/* Define Matrix ___________________________________________________________
		
		This section prepares an empty matrix to hold results
		
	*/

		local var_list `outcomes'
		local varnames ""   
		local varlabs ""   
		local mat_length `: word count `var_list'' 
		local mat_width `: word count `stats_list'' 
		mat R =  J(`mat_length', `mat_width', .)
		
		
	/* Export Regression ___________________________________________________________*/

	local i = 1

	foreach dv of local var_list  {

		/* Variable Name */
		qui ds `dv'
			local varname = "`r(varlist)'"  
			*local varlab: var label `var'  										// Could capture variable label in future	
			local varnames `varnames' `varname'   
			*local varlabs `varlabs' `varlab' 

	/* Basic Regression  _______________________________________________________*/

		/* Run basic regression */
		xi: reg `dv' i.treat ${cov_always}						// This is the core regression

			/* Save beta on treat, se, R, N, means (save space for pval!) */
			matrix table = r(table)
			matrix list table	
			
			local court_coef = table[1,1]    									//beta
			local court_se = table[2,1]   										//se	
			local court_pval = table[4,1]										//pval
			
			local both_coef = table[1,2]    									//beta
			local both_se = table[2,2]   										//se	
			local both_pval = table[4,2]										//pval
	
	/* Gather Summary Statistics _______________________________________________*/
		
		/* Treat/Control Mean */
		qui sum `dv' if treat == 0
			local control_mean `r(mean)'
			local control_sd `r(sd)'
			local control_n `r(N)'
		
		qui sum `dv' if treat == 1
			local court_mean `r(mean)'
			local court_sd `r(sd)'
			local court_n `r(N)'

		qui sum `dv' if treat == 2
			local both_mean `r(mean)'
			local both_sd `r(sd)'
			local both_n `r(N)'

		/* Variable Range */
		qui sum `dv' 
			local min = r(min)
			local max = r(max)
		
		/* Save variable summaries */
			mat R[`i',1]= `control_mean'    									// control mean
			mat R[`i',2]= `control_sd'    										// control_sd	
			mat R[`i',3]= `control_n'    										// control_n
			mat R[`i',4]= `court_mean'    										// court mean
			mat R[`i',5]= `court_sd'    										// court_sd	
			mat R[`i',6]= `court_n'    											// court_n	
			mat R[`i',7]= `court_coef'    										// court coef
			mat R[`i',8]= `court_se'    										// court_se	
			mat R[`i',9]= `court_pval'    										// court_pval	
			mat R[`i',10]= `both_mean'    										// both mean
			mat R[`i',11]= `both_sd'    										// both sd
			mat R[`i',12]= `both_n'    											// both n
			mat R[`i',13]= `both_coef'    										// both ceof
			mat R[`i',14]= `both_se'    										// both se
			mat R[`i',15]= `both_pval'    										// both pval
			mat R[`i',16]= `min'  												// min
			mat R[`i',17]= `max'  												// max

	local i = `i' + 1 
	}

		
/* Export Matrix _______________________________________________________________*/ 
	
	preserve 
	/* Row Names */
	mat rownames R = `varnames'  

	/* Transfer matrix to using dataset */
	clear
	svmat R, names(name)

	/* Create a variable for each outcome */
	gen outcome = "" 
	order outcome, before(name1)
	local i = 1 
	foreach var in `var_list' { 
		replace outcome="`var'" if _n==`i' 
		local ++i
	}

	/* Label regression statistics variables */
	local i 1 
	foreach col in `stats_list' { 
		cap confirm variable name`i' 	
		if _rc==0 {
			rename name`i' `col'
			local ++i
		} 
	}  


/* Export ______________________________________________________________________*/
			
	/* Main */
	export excel using "${uzikwasa}/pfm_court_tables_uzikwasa.xlsx", sheet(`index') sheetreplace firstrow(variables) keepcellfmt
			
	restore



	
