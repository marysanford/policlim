
********************************************************************************
****************  	  Merge Manifesto and CAPMF-PPEG data 	    ****************
********************************************************************************

/*

This code joins together:

- Data on salience of the climate change issues for political parties across Europe, elaborated based on Quasi-Sentences (QS) from the Manifesto project and the use of a Large Language Model (LLM). The information is available as an aggregate measure, based on the salience of climate change in the Party manifesto released ahead of each national election.

- Data on climate policy stringency at the country level (yearly) from the OECD's Climate Actions and Policies Measurement Framework (CAPMF), already merged to data on elected governments and parliaments from WZB's Political Parties, Presidents, Elections and Governments database. The merged dataset is yearly, available for EU countries and with columns that, for each year, provide information on the most recent election year and month.

*/

* Set wd
cd "C:\Users\giorg\OneDrive\Documenti\RA Silvia Pianta\Political Parties Climate Discourse"



**# Manifesto data

* Import
import delimited "Dati\manifesto_level_en_trained_15May.csv", clear 
* br

* Prepare for the merge
tostring date, gen(date_str)
gen eyear = substr(date_str, 1, 4), after(date_str)
destring eyear, replace
gen emonth = substr(date_str, 5, 6), after(eyear)
destring emonth, replace
rename party cmp

* Save
save "Dati\manifesto_level_en_trained_15May.dta", replace



**# Merge Manifesto and CAPMF-PPEG data

* Import CAPMF-PPEG data
use "merged_ppeg_capmf", clear

* Prepare for the merge
gen emonth = month(edate), after(eyear)
destring cmp, replace
order cmp eyear emonth, after(country)

* Merge
merge m:1 cmp eyear emonth using "Dati\manifesto_level_en_trained_15May.dta"



**# Check the merge

* br if _merge == 1

* Check electoral share of merged parties (those with data on their manifestos)
* vs electoral share of not merged parties
bysort _merge: sum v_share_wgt, d

* Check seat share of merged parties (those with data on their manifestos)
* vs electoral share of not merged parties
bysort _merge: sum gov_seat, d

* Check government participation of merged parties parties
bysort _merge: sum gov_party



**# Preliminary regressions A
** (panel by country and government inauguration date, each unit is a government)

* Keep only parties in government or supporting parties
keep if gov_party == 2 | support_party == 2  
drop if _merge == 1 | _merge == 2

* Collapse at the government level 
collapse (mean) sec_pol_count sec_pol_string cross_sec_ffpp_pol_count cross_sec_ffpp_pol_string cross_sec_rdd_pol_count cross_sec_rdd_pol_string d_* pc_* v4 v5 label_strict_15may label_broad_15may, by(iso3c country_name idate iyear gov_duration)

* Assign panel format
encode iso3c, gen(country_num) // Generate numeric country variable
xtset country_num idate, daily


** SECTORAL POLICIES

* Absolute change in policy stringency
// RE
xtreg d_sec_pol_string label_broad_15may, re vce(cl country_num)
// FE
xtreg d_sec_pol_string label_broad_15may, fe vce(cl country_num)

* Percentage change in policy stringency
// RE
xtreg pc_sec_pol_string label_broad_15may, re vce(cl country_num)
// FE
xtreg pc_sec_pol_string label_broad_15may, fe vce(cl country_num)

* Absolute change in the number of policies
// RE
xtreg d_sec_pol_count label_broad_15may, re vce(cl country_num)
// FE
xtreg d_sec_pol_count label_broad_15may, fe vce(cl country_num)

* Percentage change in the number of policies
// RE
xtreg pc_sec_pol_count label_broad_15may, re vce(cl country_num)
// FE
xtreg pc_sec_pol_count label_broad_15may, fe vce(cl country_num)



**# Preliminary regressions B
** (Panel by country and year, each row is a government coalition for that year)

* ...










