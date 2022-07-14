/* _____________________________________________________________________________

	Project: Wellspring Tanzania
	Author: Dylan Groves, bm2955@columbia.edu

	Date: 2022/05/20
________________________________________________________________________________*/


/* Introduction ________________________________________________________________*/
	
	clear all	
	clear matrix
	clear mata
	set more off																			
	
/* INTERESTKNOWLEDGE ___________________________________________________________*/	

		/* define matrix */		

			import excel "${court_tables}/pfm_court_analysis_apcg_test.xlsx", sheet(courtonly) firstrow clear
			
			/* Individual Data */
			# d ;
			local sumstat_vars 
				em_reject_index
				em_reject_all
				em_reject
				em_reject_money_dum
				em_reject_religion_dum
				em_report
				em_norm_reject_dum
				em_report_norm
				em_record_shareptix
				em_record_sharepfm
				reason_courts
				;
			#d cr 
								
				gen rank = .
				local i = 1
				
				foreach var of local sumstat_vars {
					replace rank = `i' if variable == "`var'"
					local i = `i' + 1
				}	
				
			sort rank
			
			destring coef	se, replace
			gen lowb = coef - (se * 1.65)
			gen uppb = coef + (se * 1.65)
			drop if variable == "em_record_shareany"
			
			mkmat coef lowb uppb, mat(COURTONLY)
			matrix rownames COURTONLY = "Reject EM index - average (control mean = 0.82)"					///
										"Reject EM index - reject all (0.67)" 		/// 
										"Reject EM general (0.92)"						///
										"Reject EM when family needs money (0.76)"		///
										"Reject EM when religion permits (0.78)"		///
										"Report EM to authorities (0.62)"				///
										"Believe community rejects EM (0.62)"			///
										"Believe community would report EM (0.39)"		///
										"Share anti-EM message with DC (0.50)"			///
										"Share anti-EM message with Pangani FM (0.52)"	///
										"Refer to courts and laws to justify (0.04)"

		/* generate coeffplot */
		
			matselrc COURTONLY X_COURTONLY, row(1/11)

			coefplot 	matrix(X_COURTONLY[,1]), ///
														mcolor(black) ///
														ci((X_COURTONLY[,2] X_COURTONLY[,3] ))  ///
														ciopts(lcolor(black)) ///
														xline(0) ///
														xscale(r(-0.15(0.05)0.15)) ///
														xlab(-0.15(0.05)0.15) 				///
														graphregion(color(white)) ///
														bgcolor(white) xtitle("") ///
														ytitle("")  ///
														coeflabels(, notick labgap(-122))	///
														yscale(noline alt) ///
														graphregion(margin(l=60)) ///
														legend(off) ///
														headings(	"Reject EM index - average (control mean = 0.82)" = "{bf:Attitudes}" ///
																	"Report EM to authorities (0.62)" = "{bf:Reporting}" ///
																	"Believe community rejects EM (0.62)" = "{bf:Perceived Norms}" ///	
																	"Share anti-EM message with DC (0.50)" = "{bf:Share Anti-EM Message}", labgap(-122))  
														
														
					 graph export "${court_clean_figures}/coefplot_COURTONLY.png", as(png) width(3500) height(1500)  replace


/* COURT VS AG ______________________________________________________________________*/	

			import excel "${court_tables}/pfm_court_analysis_apcg_test.xlsx", sheet(courtvsag) firstrow clear
			drop if variable == "em_record_shareany"
			/* Individual Data */
			# d ;
			local sumstat_vars 
				em_reject_index
				em_reject_all
				em_reject
				em_reject_money_dum
				em_reject_religion_dum
				em_report
				em_norm_reject_dum
				em_report_norm
				em_record_shareptix
				em_record_sharepfm
				reason_courts
				;
			#d cr 
								
				gen rank = .
				local i = 1
				
				foreach var of local sumstat_vars {
					replace rank = `i' if variable == "`var'"
					local i = `i' + 1
				}	
				
			sort rank
			
			destring coef	se, replace
			gen lowb = coef - (se * 1.65)
			gen uppb = coef + (se * 1.65)
			drop if variable == "em_record_shareany"
			
			mkmat coef lowb uppb, mat(COURTVSAG)
			matrix rownames COURTVSAG = "Reject EM index - average (court mean = 0.74)"					///
										"Reject EM index - reject all (0.85)" 		/// 
										"Reject EM general (0.95)"						///
										"Reject EM when family needs money (0.80)"		///
										"Reject EM when religion permits (0.82)"		///
										"Report EM to authorities (0.70)"				///
										"Believe community rejects EM (0.60)"			///
										"Believe community would report EM (0.39)"		///
										"Share anti-EM message with DC (0.49)"			///
										"Share anti-EM message with Pangani FM (0.53)"	///
										"Refer to courts and laws to justify (0.06)"

		/* generate coeffplot */
		
			matselrc COURTVSAG X_COURTVSAG, row(1/11)

			coefplot 	matrix(X_COURTVSAG[,1]), ///
														mcolor(black) ///
														ci((X_COURTVSAG[,2] X_COURTVSAG[,3] ))  ///
														ciopts(lcolor(black)) ///
														xline(0) ///
														xscale(r(-0.15(0.05)0.15)) ///
														xlab(-0.15(0.05)0.15) 				///
														graphregion(color(white)) ///
														bgcolor(white) xtitle("") ///
														ytitle("")  ///
														coeflabels(, notick labgap(-122))	///
														yscale(noline alt) ///
														graphregion(margin(l=60)) ///
														legend(off) ///
														headings(	"Reject EM index - average (court mean = 0.74)" = "{bf:Attitudes}" ///
																	"Report EM to authorities (0.70)" = "{bf:Reporting}" ///
																	"Believe community rejects EM (0.60)" = "{bf:Perceived Norms}" ///	
																	"Share anti-EM message with DC (0.49)" = "{bf:Share Anti-EM Message}", labgap(-122))  
											
					 graph export "${court_clean_figures}/coefplot_COURTVSAG.png", as(png) width(3500) height(1500)  replace

						
/* COURT AND AG ______________________________________________________________________*/	

		/* define matrix */		

			import excel "${court_tables}/pfm_court_analysis_apcg_test.xlsx", sheet(courtag) firstrow clear
			
			/* Individual Data */
			# d ;
			local sumstat_vars 
				em_reject_index
				em_reject_all
				em_reject
				em_reject_money_dum
				em_reject_religion_dum
				em_report
				em_norm_reject_dum
				em_report_norm
				em_record_shareptix
				em_record_sharepfm
				reason_courts
				;
			#d cr 
								
				gen rank = .
				local i = 1
				
				foreach var of local sumstat_vars {
					replace rank = `i' if variable == "`var'"
					local i = `i' + 1
				}	
				
			sort rank
			
			destring coef	se, replace
			gen lowb = coef - (se * 1.65)
			gen uppb = coef + (se * 1.65)
			drop if variable == "em_record_shareany"
			
			mkmat coef lowb uppb, mat(COURTAG)
			matrix rownames COURTAG = "Reject EM index - average (control mean = 0.82)"					///
										"Reject EM index - reject all (0.67)" 		/// 
										"Reject EM general (0.92)"						///
										"Reject EM when family needs money (0.76)"		///
										"Reject EM when religion permits (0.78)"		///
										"Report EM to authorities (0.62)"				///
										"Believe community rejects EM (0.62)"			///
										"Believe community would report EM (0.39)"		///
										"Share anti-EM message with DC (0.50)"			///
										"Share anti-EM message with Pangani FM (0.52)"	///
										"Refer to courts and laws to justify (0.04)"

		/* generate coeffplot */
		
			matselrc COURTAG X_COURTAG, row(1/11)

			coefplot 	matrix(X_COURTAG[,1]), ///
														mcolor(black) ///
														ci((X_COURTAG[,2] X_COURTAG[,3] ))  ///
														ciopts(lcolor(black)) ///
														xline(0) ///
														xscale(r(-0.15(0.05)0.15)) ///
														xlab(-0.15(0.05)0.15) 				///
														graphregion(color(white)) ///
														bgcolor(white) xtitle("") ///
														ytitle("")  ///
														coeflabels(, notick labgap(-122))	///
														yscale(noline alt) ///
														graphregion(margin(l=60)) ///
														legend(off) ///
														headings(	"Reject EM index - average (control mean = 0.82)" = "{bf:Attitudes}" ///
																	"Report EM to authorities (0.62)" = "{bf:Reporting}" ///
																	"Believe community rejects EM (0.62)" = "{bf:Perceived Norms}" ///	
																	"Share anti-EM message with DC (0.50)" = "{bf:Share Anti-EM Message}", labgap(-122))  
														
														
					 graph export "${court_clean_figures}/coefplot_COURTAG.png", as(png) width(3500) height(1500)  replace

