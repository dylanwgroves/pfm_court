
			if strpos("$treat", "treat_courtag") {
					global helper_lasso_pval = 2*ttail(e(df_r),abs(${lasso_t}))
			}
				
			if strpos("$treat", "treat_courtvsag") {
					if table[1,1] < 0 {
						global helper_lasso_pval = ttail(e(df_r),abs(${lasso_t})) 
					}
						else if table[1,1] > 0 {
							global helper_lasso_pval = 1-ttail(e(df_r),abs(${lasso_t}))
						}
			}

			if strpos("$treat", "treat_courtonly") {
					if table[1,1] > 0 {
						global helper_lasso_pval = ttail(e(df_r),abs(${lasso_t})) 
					}
						else if table[1,1] < 0 {
							global helper_lasso_pval = 1-ttail(e(df_r),abs(${lasso_t}))
						}
			}