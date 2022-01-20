
/* Basics ______________________________________________________________________

	Project: Wellspring Tanzania, Courts Survey Experiment
	Purpose: Master
	Author: dylan groves, dylanwgroves@gmail.com
	Date: 2021/04/26
________________________________________________________________________________*/


/* Introduction ________________________________________________________________*/
	
	clear all	
	clear matrix
	clear mata
	set more off
	global c_date = c(current_date)
	set seed 1956

/* Paths and master ____________________________________________________________*/	

	do "${code}/pfm_.master/00_setup/pfm_paths_master.do"
	do "${code}/pfm_.master/pfm_master.do"

	
/* RD prelim ___________________________________________________________________*/

	do "${code}/pfm_court/pfm_court_prelim.do"

	
/* Balance _____________________________________________________________________*/

	*do "${code}/pfm_court/pfm_court_02_balance.do"
	
/* Analysis ____________________________________________________________________*/

	do "${code}/pfm_court/pfm_court_analysis.do"
	
/* Tables ______________________________________________________________________*/

	texdoc do "${code}/pfm_court/pfm_court_tables_balance.texdoc"
	
	texdoc do "${code}/pfm_court/pfm_court_tables_means.texdoc"
	
	texdoc do "${code}/pfm_court/pfm_court_tables_attitudesnorms_each.texdoc"
	texdoc do "${code}/pfm_court/pfm_court_tables_reporting_each.texdoc"
	texdoc do "${code}/pfm_court/pfm_court_tables_speakout_each.texdoc"
	
	/* Appendix */
	texdoc do "${code}/pfm_court/pfm_court_tables_appendix_variables.texdoc"


	
	texdoc do "${code}/pfm_court/pfm_court_tables_attitudes_apcg.texdoc"
	texdoc do "${code}/pfm_court/pfm_court_tables_norms_apcg.texdoc"
	texdoc do "${code}/pfm_court/pfm_court_tables_courtsvsag_apcg.texdoc"


