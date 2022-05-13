

if $test = "onesided" {

	/* Calculate one-side pvalue */
	if $coef > 0 {
		global lasso_helper_pval = ttail(${lasso_df},abs(${lasso_t})) 
	}
	else if $coef < 0 {
		global lasso_helper_pval = 1-ttail(${lasso_df},abs(${lasso_t}))
	}

}
	
if $test = "twosided" {

	/* Calculate two-side pvalue */
	global lasso_helper_pval = 2*ttail(${lasso_df},abs(${lasso_t})) 

}

