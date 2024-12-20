////////////////////////////////////////////////////////////////////////////////
//////////	 			          BANANA PAPERS 				      //////////
////////// 				1954 AGRICULTURAL CENSUS DATA  	              //////////
////////////////////////////////////////////////////////////////////////////////

/*
Pending Job: Check Canar and Loja data --> Canar is duplicated, Loja does not
		     distinguish canton and province.
*/

***************************** SET STATA ****************************************
{
	clear all
	set more off 
	set maxvar 50000
	set scheme s2mono
	set seed 1234
	* Working folder path
	cd "C:\Users\nicoc\Dropbox\Pre_OneDrive_USFQ\PCNICOLAS_HP_PAVILION\Masters\USFQ\USFQ_EconReview\Author"
}
di "End of SET STATA section!"

********************* BANANO AND PLATANO DATA **************************************
{
* Tabla 14: Número estimado de explotaciones, superficies y producción
import excel using "data\raw\censo_1954\censo_1954.xlsx", ///
	   sheet("tabla 14") first clear
* Remove aggregated values.
drop if provincia == "Ecuador" // Drop
 * Get a province identifier (handle Canar and Loja special cases)
gen counter = _n
gen prov_dummy = 1 if provincia == canton
replace prov_dummy = . if provincia == "Loja" & producto == "banano"  & ///
						  n_explotaciones == 1992 // Loja canton
replace prov_dummy = . if provincia == "Loja" & producto == "platano" & ///
						  n_explotaciones == 209  // Loja canton
replace prov_dummy = . if provincia == "Canar" & producto == "banano"  & ///
						  n_explotaciones == 343 // Canar canton
replace prov_dummy = . if provincia == "Canar" & producto == "platano"  & ///
						  counter == 30 // Canar canton
replace prov_dummy = 0 if prov_dummy == .
* Transform strings to integers
encode provincia, gen(provincia_num) label("provincia_labels")
encode canton, gen(canton_num) label("canton_labels")

**** Número de Explotaciones **** 
* Province bar charts
graph bar n_explotaciones if prov_dummy == 1 & producto == "banano", ///
		  over(provincia_num, sort(n_explotaciones)) horizontal ///
		  title("Número de explotaciones bananeras") name(num_explo_banano)

graph bar n_explotaciones if prov_dummy == 1 & producto == "platano", ///
		  over(provincia_num, sort(n_explotaciones)) horizontal ///
		  title("Número de explotaciones de platano") name(num_explo_platano)
* Canton bar charts
* Prepare the data (banano)
preserve
drop if prov_dummy == 1
keep if producto == "banano"
gsort - n_explotaciones
gen n_explo_counter = _n
gen top_25_c_nexplo = 1 if n_explo_counter <= 25
* Do the plot
graph bar n_explotaciones if top_25_c_nexplo == 1, ///
		  over(canton_num, sort(n_explotaciones)) horizontal ///
		  title("Número de explotaciones bananeras") name(num_explo_banano_c)
restore
* Prepare the data (platano)
preserve
drop if prov_dummy == 1
keep if producto == "platano"
gsort - n_explotaciones
gsort - n_explotaciones
gen n_explo_counter = _n
gen top_25_c_nexplo = 1 if n_explo_counter <= 25
graph bar n_explotaciones if top_25_c_nexplo == 1, ///
		  over(canton_num, sort(n_explotaciones)) horizontal ///
		  title("Número de explotaciones de platano") name(num_explo_platano_c)
restore
		  
**** Superficie sembrada **** 
* Province bar charts
graph bar sup_sembrada if prov_dummy == 1 & producto == "banano", ///
		  over(provincia_num, sort(sup_sembrada)) horizontal ///
		  title("Superficie sembrada Banano") name(sup_banano, replace)
* No data for sup_sembrada for platano
graph bar sup_sembrada if prov_dummy == 1 & producto == "platano", ///
		  over(provincia_num, sort(sup_sembrada)) horizontal ///
		  title("Superficie sembrada platano") name(sup_platano, replace)
* Canton bar charts
* Prepare the data (banano)
preserve
drop if prov_dummy == 1
keep if producto == "banano"
gsort - sup_sembrada
gen sup_sembrada_counter = _n
gen top_25_sup_sembrada = 1 if sup_sembrada_counter <= 25
* Do the plot
graph bar sup_sembrada if top_25_sup_sembrada == 1, ///
		  over(canton_num, sort(sup_sembrada)) horizontal ///
		  title("Superficie sembrada banano") name(sup_banano_c)
restore

*** Mean plot size (only for banano)
/*
Pseudo Code: 
	1. Divide sup_sembrada by n_explotaciones to get the average plot size
		1.1. This is a measure of the places were economies of scale were 
			 possible on the production side
*/
* 1. sup_sembrada / n_explotaciones
gen avg_psize = sup_sembrada / n_explotaciones

* Province bar charts
graph bar avg_psize if prov_dummy == 1 & producto == "banano", ///
		  over(provincia_num, sort(avg_psize)) horizontal ///
		  title("Superficie/Número de explotaciones") name(avg_psize_banano, replace)

* Canton bar charts
* Prepare the data (banano)
preserve
drop if prov_dummy == 1
keep if producto == "banano"
gsort - avg_psize
gen avg_psize_counter = _n
gen top_25_avg_psize = 1 if avg_psize_counter <= 25
* Do the plot
graph bar avg_psize if top_25_avg_psize == 1, ///
		  over(canton_num, sort(avg_psize)) horizontal ///
		  title("Superficie/Número de explotaciones") name(avg_psize_banano, replace)
restore




		  

 
}
di "End of BANANA AND PLATANO DATA section"





********************* USO DE TIERRA DATA **************************************
{
//* Tabla 2: Número estimado de explotaciones y superficies por uso de tierra
//import excel using "data\raw\censo_1954\censo_1954.xlsx", ///
//	   sheet("tabla 2") first clear
 

}
di "End of USO DE TIERRA section"
