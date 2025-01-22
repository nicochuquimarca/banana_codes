////////////////////////////////////////////////////////////////////////////////
//////////	 			          BANANA PAPERS 				      //////////
////////// 				GENERATE ANALYTIC DATABASE  	              //////////
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

********************* MERGE BANANO AND ROADS DATA **************************************
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

* Label some variables
label var produccion "Production: Thousand of banana bunches"
label var sup_sembrada "Sowed Area: Thousand of hectares"

* Get rid of the province level data
drop if prov_dummy == 1
 
* Get the length km data *
cap frame drop roads     // Drop prior frames
frame create roads     // Create a frame
frame change  roads     // Set the frame
* Open the roads data
import excel using "data\raw\roads_1947\roads_by_canton_1947.xlsx", ///
	   sheet("roads_1947_final") first clear
rename provincia_c provincia
rename canton_c canton
rename length_km roads_km
* Save as a temp file to do the merge 
tempfile roads_table
save `roads_table'
* Go the main frame and do the merge
frame change default
merge 1:1 provincia canton using `roads_table'
* replace the missing values with 0
replace roads_km = 0 if _merge == 1 
* Transform some variables to logs
gen l_produccion = log(produccion)
gen l_roads_km   = log(roads_km)

* Label some variables
label var roads_km "Year Round Roads in 1947 (km)"
label var l_produccion "Log(Production: Thousand of banana bunches)"
label var l_roads_km "Log(Kilometers of Available Year Round Roads)"

* Generate the top-25 cantons for n_explotaciones, sup_sembrada, sup_cosechada
* and produccion
* PENDING JOB: MAKE THIS IN A FOR-LOOP
* n_explotaciones 
gsort - n_explotaciones
gen n_explo_counter = _n
gen top_25_c_nexplo = 1 if n_explo_counter <= 25
* sup_sembrada 
gsort - sup_sembrada
gen sup_sembrada_counter = _n
gen top_25_sup_sembrada = 1 if sup_sembrada_counter <= 25
* sup_cosechada
gsort - sup_cosechada
gen sup_cosechada_counter = _n
gen top_25_sup_cosechada = 1 if sup_cosechada_counter <= 25
* produccion
gsort - produccion
gen produccion_counter = _n
gen top_25_produccion = 1 if produccion_counter <= 25



}
di "End of MERGE BANANO AND ROADS DATA"

********************* GEN OTHER VARIABLES **************************************
{
* Create variable
gen region = (inlist(provincia,"El Oro","Esmeraldas","Guayas","Los Rios","Manabi")) 
gen port = (inlist(canton,"Esmeraldas_c","Guayaquil","Machala"))
gen c_to_port = port
replace c_to_port = 1 if inlist(canton,"Eloy Alfaro","Sucre","Chone", ///
										"Daule","Baba","Babahoyo","Balzar")
replace c_to_port = 1 if inlist(canton,"Salinas","Santa Elena","Pasaje", ///
										 "Santa Rosa")
label var c_to_port "Connection to port [=1]"
* Label values
label define region_labs 0 "Sierra" 1 "Costa"
label values region region_labs
}
di "End of GEN OTHER VARIABLES"



********************* SAVE THE ANALYTIC DATABASE **************************************
{
save "data\final\banana_data.dta", replace
}
di "End of SAVE THE ANALYTIC DATABASE"