////////////////////////////////////////////////////////////////////////////////
//////////	 			          BANANA PAPERS 				      //////////
////////// 				1954 AGRICULTURAL CENSUS DATA  	              //////////
////////////////////////////////////////////////////////////////////////////////


***************************** SET STATA ****************************************
{
	clear all
	set more off 
	set maxvar 50000
	set scheme s2mono
	set seed 1234
	* Working folder path
	cd "C:\Users\nicoc\Dropbox\Pre_OneDrive_USFQ\PCNICOLAS_HP_PAVILION\Masters\USFQ\USFQ_EconReview\Author"
	global texout "C:\Users\nicoc\Dropbox\Apps\Overleaf\BananaPapers\figures"
}
di "End of SET STATA section!"

********************* BANANO AND PLATANO DATA **************************************
{
* Tabla 14: Número estimado de explotaciones, superficies y producción
import excel using "data\raw\censo_1954\censo_1954.xlsx", ///
	   sheet("tabla 14") first clear
* Remove aggregated values.
drop if provincia == "Ecuador" // Drop the national aggregation value
drop if producto  == "platano" // Drop platano (verde)
* Get a province identifier (handle Canar and Loja special cases)
gen counter = _n
gen prov_dummy = 1 if provincia == canton
replace prov_dummy = . if provincia == "Loja" & n_explotaciones == 1992 // Loja canton
replace prov_dummy = . if provincia == "Canar" & n_explotaciones == 343 // Canar canton
replace prov_dummy = 0 if prov_dummy == .

* Transform strings to integers
encode provincia, gen(provincia_num) label("provincia_labels")
encode canton, gen(canton_num) label("canton_labels")


**** Número de Explotaciones **** 
* Province bar charts
graph bar n_explotaciones if prov_dummy == 1, ///
		  over(provincia_num, sort(n_explotaciones)) horizontal ///
		  title("Número de explotaciones bananeras") name(num_explo_banano)
//graph export "results\figures\n_explotaciones_prov.png", as(png) replace
//graph export "$texout\n_explotaciones_prov.png", as(png) replace
		  
* Canton bar charts
* Prepare the data (banano)
preserve
drop if prov_dummy == 1
gsort - n_explotaciones
gen n_explo_counter = _n
gen top_25_c_nexplo = 1 if n_explo_counter <= 25
* Do the plot
graph bar n_explotaciones if top_25_c_nexplo == 1, ///
		  over(canton_num, sort(n_explotaciones)) horizontal ///
		  title("Número de explotaciones bananeras") name(num_explo_banano_c)
//graph export "results\figures\n_explotaciones_cant.png", as(png) replace
//graph export "$texout\n_explotaciones_cant.png", as(png) replace
restore

		  
**** Superficie sembrada **** 
* Province bar charts
graph bar sup_sembrada if prov_dummy == 1, ///
		  over(provincia_num, sort(sup_sembrada)) horizontal ///
		  title("Superficie sembrada Banano") name(sup_banano, replace)
//graph export "results\figures\sup_sembrada_prov.png", as(png) replace
//graph export "$texout\sup_sembrada_prov.png", as(png) replace

		  
* Canton bar charts
* Prepare the data (banano)
preserve
drop if prov_dummy == 1
gsort - sup_sembrada
gen sup_sembrada_counter = _n
gen top_25_sup_sembrada = 1 if sup_sembrada_counter <= 25
* Do the plot
graph bar sup_sembrada if top_25_sup_sembrada == 1, ///
		  over(canton_num, sort(sup_sembrada)) horizontal ///
		  title("Superficie sembrada banano") name(sup_banano_c)
//graph export "results\figures\sup_sembrada_cant.png", as(png) replace
//graph export "$texout\sup_sembrada_cant.png", as(png) replace
restore

*** Mean sowed plot size (only for banano)
/*
Pseudo Code: 
	1. Divide sup_sembrada by n_explotaciones to get the average plot size
		1.1. This is a measure of the places were economies of scale were 
			 possible on the production side
*/
* 1. sup_sembrada / n_explotaciones
gen avg_sewed_psize = sup_sembrada / n_explotaciones

* Province bar charts
graph bar avg_sewed_psize if prov_dummy == 1, ///
		  over(provincia_num, sort(avg_sewed_psize)) horizontal ///
		  title("Superficie/Número de explotaciones") ///
		  name(avg_sewed_psize_banano, replace)
//graph export "results\figures\avg_sewed_psize_prov.png", as(png) replace
//graph export "$texout\avg_sewed_psize_prov.png", as(png) replace


* Canton bar charts
* Prepare the data (banano)
preserve
drop if prov_dummy == 1
gsort - avg_sewed_psize
gen avg_sewed_psize_counter = _n
gen top_25_avg_sewed_psize = 1 if avg_sewed_psize_counter <= 25
* Do the plot
graph bar avg_sewed_psize if top_25_avg_sewed_psize == 1, ///
		  over(canton_num, sort(avg_sewed_psize)) horizontal ///
		  title("Superficie/Número de explotaciones") ///
		  name(avg_sewed_psize_banano, replace)
//graph export "results\figures\avg_sewed_psize_cant.png", as(png) replace
//graph export "$texout\avg_sewed_psize_cant.png", as(png) replace
restore


**** Superficie cosechada (banano only) **** 
* Province bar charts
graph bar sup_cosechada if prov_dummy == 1, ///
		  over(provincia_num, sort(sup_cosechada)) horizontal ///
		  title("Superficie cosechada Banano") name(sup_banano_cos, replace)
//graph export "results\figures\sup_cosechada_prov.png", as(png) replace
//graph export "$texout\sup_cosechada_prov.png", as(png) replace

		  
* Canton bar charts
* Prepare the data (banano)
preserve
drop if prov_dummy == 1
gsort - sup_cosechada
gen sup_cosechada_counter = _n
gen top_25_sup_cosechada = 1 if sup_cosechada_counter <= 25
* Do the plot
graph bar sup_cosechada if top_25_sup_cosechada == 1, ///
		  over(canton_num, sort(sup_cosechada)) horizontal ///
		  title("Superficie cosechada banano") name(sup_banano_cos_c)
//graph export "results\figures\sup_cosechada_cant.png", as(png) replace
//graph export "$texout\sup_cosechada_cant.png", as(png) replace
restore



*** Mean harvested plot size (only for banano)
/*
Pseudo Code: 
	1. Divide sup_cosechada by n_explotaciones to get the average plot size
		1.1. This is a measure of the places were economies of scale were 
			 possible on the production side
*/
* 1. sup_sembrada / n_explotaciones
gen avg_harvested_psize = sup_cosechada / n_explotaciones

* Province bar charts
graph bar avg_harvested_psize if prov_dummy == 1, ///
		  over(provincia_num, sort(avg_harvested_psize)) horizontal ///
		  title("Superficie/Número de explotaciones") ///
		  name(avg_harvested_psize_banano, replace)
//graph export "results\figures\avg_harvested_psize_prov.png", as(png) replace
//graph export "$texout\avg_harvested_psize_prov.png", as(png) replace


* Canton bar charts
* Prepare the data (banano)
preserve
drop if prov_dummy == 1
gsort - avg_harvested_psize
gen avg_harvested_psize_counter = _n
gen top_25_avg_harvested_psize = 1 if avg_harvested_psize_counter <= 25
* Do the plot
graph bar avg_harvested_psize if top_25_avg_harvested_psize == 1, ///
		  over(canton_num, sort(avg_harvested_psize)) horizontal ///
		  title("Superficie/Número de explotaciones") ///
		  name(avg_harvested_psize_banano_c, replace)
//graph export "results\figures\avg_harvested_psize_cant.png", as(png) replace
//graph export "$texout\avg_harvested_psize_cant.png", as(png) replace

restore


*** Production (banano only)
* Province bar charts
graph bar produccion if prov_dummy == 1, ///
		  over(provincia_num, sort(produccion)) horizontal ///
		  title("Produccion Banano") name(production_banano, replace)
//graph export "results\figures\production_prov.png", as(png) replace
//graph export "$texout\production_prov.png", as(png) replace

* Canton bar charts
* Prepare the data (banano)
preserve
drop if prov_dummy == 1
gsort - produccion
gen produccion_counter = _n
gen top_25_produccion = 1 if produccion_counter <= 25
* Do the plot
graph bar produccion if top_25_produccion == 1, 			///
		  over(canton_num, sort(produccion)) horizontal 	///
		  title("Produccion banano") name(production_banano_c)
//graph export "results\figures\production_cant.png", as(png) replace
//graph export "$texout\production_cant.png", as(png) replace
restore


*** Production by harvested area
/*
Pseudo Code: 
	1. Divide produccion by sup_cosechada to get how many units are produce by each
	   ha of harvested area
		1.1. This is a measure of the places were economies of scale were 
			 possible on the production side
*/
* 1. sup_sembrada / n_explotaciones
gen prod_by_hha = produccion / sup_cosechada

* Province bar charts
graph bar prod_by_hha if prov_dummy == 1, ///
		  over(provincia_num, sort(prod_by_hha)) horizontal ///
		  title("Produccion/Sup cosechada Banano") ///
		  name(prod_by_hha_banano, replace)
//graph export "results\figures\prod_by_hha_prov.png", as(png) replace
//graph export "$texout\prod_by_hha_prov.png", as(png) replace


* Canton bar charts
* Prepare the data (banano)
preserve
drop if prov_dummy == 1
gsort - prod_by_hha
gen prod_by_hha_counter = _n
gen top_25_prod_by_hha = 1 if prod_by_hha_counter <= 25
* Do the plot
graph bar prod_by_hha if top_25_prod_by_hha == 1, 		 ///
		  over(canton_num, sort(prod_by_hha)) horizontal ///
		  title("Produccion/Sup cosechada Banano")       ///
		  name(prod_by_hha_banano_c, replace)
//graph export "results\figures\prod_by_hha_cant.png", as(png) replace
//graph export "$texout\prod_by_hha_cant.png", as(png) replace
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
