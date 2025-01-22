////////////////////////////////////////////////////////////////////////////////
//////////	 			          BANANA PAPERS 				      //////////
////////// 		       DESCRIPTIVE AND CORRELATION ANALYSIS  	      //////////
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
	global figout "C:\Users\nicoc\Dropbox\Apps\Overleaf\BananaPapers\figures"
	global texout "C:\Users\nicoc\Dropbox\Apps\Overleaf\BananaPapers\tables"
}
di "End of SET STATA section!"

***************************** OPEN THE DATA ************************************
{
use "data\final\banana_data.dta", clear
}
di "End of OPEN THE DATA"

***************************** DESCRIPTIVE ANALYSIS *****************************
{
*** Roads summary statistics
tab region, gen(reg_)
gen roads_km_sierra = roads_km * reg_1
gen roads_km_costa  = roads_km * reg_2
replace roads_km_sierra = . if reg_1 == 0
replace roads_km_costa = . if reg_2 == 0
* Build the table manually in overleaf
* Pending Job: Automate this part (it is easy, it just takes time to remmember
* 			   the commands)
sum roads_km
sum roads_km_sierra
sum roads_km_costa, d
sum c_to_port if region == 1


*** Census summary stats 

* Pending Job: Automate this part (it is easy, it just takes time to remmember
* 			   the commands)
summ sup_sembrada sup_cosechada n_explotaciones produccion if region == 0



summ sup_sembrada if region == 0, d
summ sup_cosechada if region == 0, d
summ n_explotaciones if region == 0, d
summ produccion if region ==0 , d


* Plots
* Number of plantations
graph bar n_explotaciones if top_25_c_nexplo == 1, ///
		  over(canton_num, sort(n_explotaciones)) horizontal bargap(2) ///
		  blabel(bar, size(small) format(%10.0fc)) name(num_explo_c, replace) ///
		  ytitle("Number of Banana Plantations") ylabel(0(1000)4000)
graph export "results\figures\n_explotaciones_cant.png", as(png) replace
graph export "$figout\n_explotaciones_cant.png", as(png) replace
* Sowed Area
graph bar sup_sembrada if top_25_sup_sembrada == 1, ///
		  over(canton_num, sort(sup_sembrada)) horizontal bargap(2) ///
		  blabel(bar, size(small)) name(sup_sembrada_c, replace) ///
		  ytitle("Sowed Area, Thousand of hectares") ylabel(0(2)28)
graph export "results\figures\sup_sembrada_cant.png", as(png) replace
graph export "$figout\sup_sembrada_cant.png", as(png) replace
* Harvested Area
graph bar sup_cosechada if top_25_sup_cosechada == 1, ///
		  over(canton_num, sort(sup_cosechada)) horizontal bargap(2) ///
		  blabel(bar, size(small)) name(sup_cosechada_c, replace) ///
		  ytitle("Harvested Area, Thousand of hectares") ylabel(0(2)20)
graph export "results\figures\sup_cosechada_cant.png", as(png) replace
graph export "$figout\sup_cosechada_cant.png", as(png) replace
* Production
graph bar produccion if top_25_produccion == 1, ///
		  over(canton_num, sort(produccion)) horizontal bargap(2) ///
		  blabel(bar, size(small) format(%10.0fc)) name(produccion_c, replace) ///
		  ytitle("Production, Thousand of Bunches")  ///
		  ylabel(0(1000)8000)
graph export "results\figures\production_cant.png", as(png) replace
graph export "$figout\production_cant.png", as(png) replace
}
di "End of DESCRIPTIVE ANALYSIS"


***************************** CORRELATION ANALYSIS *****************************
{
* Controls
global covs c_to_port

* Correlation analysis
qui eststo sup_sem: reg sup_sembrada    roads_km $covs if region == 1, r
qui eststo sup_cos: reg sup_cosechada   roads_km $covs if region == 1, r
qui eststo n_explo: reg n_explotaciones roads_km $covs if region == 1, r
qui eststo producc: reg produccion      roads_km $covs if region == 1, r
esttab sup_sem
* Export the table
esttab sup_sem sup_cos n_explo producc 			    /// Call the models
    using "$texout\roads_vs_prod_corrs.tex", /// Declare tex files
	label b(%10.3fc) se(%10.3fc) 	/// Coef, sd and obs formats
	star(* 0.10 ** 0.05 *** 0.01)   /// Stars
	nomtitles nonumbers style(tex)  /// No titles & numbers, style = tex
	fragment booktabs not nolines   /// No titles & numbers, style = tex
	prehead(\\) compress noobs      /// Pre-head, compact tab, no obs
	plain parentheses width(\hsize) /// Plain format, parentheses (se) and able width
	collabels(,none) eqlabel(,none) nolines replace // No col & eq labels, replace file


* Plots
twoway scatter produccion roads_km if region == 1, ///
 title("Year Round Available Roads in 1947 vs Banana Output in 1954 by Canton",size(medium)) ///
 subtitle("Sample: All Cantons in the Costa Region", size(medium)) /// 
 ylabel(0(1000)8000, angle(h) format(%10.0fc)) xlabel(0(25)150) ///
 msize(small) mlabel(canton) mlabsize(vsmall) name(all_cantons, replace) 
graph export "results\figures\roads_vs_prod_costa_all.png", as(png) replace
graph export "$figout\roads_vs_prod_costa_all.png", as(png) replace
* Logs plots
twoway scatter l_produccion l_roads_km if region == 1 & produccion>0 & roads_km>0, ///
 title("Year Round Available Roads in 1947 vs Banana Output in 1954 by Canton",size(medium)) ///
 subtitle("Sample: Log(Output>0) and Log(Roads>0) in the Costa Region", size(medium)) ///
 ylabel(0(1)9, angle(h) format(%10.0fc)) xlabel(0(1)6) ///
 msize(small) mlabel(canton) mlabsize(vsmall) name(l_red_cantons, replace)
graph export "results\figures\l_roads_vs_l_prod_costa_red.png", as(png) replace
graph export "$figout\l_roads_vs_l_prod_costa_red.png", as(png) replace



* Check later *
********************************************************************************
* Level plots
twoway scatter produccion roads_km if produccion > 0 & produccion < 2000 & ///
									  roads_km>0 & roads_km < 110 & region == 1, ///
 title("Year Round Available Roads in 1947 vs Banana Output in 1954 by Canton",size(medium)) ///
 subtitle("Sample: (0<Output<2000) and (0<Roads km<110) in the Costa Region", size(medium)) ///
 ylabel(0(250)2000, angle(h) format(%10.0fc)) xlabel(0(20)100) ///
 msize(small) mlabel(canton) mlabsize(vsmall) name(red_cantons, replace) 
graph export "results\figures\roads_vs_prod_costa_red.png", as(png) replace
* Logs plots
twoway scatter l_produccion l_roads_km if region == 1 & produccion>0 & roads_km>0, ///
 title("Year Round Available Roads in 1947 vs Banana Output in 1954 by Canton",size(medium)) ///
 subtitle("Sample: Log(Output>0) and Log(Roads>0) in the Costa Region", size(medium)) ///
 ylabel(0(1)9, angle(h) format(%10.0fc)) xlabel(0(1)6) ///
 msize(small) mlabel(canton) mlabsize(vsmall) name(l_red_cantons, replace)
 graph export "results\figures\l_roads_vs_l_prod_costa_red.png", as(png) replace
* Check later *
}
di "End of DESCRIPTIVE ANALYSIS"