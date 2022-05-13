
/* Basics ______________________________________________________________________

	Project: Wellspring Tanzania
	Purpose: Analysis
	Author: dylan groves, dylanwgroves@gmail.com
	Date: 2020/12/23
________________________________________________________________________________*/


forval i = 1/$count {

	macro drop s`i'
	macro drop s`i'c
	
	/* Stars */
	
		/* Normal */																
		if ${p`i'} < 0.1 {
			global s`i' "*"
		}
			if ${p`i'} < 0.05 {
				global s`i' "**"
			}
				if ${p`i'} < 0.01 {
					global s`i' "***"
				}	
				
		if ${p`i'c} < 0.1 {
			global s`i'c "*"
		}
			if ${p`i'c} < 0.05 {
				global s`i'c "**"
			}
				if ${p`i'c} < 0.01 {
					global s`i'c "***"
				}		
		
		
		/* Restrictive 
		if ${p`i'} < 0.005 {
			global s`i' "*"
		}
		
		if ${p`i'c} < 0.005 {
			global s`i'c "*"
		}
		*/
	

	/* p-value setting */
		if ${p`i'} < 0.001 {
			global p`i' "<0.001"
			}
			
		if ${p`i'c} < 0.001 {
			global p`i'c "<0.001"
			}
}
