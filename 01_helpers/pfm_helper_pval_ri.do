
/* Calculate RI p-value */
if "$test" == "onesided" {

	/* one sided */
	local rip_count = 0
	forval j = 1 / $rerandcount {
	
		qui xi: reg $dv ${treat}_`j' ${cov_always} [pweight=${ipw}_`j']
			matrix RIP = r(table)
			local coef_ri = RIP[1,1]
			if ${coef} < `coef_ri' { 	  
					local rip_count = `rip_count' + 1	
			}
	}	
}


if "$test" == "onesidedneg" {

	/* one sided */
	local rip_count = 0
	forval j = 1 / $rerandcount {
	
		qui xi: reg $dv ${treat}_`j' ${cov_always} [pweight=${ipw}_`j']
			matrix RIP = r(table)
			local coef_ri = RIP[1,1]
			if ${coef} > `coef_ri' { 	  
					local rip_count = `rip_count' + 1	
			}
	}	
}


if "$test" == "twosided" {

	/* two sided */
	local rip_count = 0
	forval j = 1 / $rerandcount {
	
		qui xi: reg $dv ${treat}_`j' ${cov_always} [pweight=${ipw}_`j']
			matrix RIP = r(table)
			local coef_ri = RIP[1,1]
			
			if abs(${coef}) < abs(`coef_ri') { 	  
				local rip_count = `rip_count' + 1	
			}
	}
}

	di "`rip_count' AND $rerandcount"
	global helper_ripval = `rip_count' / $rerandcount
	
	
		
	