* Set directory and import data set
clear all
set more off
cd "C:\Users\beras\OneDrive\Escritorio\Futbol\"
import excel "Data.xlsx", sheet("Output") firstrow

* 0. GENERATE VARIABLES AND FILTERS
* 0.1. GENERATE FILTERS
* 0.1.1. Filter for cut (potential selection, they may be less prone to respond to the treatment)
gen cut = 0
replace cut = 1 if (C2011 == "Cut" | C2012 == "Cut" | C2013 == "Cut" | C2014 == "Cut" | C2015 == "Cut" | C2016 == "Cut" | C2017 == "Cut" | C2018 == "Cut")
* 0.1.2. Filter for people that play since the lower cattegories while Natxo is in Athletic (new incorporations may be chosen due to their probability of responding to the stimulus and who knows which treatment was received by previous cohorts)
gen firstalevin = 0
replace firstalevin = 1 if Ageatfirst == 10

* 0.2. GENERATE VARIABLES
* 0.2.1. Generate first competitiveness variable (to measure potential selection in the treatment)
gen competifirst = C2018 if C2018 != "Not applicable"
replace competifirst = C2017 if C2017 != "Not applicable"
replace competifirst = C2016 if C2016 != "Not applicable"
replace competifirst = C2015 if C2015 != "Not applicable"
replace competifirst = C2014 if C2014 != "Not applicable"
replace competifirst = C2013 if C2013 != "Not applicable"
replace competifirst = C2012 if C2012 != "Not applicable"
replace competifirst = C2011 if C2011 != "Not applicable"
gen competifirstnum = real(competifirst)

* 0.2.2. Generate treated dummy variables with competitive and anticoompetitive training (to measure the quality and intensity of the treatment)
gen comptreatment = 0
replace comptreatment = 1 if (Yearstreatmentcomp1 != 0 | Yearstreatmentcomp2 != 0 | Yearstreatmentcomp3 != 0)

gen comptreatment11 = 0
replace comptreatment1 = 1 if Yearstreatmentcomp1 != 0
gen comptreatment2 = 0
replace comptreatment2 = 1 if Yearstreatmentcomp2 != 0
gen comptreatment3 = 0
replace comptreatment3 = 1 if Yearstreatmentcomp3 != 0

gen anticomptreatment = 0
replace anticomptreatment = 1 if (Yearstreatmentanticomp1 != 0)

* 0.2.1. Generate entry year
gen entryyear = 2018 if C2018 != "Not applicable"
replace entryyear = 2017 if C2017 != "Not applicable"
replace entryyear = 2016 if C2016 != "Not applicable"
replace entryyear = 2015 if C2015 != "Not applicable"
replace entryyear = 2014 if C2014 != "Not applicable"
replace entryyear = 2013 if C2013 != "Not applicable"
replace entryyear = 2012 if C2012 != "Not applicable"
replace entryyear = 2011 if C2011 != "Not applicable"

* 0.2.2. Generate year of birth
gen Yearbirth = entryyear - Ageatfirst

* 0.2.3. Replace proportion to not be in percentage terms
replace Prop1s = Prop1s / 100

* 0.2.4. Generate proportions without first year
gen Prop1se = ( Prop1s * OBSERVEd - competifirstnum ) / (OBSERVEd - 1)

* 1. TREATMENT RANDOMNESS ANALYSIS
* 1.1. Initial competitiveness, competitive treatment analysis: Correlation between tratment and first-year competition (Is the treatment equally distributed across the different players given their initial scores?)
preserve
drop if firstalevin == 0
reg competifirstnum comptreatment
reg competifirstnum comptreatment i.Yearbirth i.entryyear
probit competifirstnum comptreatment
probit competifirstnum comptreatment i.Yearbirth i.entryyear
restore

preserve
reg competifirstnum comptreatment
reg competifirstnum comptreatment i.Yearbirth i.entryyear
probit competifirstnum comptreatment
probit competifirstnum comptreatment i.Yearbirth i.entryyear
restore
* Comment: There exists a positive correlation between the treated units and their initial level of competitiveness.

* 1.1. Initial competitiveness, anticompetitive treatment analysis: Correlation between tratment and first-year competition (Is the treatment equally distributed across the different players given their initial scores?)
preserve
drop if firstalevin == 0
reg competifirstnum anticomptreatment
reg competifirstnum anticomptreatment i.Yearbirth i.entryyear
probit competifirstnum anticomptreatment
probit competifirstnum anticomptreatment i.Yearbirth i.entryyear
restore

preserve
reg competifirstnum anticomptreatment
reg competifirstnum anticomptreatment i.Yearbirth i.entryyear
probit competifirstnum anticomptreatment
probit competifirstnum anticomptreatment i.Yearbirth i.entryyear
restore
* Comment: Same as before

* 1.1. Initial competitiveness, competitive and anticompetitive treatments analysis: Correlation between tratments and first-year competition (Are the treatments equally distributed across the different players given their initial scores?)
preserve
drop if firstalevin == 0
reg competifirstnum comptreatment anticomptreatment
reg competifirstnum comptreatment anticomptreatment i.Yearbirth i.entryyear
probit competifirstnum comptreatment anticomptreatment
probit competifirstnum comptreatment anticomptreatment i.Yearbirth i.entryyear
restore

preserve
reg competifirstnum comptreatment anticomptreatment
reg competifirstnum comptreatment anticomptreatment i.Yearbirth i.entryyear
probit competifirstnum comptreatment anticomptreatment
probit competifirstnum comptreatment anticomptreatment i.Yearbirth i.entryyear
restore
* Comment: Same as before

* 2. SUMMARY OF STATISTICS
* Tables of Summary Statistics
preserve
drop if (LaLiga == "Not Yet" | LaLiga == "Not yet" | LaLiga == "?")
drop if (A == "Not Yet" | A == "Not yet" | A == "?")
drop if (ProContract18 == "Not Yet" | ProContract18 == "Not yet" | ProContract18 == "?")
destring LaLiga, replace
destring A, replace
destring ProContract18, replace
tabstat Yearbirth Ageatfirst Prop1s cut comptreatment anticomptreatment YearsinAcademy UnderSpain ProContract18 A LaLiga, stat(n mean sd min max p25 p75) col(stat)
tabstat Yearbirth Ageatfirst Prop1s cut comptreatment anticomptreatment YearsinAcademy UnderSpain ProContract18 A LaLiga, stat(n mean sd min max p25 p75) col(stat) by(Sample)
restore

* 3. PERSISTANCE IN COMPETITIVENESS
* Simple regression of proportion of competitive choices on first-year competitiveness
preserve
drop if OBSERVEd == 1
reg Prop1se competifirstnum i.Yearbirth i.entryyear
restore

preserve
drop if OBSERVEd == 1
drop if firstalevin == 0
reg Prop1se competifirstnum i.Yearbirth i.entryyear
restore
* Comment: First year is a good predictor

* 4. MAIN ANALYSIS: RELATIONSHIP BETWEEN COMPETITIVENESS AND FINAL OUTCOMES.
* 4.1. The relationship between competitiveness and success. 
* 4.1.1. The relationship between competitiveness and success.  All sample. Accumulated competitivenesss
preserve
drop if (LaLiga == "Not Yet" | LaLiga == "Not yet" | LaLiga == "?")
drop if (A == "Not Yet" | A == "Not yet" | A == "?")
drop if (ProContract18 == "Not Yet" | ProContract18 == "Not yet" | ProContract18 == "?")
destring LaLiga, replace
destring A, replace
destring ProContract18, replace
reg YearsinAcademy Prop1s competifirstnum
reg YearsinAcademy Prop1s competifirstnum i.entryyear i.Yearbirth i.Ageatfirst
probit UnderSpain Prop1s competifirstnum
probit UnderSpain Prop1s competifirstnum i.entryyear i.Yearbirth i.Ageatfirst
probit ProContract18 Prop1s competifirstnum 
probit ProContract18 Prop1s competifirstnum i.entryyear i.Yearbirth i.Ageatfirst
probit A Prop1s competifirstnum
probit A Prop1s competifirstnum i.entryyear i.Yearbirth i.Ageatfirst
probit LaLiga Prop1s competifirstnum
probit LaLiga Prop1s competifirstnum i.entryyear i.Yearbirth i.Ageatfirst
restore
* Comment: more competitive players are more likely to play more years in Athletic and Spain sub, to get a professional contract and to play in La Liga and 2a


* 4.1.2. The relationship between competitiveness and success. Excluding cut player.
preserve
drop if (LaLiga == "Not Yet" | LaLiga == "Not yet" | LaLiga == "?")
drop if (A == "Not Yet" | A == "Not yet" | A == "?")
drop if (ProContract18 == "Not Yet" | ProContract18 == "Not yet" | ProContract18 == "?")
destring LaLiga, replace
destring A, replace
destring ProContract18, replace
drop if cut == 1
probit UnderSpain Prop1s competifirstnum
probit UnderSpain Prop1s competifirstnum i.entryyear i.Yearbirth i.Ageatfirst
probit ProContract18 Prop1s competifirstnum 
probit ProContract18 Prop1s competifirstnum i.entryyear i.Yearbirth i.Ageatfirst
probit A Prop1s competifirstnum
probit A Prop1s competifirstnum i.entryyear i.Yearbirth i.Ageatfirst
probit LaLiga Prop1s competifirstnum
probit LaLiga Prop1s competifirstnum i.entryyear i.Yearbirth i.Ageatfirst
restore
* Comment: more competitive players are more likely to play more years in Athletic and Spain sub, to get a professional contract, but the relationship between competitiveness and getting to LaLiga and Segunda B is not significantly different from zero.


* 4.2. The relationship between treatment, competitiveness and success. 
* 4.2.1. The relationship between treatment, competitiveness and success.  All sample. Aggregate treatments
preserve
drop if (LaLiga == "Not Yet" | LaLiga == "Not yet" | LaLiga == "?")
drop if (A == "Not Yet" | A == "Not yet" | A == "?")
drop if (ProContract18 == "Not Yet" | ProContract18 == "Not yet" | ProContract18 == "?")
destring LaLiga, replace
destring A, replace
destring ProContract18, replace
reg YearsinAcademy comptreatment anticomptreatment Prop1s competifirstnum
reg YearsinAcademy comptreatment anticomptreatment Prop1s competifirstnum i.entryyear i.Yearbirth i.Ageatfirst
probit ProContract18 comptreatment anticomptreatment Prop1s competifirstnum
probit ProContract18 comptreatment anticomptreatment Prop1s competifirstnum i.entryyear i.Yearbirth i.Ageatfirst
probit UnderSpain comptreatment anticomptreatment Prop1s competifirstnum
probit UnderSpain comptreatment anticomptreatment Prop1s competifirstnum i.entryyear i.Yearbirth i.Ageatfirst
probit A comptreatment anticomptreatment Prop1s competifirstnum
probit A comptreatment anticomptreatment Prop1s competifirstnum i.entryyear i.Yearbirth i.Ageatfirst
probit LaLiga comptreatment anticomptreatment Prop1s competifirstnum
probit LaLiga comptreatment anticomptreatment Prop1s competifirstnum i.entryyear i.Yearbirth i.Ageatfirst
restore

* 4.2.2. The relationship between treatment, competitiveness and success.  All sample. Aggregate treatments
preserve
drop if (LaLiga == "Not Yet" | LaLiga == "Not yet" | LaLiga == "?")
drop if (A == "Not Yet" | A == "Not yet" | A == "?")
drop if (ProContract18 == "Not Yet" | ProContract18 == "Not yet" | ProContract18 == "?")
destring LaLiga, replace
destring A, replace
destring ProContract18, replace
drop if cut == 1
probit ProContract18 comptreatment anticomptreatment Prop1s competifirstnum
probit ProContract18 comptreatment anticomptreatment Prop1s competifirstnum i.entryyear i.Yearbirth i.Ageatfirst
probit UnderSpain comptreatment anticomptreatment Prop1s competifirstnum
probit UnderSpain comptreatment anticomptreatment Prop1s competifirstnum i.entryyear i.Yearbirth i.Ageatfirst
probit A comptreatment anticomptreatment Prop1s competifirstnum
probit A comptreatment anticomptreatment Prop1s competifirstnum i.entryyear i.Yearbirth i.Ageatfirst
probit LaLiga comptreatment anticomptreatment Prop1s competifirstnum
probit LaLiga comptreatment anticomptreatment Prop1s competifirstnum i.entryyear i.Yearbirth i.Ageatfirst
restore

* 4.2.3. The relationship between treatment, competitiveness and success.  All sample. Yearly treatments.
preserve
drop if (LaLiga == "Not Yet" | LaLiga == "Not yet" | LaLiga == "?")
drop if (A == "Not Yet" | A == "Not yet" | A == "?")
drop if (ProContract18 == "Not Yet" | ProContract18 == "Not yet" | ProContract18 == "?")
destring LaLiga, replace
destring A, replace
destring ProContract18, replace
probit ProContract18 comptreatment1 comptreatment2 anticomptreatment Prop1s competifirstnum
probit ProContract18 comptreatment1 comptreatment2 anticomptreatment Prop1s competifirstnum i.entryyear i.Yearbirth i.Ageatfirst
probit UnderSpain comptreatment1 comptreatment2 anticomptreatment Prop1s competifirstnum
probit UnderSpain comptreatment1 comptreatment2 anticomptreatment Prop1s competifirstnum i.entryyear i.Yearbirth i.Ageatfirst
probit A comptreatment1 comptreatment2 anticomptreatment Prop1s competifirstnum
probit A comptreatment1 comptreatment2 anticomptreatment Prop1s competifirstnum i.entryyear i.Yearbirth i.Ageatfirst
probit LaLiga comptreatment1 comptreatment2 anticomptreatment Prop1s competifirstnum
probit LaLiga comptreatment1 comptreatment2 anticomptreatment Prop1s competifirstnum i.entryyear i.Yearbirth i.Ageatfirst
restore

* 4.1.4. The relationship between treatment, competitiveness and success. Excluding cut player.
preserve
drop if (LaLiga == "Not Yet" | LaLiga == "Not yet" | LaLiga == "?")
drop if (A == "Not Yet" | A == "Not yet" | A == "?")
drop if (ProContract18 == "Not Yet" | ProContract18 == "Not yet" | ProContract18 == "?")
destring LaLiga, replace
destring A, replace
destring ProContract18, replace
drop if cut == 1
probit ProContract18 comptreatment1 comptreatment2 anticomptreatment Prop1s competifirstnum
probit ProContract18 comptreatment1 comptreatment2 anticomptreatment Prop1s competifirstnum i.entryyear i.Yearbirth i.Ageatfirst
probit UnderSpain comptreatment1 comptreatment2 anticomptreatment Prop1s competifirstnum
probit UnderSpain comptreatment1 comptreatment2 anticomptreatment Prop1s competifirstnum i.entryyear i.Yearbirth i.Ageatfirst
probit A comptreatment1 comptreatment2 anticomptreatment Prop1s competifirstnum
probit A comptreatment1 comptreatment2 anticomptreatment Prop1s competifirstnum i.entryyear i.Yearbirth i.Ageatfirst
probit LaLiga comptreatment1 comptreatment2 anticomptreatment Prop1s competifirstnum
probit LaLiga comptreatment1 comptreatment2 anticomptreatment Prop1s competifirstnum i.entryyear i.Yearbirth i.Ageatfirst
restore


* 4. FIRST ANALYSIS OF AGE 
* 4.0. Reshape data set 
reshape long C, i(PlayerID) j(year)

* 4.2. Generate variables for analysis
gen Age = year - Yearbirth
gen Aget1 = Yearstreatmentcomp1 - Yearbirth
replace Aget1 = 0 if Aget1 < -1900
gen Aget2 = Yearstreatmentcomp2 - Yearbirth
replace Aget2 = 0 if Aget2 < -1900
gen Ageat1 = Yearstreatmentanticomp1 - Yearbirth
replace Ageat1 = 0 if Ageat1 < -1900

gen yearsfromtreatmentcomp1 = year - Yearstreatmentcomp1
replace yearsfromtreatmentcomp1 = 0 if yearsfromtreatmentcomp1 < 0 
replace yearsfromtreatmentcomp1 = 0 if yearsfromtreatmentcomp1 > 2000 
gen yearsfromtreatmentcomp2 = year - Yearstreatmentcomp2
replace yearsfromtreatmentcomp2 = 0 if yearsfromtreatmentcomp2 < 0 
replace yearsfromtreatmentcomp2 = 0 if yearsfromtreatmentcomp2 > 2000 
gen yearsfromtreatmentanticomp1 = year - Yearstreatmentanticomp1
replace yearsfromtreatmentanticomp1 = 0 if yearsfromtreatmentanticomp1 < 0 
replace yearsfromtreatmentanticomp1 = 0 if yearsfromtreatmentanticomp1 > 2000 

gen treatmentcomp1dummy = 0 
replace treatmentcomp1dummy = 1 if yearsfromtreatmentcomp1 > 0 
gen treatmentcomp2dummy = 0 
replace treatmentcomp2dummy = 1 if yearsfromtreatmentcomp2 > 0 
gen treatmentanticomp1dummy = 0 
replace treatmentanticomp1dummy = 1 if yearsfromtreatmentanticomp1 > 0 
gen intertreatcomp1treatcomp2 = treatmentcomp1dummy * treatmentcomp2dummy
gen intertreatcomp1treatanticomp1 = treatmentcomp1dummy * treatmentanticomp1dummy
gen intertreatcomp2treatanticomp1 = treatmentcomp2dummy * treatmentanticomp1dummy
gen intertotaltreatment = treatmentcomp1dummy * treatmentcomp2dummy * treatmentanticomp1dummy
gen intertreatcomp1age = treatmentcomp1dummy * Aget1
gen intertreatcomp2age = treatmentcomp2dummy * Aget2
gen intertreatanticomp1age = treatmentanticomp1dummy * Ageat1

* 4.1. Histograms of age
preserve
drop if C == "Cut"
drop if C == "Not applicable"
histogram Age
restore

preserve
drop if C == "Cut"
drop if C == "Not applicable"
drop if cut == 1
histogram Age
restore
* Comment: looks reasonable, as new entries are not cut

* 4.2. Relationship between age and competitiveness
* 4.2.2. Relationship only for those that are not cut (avoiding selection problem of those that persist) and start since they are little (avoiding scouts selecting boys that are specially competitive)
preserve
drop if cut == 1
drop if C == "Not applicable"
destring C, replace
reg C i.Age
coefplot, vertical drop(_cons) yline(0)
reg C i.Age i.entryyear i.Yearbirth i.Ageatfirst
reg C i.Age i.entryyear i.Yearbirth i.Ageatfirst i.PlayerID

preserve
drop if cut == 1
drop if C == "Not applicable"
destring C, replace
probit C i.Age
coefplot, vertical drop(_cons) yline(0)
probit C i.Age i.entryyear i.Yearbirth i.Ageatfirst
probit C i.Age i.entryyear i.Yearbirth i.Ageatfirst i.PlayerID
restore

preserve
drop if cut == 1
drop if Ageatfirst != 10
drop if C == "Not applicable"
drop if entryyear == 2018
destring C, replace
reg C i.Age
coefplot, vertical drop(_cons) yline(0)
reg C i.Age i.entryyear i.Yearbirth i.Ageatfirst
reg C i.Age i.entryyear i.Yearbirth i.Ageatfirst i.PlayerID
restore

preserve
drop if cut == 1
drop if Ageatfirst != 10
drop if C == "Not applicable"
destring C, replace
drop if entryyear == 2018
probit C i.Age
coefplot, vertical drop(_cons) yline(0)
probit C i.Age i.Yearbirth i.Ageatfirst i.entryyear
probit C i.Age i.Yearbirth i.Ageatfirst i.entryyear i.PlayerID
restore
* Comment: Big jump in competitiveness between the ages of 13 and 15. At the age of 15 men are already developed competition-wise?


* 4.2.1. Relationship for the whole sample
preserve
drop if C == "Cut"
drop if C == "Not applicable"
destring C, replace
reg C i.Age i.entryyear i.PlayerID
probit C i.Age i.entryyear
restore
* Comment: Big jump in competitiveness between the ages of 13 and 15.


* FIRST ANALYSIS: INFLUENCE OF THE TREATMENT ON INTERMEDIATE OUTCOMES.
* First analysis: Intermediate outcomes. The influence of the treatment on the competitiveness of players
* Are players more competitive? All sample - Super competitive and anticompetitive trainers - before/after
preserve
drop if C == "Cut"
drop if C == "Not applicable"
destring C, replace
reg C treatmentcomp1dummy treatmentcomp2dummy treatmentanticomp1dummy i.Age i.entryyear
probit C treatmentcomp1dummy treatmentcomp2dummy treatmentanticomp1dummy i.Age i.entryyear
restore
* Are players more competitive? All sample - Super competitive and anticompetitive trainers - by years since treatment
preserve
drop if C == "Cut"
drop if C == "Not applicable"
destring C, replace
reg C i.yearsfromtreatmentcomp1 i.yearsfromtreatmentcomp2 i.yearsfromtreatmentanticomp1 i.Age i.entryyear
probit C i.yearsfromtreatmentcomp1 i.yearsfromtreatmentcomp2 i.yearsfromtreatmentanticomp1 i.Age i.entryyear
restore
* Are players more competitive? All sample if not cut - Super competitive and anticompetitive trainers - before/after
preserve
drop if cut == 1
drop if C == "Not applicable"
destring C, replace
reg C treatmentcomp1dummy treatmentcomp2dummy treatmentanticomp1dummy i.Age i.entryyear
probit C treatmentcomp1dummy treatmentcomp2dummy treatmentanticomp1dummy i.Age i.entryyear
restore
* Are players more competitive? All sample if not cut - Super competitive and anticompetitive trainers - by years since treatment
preserve
drop if cut == 1
drop if C == "Not applicable"
destring C, replace
reg C i.yearsfromtreatmentcomp1 i.yearsfromtreatmentcomp2 i.yearsfromtreatmentanticomp1 i.Age i.entryyear
probit C i.yearsfromtreatmentcomp1 i.yearsfromtreatmentcomp2 i.yearsfromtreatmentanticomp1 i.Age i.entryyear
restore
* Comment: No apparent effect of anticompetitive treatment. Time-wise, the effect seems to be concentrated the year following the treatment.

* First analysis: Intermediate outcomes. The influence of the treatment, age and their interaction on competitiveness
preserve
drop if cut == 1
drop if C == "Not applicable"
destring C, replace
reg C treatmentcomp1dummy i.Age i.Aget1 i.entryyear
probit C treatmentcomp1dummy i.Age i.Aget1 i.entryyear
reg C i.Age i.Aget1 i.entryyear
probit C i.Age i.Aget1 i.entryyear
restore

preserve
drop if cut == 1
drop if C == "Not applicable"
destring C, replace
reg C treatmentcomp2dummy i.Age i.Aget2 i.entryyear
probit C treatmentcomp2dummy i.Age i.Aget2 i.entryyear
reg C i.Age i.Aget2 i.entryyear
probit C i.Age i.Aget2 i.entryyear
restore

preserve
drop if cut == 1
drop if C == "Not applicable"
destring C, replace
reg C treatmentanticomp1dummy i.Age i.Ageat1 i.entryyear
probit C treatmentanticomp1dummy i.Age i.Ageat1 i.entryyear
reg C i.Age i.Ageat1 i.entryyear
probit C i.Age i.Ageat1 i.entryyear
restore

preserve
drop if cut == 1
drop if C == "Not applicable"
destring C, replace
reg C treatmentcomp1dummy treatmentcomp2dummy treatmentanticomp1dummy i.Age i.Aget1 i.Aget2 i.Ageat1 i.entryyear
probit C treatmentcomp1dummy treatmentcomp2dummy treatmentanticomp1dummy i.Age i.Aget1 i.Aget2 i.Ageat1 i.entryyear
restore

preserve
drop if cut == 1
drop if C == "Not applicable"
destring C, replace
reg C i.Age i.Aget1 i.Aget2 i.Ageat1 i.entryyear
probit C i.Age i.Aget1 i.Aget2 i.Ageat1 i.entryyear
restore

preserve
drop if cut == 1
drop if C == "Not applicable"
destring C, replace
reg C i.yearsfromtreatmentcomp1 i.yearsfromtreatmentcomp2 i.yearsfromtreatmentanticomp1 i.Age i.Aget1 i.Aget2 i.Ageat1 i.entryyear
probit C i.yearsfromtreatmentcomp1 i.yearsfromtreatmentcomp2 i.yearsfromtreatmentanticomp1 i.Age i.Aget1 i.Aget2 i.Ageat1 i.entryyear
restore
* Comment: Interesting effect, it seems that the most positive influence is achieved for the ages between 13 and 15, although for kids of age 10 the procompetitive treatment may induce the opposite effects.

* First analysis: Intermediate outcomes. The influence of the treatment, initial competitiveness and their interaction on  final competitiveness

* First analysis: Intermediate outcomes. The influence of the treatment on players being cut at some point
* Are players cut more before/after? All sample - 


