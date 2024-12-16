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
}
di "End of SET STATA section!"

********************* BANANO AND PLATANO DATA **************************************
{
* Tabla 14: Número estimado de explotaciones, superficies y producción
import excel using "data\raw\censo_1954\censo_1954.xlsx", ///
	   sheet("tabla 14") first clear
* Remove aggregated values.
drop if provincia == "Ecuador" // Drop 
 

}
di "End of BANANA AND PLATANO DATA section"



********************* USO DE TIERRA DATA **************************************
{
* Tabla 2: Número estimado de explotaciones y superficies por uso de tierra
import excel using "data\raw\censo_1954\censo_1954.xlsx", ///
	   sheet("tabla 2") first clear
 

}
di "End of USO DE TIERRA section"
