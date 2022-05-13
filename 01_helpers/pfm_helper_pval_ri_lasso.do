
/* Calculate Lasso RI p-value */

/* one-sided */
if "$test" == "onesided" {

									
	local lasso_rip_count = 0
	forval k = 1/$rerandcount {
		
		if ${lasso_ctls_num} != 0 {											// If lassovars selected						
			qui regress $dv ${treat}_`k' ${cov_always} ${lasso_ctls} [pweight=${ipw}_`k']
				matrix LASSO_RIP = r(table)
			}
			
			else if ${lasso_ctls_num} == 0 {							// If lassovars not selected
				qui regress $dv ${treat}_`k' ${cov_always} [pweight=${ipw}_`k']
					matrix LASSO_RIP = r(table)
			}	
			
			local lasso_coef_ri = LASSO_RIP[1,1]
				
			if ${lasso_coef} < `lasso_coef_ri' { 	  
					local lasso_rip_count = `lasso_rip_count' + 1	
			}
	}
}


if "$test" == "onesidedneg" {

									
	local lasso_rip_count = 0
	forval k = 1/$rerandcount {
		
		if ${lasso_ctls_num} != 0 {											// If lassovars selected						
			qui regress $dv treat_`k' ${cov_always} ${lasso_ctls} [pweight=${ipw}_`k']
				matrix LASSO_RIP = r(table)
			}
			
			else if ${lasso_ctls_num} == 0 {							// If lassovars not selected
				qui regress $dv ${treat}_`k' ${cov_always} [pweight=${ipw}_`k']
					matrix LASSO_RIP = r(table)
			}	
			
			local lasso_coef_ri = LASSO_RIP[1,1]
				
			if ${lasso_coef} > `lasso_coef_ri' { 	  
					local lasso_rip_count = `lasso_rip_count' + 1	
			}
	}
}


/* two-sided */

if "$test" == "twosided" {

									
	local lasso_rip_count = 0
	forval k = 1/$rerandcount {
		
		if ${lasso_ctls_num} != 0 {											// If lassovars selected						
			qui regress $dv treat_`k' ${cov_always} ${lasso_ctls} [pweight=${ipw}_`k']
				matrix LASSO_RIP = r(table)
			}
			
			else if ${lasso_ctls_num} == 0 {							// If lassovars not selected
				qui regress $dv treat_`k' ${cov_always} [pweight=${ipw}_`k']
					matrix LASSO_RIP = r(table)
			}	
			
			local lasso_coef_ri = LASSO_RIP[1,1]
							
			if abs(${lasso_coef}) < abs(`lasso_coef_ri') { 	  
				local lasso_rip_count = `lasso_rip_count' + 1	
			}
	}
}

	
	global helper_lasso_ripval = `lasso_rip_count' / $rerandcount