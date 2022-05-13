

if $test = "onesided" {

	/* Calculate one-side pvalue */
	if $coef > 0 {
		global pval = ttail(${df},abs(${t})) 
	}
	else if $coef < 0 {
		global pval = 1-ttail(${df},abs(${t}))
	}

}
	
if $test = "twosided" {

	/* Calculate two-side pvalue */
	global pval = 2*ttail(${df},abs(${t})) 

}

