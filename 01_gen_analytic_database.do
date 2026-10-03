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

*************** MERGE BANANO, CACAO, ROADS AND WATER DATA *********************
{

	**** Banana Data
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
	replace prov_dummy = . if provincia == "Loja" & ///
			n_explotaciones == 1992 // Loja canton
	replace prov_dummy = . if provincia == "Canar" & ///
			n_explotaciones == 343 // Canar canton
	replace prov_dummy = 0 if prov_dummy == .
	* Transform strings to integers
	encode provincia, gen(provincia_num) label("provincia_labels")
	encode canton, gen(canton_num) label("canton_labels")
	* Label some variables
	label var produccion "Production: Thousand of banana bunches"
	label var sup_sembrada "Sowed Area: Thousand of hectares"
	* Get rid of the province level data
	drop if prov_dummy == 1
	}
	***** End of Banana Data

	**** Cacao Data
	{
	* Create a frame to work
	cap frame drop cacao_frame // Drop prior frames
	frame create cacao_frame   // Create a frame
	frame change cacao_frame   // Set the frame
	* Tabla 16: CACAO Y CAFÉ. Explotaciones, árboles y producción
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
	* Drop repeated variables and prepare for the merge
	drop producto counter prov_dummy
	* Save as a temp file to do the merge 
	tempfile cacao_table
	save `cacao_table'
	* Go the main frame and do the merge
	frame change default
	merge 1:1 provincia canton using `cacao_table'
	* drop the _merge variable to avoid errors
	drop _merge
	}
	**** End of Cacao Data
	
	**** Roads Data
	{
	* Work in a separate frame
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
	drop _merge
	* Transform some variables to logs
	gen l_produccion = log(produccion)
	gen l_n_explotaciones = log(n_explotaciones)
	gen l_sup_sembrada = log(sup_sembrada)
	gen l_sup_cosechada = log(sup_cosechada)
	gen l_roads_km   = log(roads_km)
	}
	**** End of Roads Data
	
	**** Distance to water Data
	{
	* Work in a different frame
	cap frame drop water_data // Drop prior frames that may share the name
	frame create water_data // Create a frame
	frame change water_data //
	import delimited using 	"data\raw\aid_data\csv_files\canton_level_distance_to_water_and_precipitation.csv", clear
	* Keep certain variables
	keep asdf_id  udel_precip_v501_mean1954mean  udel_precip_v501_mean1954min udel_precip_v501_mean1954max dist_to_waternonemean dist_to_waternonemax dist_to_waternonemin level gqid id shapegroup shapeid shapename shapetype
	* Get the canton and provinces names from a custom built dictionary
	cap frame drop canton_dictionary   // Drop prior frames
	frame create canton_dictionary      // Create a frame
	frame change canton_dictionary     // Set the frame
	import excel using "data\raw\aid_data\csv_files\banana_aid_dictionary.xlsx", ///
		   sheet("aid_censo_dictionary") first clear
	rename provincia_1954 provincia
	rename canton_1954 canton
	rename Comentario comentario
	keep shapeid shapename provincia canton comentario // Keep variables of interest
	* Save as a temp file to do the merge 
	tempfile dictionary
	save `dictionary'
	* Go the main frame and do the merge
	frame change water_data
	merge 1:1 shapeid shapename using `dictionary'
	* Drop the temp frame
	frame drop canton_dictionary
	* Drop Galapagos and Amazon data (not included in the 54 census)
	drop if comentario == "Galapagos y la amazonia no forman parte del censo 1954"
	drop comentario _merge
	* Convert some variables from strings to numeric variables before aggregation
	destring udel_precip_v501_mean1954max,  replace
	destring udel_precip_v501_mean1954mean, replace
	destring udel_precip_v501_mean1954min,  replace
	* Aggregate the data for cantons that splitted after the 1950s
	gen key = provincia + "-" + canton
	sort key
	by key: egen dist_to_waternonemean_agg = mean(dist_to_waternonemean)
	by key: egen dist_to_waternonemax_agg  = max(dist_to_waternonemax) 
	by key: egen dist_to_waternonemin_agg  = min(dist_to_waternonemin)
	by key: egen rain_1954mean_agg 		   = mean(udel_precip_v501_mean1954mean) 
	by key: egen rain_1954max_agg 		   = max(udel_precip_v501_mean1954max)
	by key: egen rain_1954min_agg 		   = min(udel_precip_v501_mean1954min)
	* Collapse to delete duplicates and prepare for merge with the census data
	collapse (mean) dist_to_waternonemean_agg dist_to_waternonemax_agg dist_to_waternonemin_agg rain_1954mean_agg rain_1954max_agg rain_1954min_agg, by(provincia canton)
	* Save as a temp file to do the merge 
	tempfile water_table
	save `water_table'
	* Go the main frame and do the merge
	frame change default
	merge 1:1 provincia canton using `water_table'
	drop _merge
	* Rename water variables
	rename dist_to_waternonemean_agg water_dist_mean
	rename dist_to_waternonemin_agg water_dist_min
	rename dist_to_waternonemax_agg water_dist_max
	rename rain_1954mean_agg rain_mean
	rename rain_1954max_agg rain_max
	rename rain_1954min_agg rain_min
	* Rescale distance to water from mts to km
	replace water_dist_mean = water_dist_mean/1000
	replace water_dist_min = water_dist_min/1000
	replace water_dist_max = water_dist_max/1000
	* Transform some variables to logs
	gen l_water_dist_mean = log(water_dist_mean)
	}
	**** End of Distance to water Data
	
	**** General Data Cleaning
	{
	* Drop the previous frames
	frame drop cacao_frame // Drop the cacao frame
	frame drop roads       // Drop the road frame
	frame drop water_data  // Drop the water frame
	* Label some variables
	label var roads_km "Year Round Roads in 1947 (km)"
	label var l_produccion "Log(Production: Thousand of banana bunches)"
	label var l_roads_km "Log(Year Round Roads in 1947 (km))"
	label var l_water_dist_mean "Log(Mean distance to river or lake (km))"
	label var water_dist_mean "Mean distance to river or lake (km)"
	label var rain_mean "Mean monthly precipitation in 1954 (mm)"
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
	**** End of General Data Cleaning

}
di "End of MERGE BANANO, CACAO, ROADS AND WATER DATA"

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