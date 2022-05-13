/* One-sided p-value for predicted effects */
	
	if table[1,1] > 0 {
		global helper_pval = ttail(e(df_r),abs(${t})) 
	}
	
	else if table[1,1] < 0 {
		global helper_pval = 1-ttail(e(df_r),abs(${t}))
	}