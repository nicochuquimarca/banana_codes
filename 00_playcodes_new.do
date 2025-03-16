	clear all
	set more off 
	set maxvar 50000
	set scheme s2mono
	set seed 1234
	* Working folder path
	cd "C:\Users\nicoc\Dropbox\Pre_OneDrive_USFQ\PCNICOLAS_HP_PAVILION\Masters\USFQ\USFQ_EconReview\Author"
	global texout "C:\Users\nicoc\Dropbox\Apps\Overleaf\BananaPapers\figures"



* Tabla 16: XXX
import excel using "data\raw\censo_1954\censo_1954.xlsx", ///
	   sheet("tabla 16") first clear
* Remove aggregated values.
drop if provincia == "Ecuador" // Drop the national aggregation value
keep if producto  == "Cacao"   // Keep cacao
* Get a province identifier (handle Canar and Loja special cases)
gen counter = _n
gen prov_dummy = 1 if provincia == canton
replace prov_dummy = . if provincia == "Loja"  & produccion == 0 // Loja canton
replace prov_dummy = . if provincia == "Canar" & counter == 12 // Canar canton
replace prov_dummy = 0 if prov_dummy == .
* Rename variable names
rename n_expotaciones cacao_n_explotaciones
rename total_arboles cacao_total_arboles 
rename arboles_prod cacao_arboles_prod 
rename produccion cacao_produccion
replace cacao_produccion = cacao_produccion/1000
* Label some variables
label var cacao_n_explotaciones "Plantations: Number of Cacao plantations"
label var cacao_total_arboles "Cacao Trees"
label var cacao_arboles_prod "Cacao Trees in Productive Stage"
label var cacao_produccion "Cacao Output: Thousand of Kg"
* Get rid of the province level data
drop if prov_dummy == 1
* Drop repeted variables and prepare for the merge
drop producto counter prov_dummy