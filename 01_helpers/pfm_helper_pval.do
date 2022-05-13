

			if strpos("$treat", "treat_courtag") {
					global helper_pval = 2*ttail(e(df_r),abs(${t}))
			}
				
			if strpos("$treat", "treat_courtvsag") {
					if table[1,1] < 0 {
						global helper_pval = ttail(e(df_r),abs(${t})) 
					}
						else if table[1,1] > 0 {
							global helper_pval = 1-ttail(e(df_r),abs(${t}))
						}
			}

			if strpos("$treat", "treat_courtonly") {
					if table[1,1] > 0 {
						global helper_pval = ttail(e(df_r),abs(${t})) 
					}
						else if table[1,1] < 0 {
							global helper_pval = 1-ttail(e(df_r),abs(${t}))
						}
			}
						

di "$helper_pval"
