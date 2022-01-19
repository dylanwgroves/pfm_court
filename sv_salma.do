

//*Salma's Randomization file//
use "C:\Users\CBSPC-5\Dropbox\Wellspring Tanzania - Court\01_data\pfm_court_analysis.dta", clear

forval x = 1/1000 {

	* Set Seed
	set seed `x'
	gen random_`x'=runiform()
	gen faketreat_`x'=0 if random_`x'<1/3
replace faketreat_`x'=1 if random_`x'>1/3 & random_`x'<2/3
replace faketreat_`x'=2 if random_`x'>2/3


gen fakecourt_treat_`x'=1 if faketreat_`x'==2
replace fakecourt_treat_`x'=0 if faketreat_`x'==0

reg em_report fakecourt_treat_`x'

	}
stop

set seed 30
gen random_1=runiform()
gen faketreat_1=0 if random_1<1/3
replace faketreat_1=1 if random_1>1/3 & random_1<2/3
replace faketreat_1=2 if random_1>2/3
order faketreat_1
tab faketreat_1
gen fakecourt_treat_1=1 if faketreat_1==2
replace fakecourt_treat_1=0 if faketreat_1==0
tab fakecourt_treat_1
reg em_report fakecourt_treat_1
//NUMBER TWO//
set seed 2
gen random_2=runiform()
gen faketreat_2=0 if random_2<1/3
replace faketreat_2=1 if random_2>1/3 & random_2<2/3
replace faketreat_2=2 if random_2>2/3
order faketreat_2
tab faketreat_2
gen fakecourt_treat_2=1 if faketreat_2==2
replace fakecourt_treat_2=0 if faketreat_2==0
tab fakecourt_treat_2
reg em_report fakecourt_treat_2
reg em_report fakecourt_treat_1


















reg em_report treat_courtonly
tab treat
stop








order random_1
order random_2
br
