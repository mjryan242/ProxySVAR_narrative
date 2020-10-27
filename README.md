# ProxySVAR_narrative


1. File "nzhansard_uncertainty_proxy_var.R" takes the NZ Hansard (file too big to store here; available on request) as supplied by M. Qasim and performs the following steps:
-preprocessing steps (removes digits, puncation etc)
-isolates 40 word windows under "uncertainty" and its variants
-performs topic modelling


Note: Owing to the size of the task I run this on an Amazon server

2. File "2._Instrument_creation" creates the instrument
Inputs from step 1:theta,
Other inputs: Topic_names (a file that maps topic id to its high level and specific topics; topics are labelled using top 20 words in xxxx file)
	      official_vol_dates_LU.csv  - a file that gives the dates the different Hansard volumes span
	       Measures_FINAL_weighted.csv - a file that contains the uncertainty index and other macroeconomic data from:
              "Ryan,  M.   (2020).An  anchor  in  stormy  seas:   Does  reforming  economic  in-stitutions  reduce  uncertainty?  evidence  from  New  Zealand(Unpublishedmanuscript).  University of Waikato."
Outputs: "Narrative_IV.csv"  (alternatively called exo_events2.csv)             

3. R File "Figures_1_to_4" creates figures 1-4 in the paper

4 Eviews file:  Preprocessing
Input:  Macro data from Ryan (2020)
Step 1: Filters the data including the creating Bloom-type instrument
Step 2: Estimates a recursive VAR
Step 3: tests instrument relevance and exogeneity (table 2 and 3 of paper)
DW critical values from: https://wernermurhadi.files.wordpress.com/2011/07/tabel-durbin-watson.pdf





5.Estimate the proxy SVAR using the code of Montiel Olea, stock and watson
File is called: UncertaintyIV
Key input in general:"timeU"-a date index;  and data_for_SVARIV.xlsx (the macro dataset produced in step 4)

Key input data for my instrument: Narrative_IV_m.xlsx
Key input data for bloom instrument: ExtIV_bloom

Outputs are impulse responses  ####need to update paper (slightly out in R)
IRF point estimates are "PLUgin" => irf
confidence intervals
plugins are available in InferenceMSW => Dmethodlbound and Dmethodubound 
weak instrument are available in: InferenceMSW => MSWlbound and MSWubound  

Estimate.m does the equivalent with the code of Carriero, A., Mumtaz, H., Theodoridis, K., & Theophilopoulou, A. (2015). Theimpact  of  uncertainty  shocks  under  measurement  error:  a  Proxy  SVARapproach.  
I use the FEVD from this code (it uses data_for_proxysvar.xlsx and  data_for_proxysvar_bloom.xlsx) which are the above datasets with the instrument appended




6.  The various impulse response files create impulse responses for the paper
