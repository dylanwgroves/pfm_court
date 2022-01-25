use "X:\Dropbox\Dylan - Data\Afrobarometer\2019\r7_merged_data_34ctry.dta", clear

bys URBRUR: tab Q43I COUNTRY, col




keep if COUNTRY == 29


foreach var in Q43A Q43B Q43C Q43D Q43E Q43F Q43G Q43H Q43I Q43J Q43K {

	tab `var' URBRUR, col

}