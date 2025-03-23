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

	**** SUMMARY STATS TABLES IN MANUSCRIPT (MANUAL)
	{
	* The tables were build manually in the overleaf document
	* Pending Job: Automate it (easy but takes a bit of time)
	*** Roads summary statistics
	tab region, gen(reg_)
	gen roads_km_sierra = roads_km * reg_1
	gen roads_km_costa  = roads_km * reg_2
	replace roads_km_sierra = . if reg_1 == 0
	replace roads_km_costa = . if reg_2 == 0
	sum roads_km
	sum roads_km_sierra
	sum roads_km_costa, d
	sum c_to_port if region == 1
	
	*** Census summary stats 
	summ sup_sembrada sup_cosechada n_explotaciones produccion if region == 0
	summ sup_sembrada if region == 0, d
	summ sup_cosechada if region == 0, d
	summ n_explotaciones if region == 0, d
	summ produccion if region ==0 , d
	
	*** Rivers and rain summ stats
	sum water_dist_mean, d
	sum water_dist_mean if region == 0, d // Sierra
	sum rain_mean, d
	}
	**** SUMMARY STATS TABLES IN MANUSCRIPT (MANUAL)
	
	**** PLOTS - BANANA OUTCOMES RANKING
	{
	* Number of plantations
	graph bar n_explotaciones if top_25_c_nexplo == 1, ///
			  over(canton_num, sort(n_explotaciones)) horizontal bargap(2) ///
			  blabel(bar, size(small) format(%10.0fc)) name(num_explo_c, replace) ///
			  ytitle("Number of Banana Plantations") ylabel(0(1000)4000)
	//graph export "results\figures\n_explotaciones_cant.png", as(png) replace
	//graph export "$figout\n_explotaciones_cant.png", as(png) replace
	* Sowed Area
	graph bar sup_sembrada if top_25_sup_sembrada == 1, ///
			  over(canton_num, sort(sup_sembrada)) horizontal bargap(2) ///
			  blabel(bar, size(small)) name(sup_sembrada_c, replace) ///
			  ytitle("Sowed Area, Thousand of hectares") ylabel(0(2)28)
	//graph export "results\figures\sup_sembrada_cant.png", as(png) replace
	//graph export "$figout\sup_sembrada_cant.png", as(png) replace
	* Harvested Area
	graph bar sup_cosechada if top_25_sup_cosechada == 1, ///
			  over(canton_num, sort(sup_cosechada)) horizontal bargap(2) ///
			  blabel(bar, size(small)) name(sup_cosechada_c, replace) ///
			  ytitle("Harvested Area, Thousand of hectares") ylabel(0(2)20)
	//graph export "results\figures\sup_cosechada_cant.png", as(png) replace
	//graph export "$figout\sup_cosechada_cant.png", as(png) replace
	* Production
	graph bar produccion if top_25_produccion == 1, ///
			  over(canton_num, sort(produccion)) horizontal bargap(2) ///
			  blabel(bar, size(small) format(%10.0fc)) name(produccion_c, replace) ///
			  ytitle("Production, Thousand of Bunches")  ///
			  ylabel(0(1000)8000)
	//graph export "results\figures\production_cant.png", as(png) replace
	//graph export "$figout\production_cant.png", as(png) replace
	}
	**** PLOTS - BANANA OUTCOMES RANKING
}
di "End of DESCRIPTIVE ANALYSIS"


***************************** CORRELATION ANALYSIS *****************************
{
	***************************** TABLES ***************************************
	
	**** Table 3: Infraestructure, Distance to Rivers and Outcome Correlation
	{
	* Controls
	global covs c_to_port water_dist_mean rain_mean
	* Run the regs
	qui eststo sup_sem: reg sup_sembrada    roads_km $covs if region == 1, r
	qui eststo sup_cos: reg sup_cosechada   roads_km $covs if region == 1, r
	qui eststo n_explo: reg n_explotaciones roads_km $covs if region == 1, r
	qui eststo producc: reg produccion      roads_km $covs if region == 1, r
	* Export the table
	esttab sup_sem sup_cos n_explo producc  /// Call the models
		using "$texout\roads_vs_prod_corrs.tex", /// Declare tex files
		label b(%10.3fc) se(%10.3fc) 	/// Coef, sd and obs formats
		star(* 0.10 ** 0.05 *** 0.01)   /// Stars
		nomtitles nonumbers style(tex)  /// No titles & numbers, style = tex
		fragment booktabs not nolines   /// No titles & numbers, style = tex
		prehead(\\) compress noobs      /// Pre-head, compact tab, no obs
		plain parentheses width(\hsize) /// format, parentheses (se) and table width
		collabels(,none) eqlabel(,none) nolines replace // No col & eq labs, rep. file
	}
    **** Table 3: Infraestructure, Distance to Rivers and Outcome Correlation
	
	**** Table 4: Log Infrastructure, Distance to Rivers and Outcome Corr
	{
	* Controls
	global l_covs c_to_port l_water_dist_mean rain_mean
	* Run the regs
	qui eststo l_sup_sem: reg l_sup_sembrada    l_roads_km $l_covs if region == 1, r
	qui eststo l_sup_cos: reg l_sup_cosechada   l_roads_km $l_covs if region == 1, r
	qui eststo l_n_explo: reg l_n_explotaciones l_roads_km $l_covs if region == 1, r
	qui eststo l_producc: reg l_produccion      l_roads_km $l_covs if region == 1, r
	* Export the table
	esttab l_sup_sem l_sup_cos l_n_explo l_producc  /// Call the models
		using "$texout\l_roads_vs_prod_corrs.tex",  /// Declare tex files
		label b(%10.3fc) se(%10.3fc) 	/// Coef, sd and obs formats
		star(* 0.10 ** 0.05 *** 0.01)   /// Stars
		nomtitles nonumbers style(tex)  /// No titles & numbers, style = tex
		fragment booktabs not nolines   /// No titles & numbers, style = tex
		prehead(\\) compress noobs      /// Pre-head, compact tab, no obs
		plain parentheses width(\hsize) /// format, parentheses (se) and table width
		collabels(,none) eqlabel(,none) nolines replace // No col & eq labs, rep. file
	}
	**** Table 4: Log Infrastructure, Distance to Rivers and Outcome Corr
	
	**** Table 5: Cacao Infrastructure, Distance to Rivers and outcome vars
	{
	* Controls
	global ccovs roads_km c_to_port water_dist_mean rain_mean
	* Run the regs
	qui eststo cacao_tarboles: reg cacao_total_arboles   $ccovs if region == 1, r
	qui eststo cacao_parboles: reg cacao_arboles_prod    $ccovs if region == 1, r
	qui eststo cacao_nexplota: reg cacao_n_explotaciones $ccovs if region == 1, r
	qui eststo cacao_producci: reg cacao_produccion      $ccovs if region == 1, r
	* Export the table
	esttab cacao_tarboles cacao_parboles cacao_nexplota cacao_producci /// Models
		using "$texout\cacao_roads_vs_prod_corrs.tex",  /// Declare tex files
		label b(%10.3fc) se(%10.3fc) 	/// Coef, sd and obs formats
		star(* 0.10 ** 0.05 *** 0.01)   /// Stars
		nomtitles nonumbers style(tex)  /// No titles & numbers, style = tex
		fragment booktabs not nolines   /// No titles & numbers, style = tex
		prehead(\\) compress noobs      /// Pre-head, compact tab, no obs
		plain parentheses width(\hsize) /// format, parentheses (se) and table width
		collabels(,none) eqlabel(,none) nolines replace // No col & eq labs, rep. file
	}
	**** Table 5: Cacao Infrastructure, Distance to Rivers and outcome vars
	
    ***************************** FIGURES ***************************************

	*** Figure 1: Roads and Production Scatter Plots
	{
	* Prepare data for the plot
	global plot_covs c_to_port water_dist_mean rain_mean
	qui reg produccion $plot_covs if region == 1, r   
	cap drop road_res
	predict road_res, resid
	label var road_res "Residuals of Output: Thousand of Banana Bunches"
	qui reg road_res roads_km, r
	mat est_values = r(table)
	scalar ci95lb = est_values[5,1]
	scalar ci95up = est_values[6,1]
	* Do the plot
	twoway (lfit    road_res roads_km if region == 1, ///
			lcolor(red)) /// Fitted Values
		   (scatter road_res roads_km if region == 1, ///
		   	msymbol(circle) msize(small) mcolor(blue%40) ///
			mlabel(canton) mlabsize(small)), /// Scatter Plot
	title("Sample: All Cantons in the Costa Region", size(medium)) /// 
	ytitle("Residuals of Output: Thousand of Banana Bunches")        ///
	ylabel(-4000(1000)3000, angle(h) format(%10.0fc)) xlabel(0(25)150) ///
	legend(order(1 "Linear Fit" 2 "Residuals")) name(costa, replace) 
	graph export "results\figures\roads_vs_prod_costa_all.png", as(png) replace
	graph export "$figout\roads_vs_prod_costa_all.png", as(png) replace
	}
	*** Figure 1: Roads and Production Scatter Plots
	
	**** Figure 2: Log(Roads and Production Scatter Plots)
	{
	* Prepare data for the plot
	global plot_lcovs c_to_port l_water_dist_mean rain_mean
	qui reg l_produccion $plot_lcovs if region == 1, r   
	cap drop l_road_res
	predict l_road_res, resid
	label var l_road_res "Residuals of Log(Output): Log(Thousand of Banana Bunches)"
	qui reg l_road_res l_roads_km, r
	mat est_values = r(table)
	scalar ci95lb = est_values[5,1]
	scalar ci95up = est_values[6,1]
	* Do the plot
	twoway (lfit l_road_res l_roads_km if region == 1, ///
			lcolor(red)) /// Fitted Values
		   (scatter l_road_res l_roads_km if region == 1, ///
		   	msymbol(circle) msize(small) mcolor(blue%40) ///
			mlabel(canton) mlabsize(small)), /// Scatter Plot
	title("Sample: Log(Roads) and Log(Output) in the Costa Region", size(medium)) /// 
	ytitle("Residuals of Log(Output)") ///
	ylabel(-5(1)3, angle(h) format(%10.0fc)) xlabel(0(1)6) ///
	legend(order(1 "Linear Fit" 2 "Residuals")) name(l_red_cantons, replace)
	graph export "results\figures\l_roads_vs_l_prod_costa_red.png", as(png) replace
	graph export "$figout\l_roads_vs_l_prod_costa_red.png", as(png) replace
	}
	**** Figure 2: Log(Roads and Production Scatter Plots)
	
	**** Figure 3: Distance to Rivers and Plantations
	{
	* Prepare data for the plot
	global plot_covs c_to_port roads_km rain_mean
	qui reg n_explotaciones $plot_covs if region == 1, r   
	cap drop water_res
	predict water_res, resid
	label var water_res "Residuals of Plantations"
	* Do the plot
	twoway (lfit    water_res water_dist_mean if region == 1, ///
			lcolor(red)) /// Fitted Values
		   (scatter water_res water_dist_mean if region == 1, ///
		   	msymbol(circle) msize(small) mcolor(blue%40) ///
			mlabel(canton) mlabsize(small)), /// Scatter Plot
	title("Sample: All Cantons in the Costa Region", size(medium)) /// 
	ytitle("Residuals of Banana Plantations") ///
	ylabel(-1000(500)2000, angle(h) format(%10.0fc)) xlabel(0(20)120) ///
	legend(order(1 "Linear Fit" 2 "Residuals")) name(explotaciones_costa, replace)
	graph export "results\figures\water_vs_explotaciones_costa.png", as(png) replace
	graph export "$figout\water_vs_explotaciones_costa.png", as(png) replace
	}
	**** Figure 3: Distance to Rivers and Plantations	
	
	**** Figure 4: Log(Distance to Rivers and Plantations)
	{
	* Prepare data for the plot
	global plot_lcovs c_to_port l_roads_km rain_mean
	qui reg l_n_explotaciones $plot_lcovs if region == 1, r   
	cap drop l_water_res
	predict l_water_res, resid
	label var l_water_res "Residuals of Log(Plantations)"
	* Do the plot
	twoway (lfit    l_water_res l_water_dist_mean if region == 1, ///
			lcolor(red)) /// Fitted Values
		   (scatter l_water_res l_water_dist_mean if region == 1, ///
		   	msymbol(circle) msize(small) mcolor(blue%40) ///
			mlabel(canton) mlabsize(small)), /// Scatter Plot
	title("Sample: Log(Distance) and Log(Plantations) in the Costa Region", size(medium)) /// 
	ytitle("Residuals of Log(Banana Plantations)") ///
	ylabel(-2(0.5)2, angle(h) format(%10.0fc)) xlabel(1(1)5) ///
	legend(order(1 "Linear Fit" 2 "Residuals")) name(explotaciones_costa, replace)
	graph export "results\figures\l_water_vs_explotaciones_costa.png", as(png) replace
	graph export "$figout\l_water_vs_explotaciones_costa.png", as(png) replace
	}
	**** Figure 4: Log(Distance to Rivers and Plantations)
}
di "End of DESCRIPTIVE ANALYSIS"