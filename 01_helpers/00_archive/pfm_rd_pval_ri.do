
/* Calculate RI p-value */
	local rip_count = 0
	forval j = 1 / $rerandcount {
	
		qui xi: reg $dv treat_`j' ${cov_always}
			matrix RIP = r(table)
			local coef_ri = RIP[1,1]
			if ${coef} > 0 {
				if ${coef} < `coef_ri' { 	  
					local rip_count = `rip_count' + 1	
				}
			}
			
			if ${coef} < 0 {
				if abs(${coef}) < abs(`coef_ri') { 	  
					local rip_count = `rip_count' + 1	
				}
			}
	}
	
	global helper_ripval = `rip_count' / $rerandcount
	

			
	