
/* Basics ______________________________________________________________________

	Project: Wellspring Tanzania, Development News
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

	do "${code}/pfm_devnews/pfm_devnews_prelim.do"

	
/* Balance _____________________________________________________________________*/

	*do "${code}/pfm_court/pfm_court_02_balance.do"
	
/* Analysis ____________________________________________________________________*/

	do "${code}/pfm_devnews/pfm_devnews_analysis.do"
	
/* Tables ______________________________________________________________________*/

	texdoc do "${code}/pfm_devnews/pfm_devnews_tables.texdoc"
	
	
	/* Appendix */
	texdoc do "${code}/pfm_court/pfm_court_tables_appendix_variables.texdoc"


