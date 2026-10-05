This Github repository contains the code used to run age-stratified, metapopulation compartmental models using odin.dust with different scenarios for vaccination uptake. These models are used to analyse the dynamics of measles outbreaks in England between 2010 and 2019, and to simulate changes in vaccination coverage between 2010 and 2019. The generated simulations can me found in the models Output/models folder, figures are saved in the in the Figures folder and summary tables are saved in  the Output folder. The R folder contains all the scripts and functions.

For an independent re-run of the reference simulation (without using the
precomputed scenario output), see [`REPRODUCIBILITY.md`](REPRODUCIBILITY.md)
and run `Rscript R/replicate_reference.R`.

The code for fitting the model can be found in a separate repo: https://github.com/alxsrobert/measles_england_sir and the results are published here: https://www.thelancet.com/journals/lanpub/article/PIIS2468-2667(24)00181-6/fulltext

## Installation
Clone/download this project onto your machine.

The following R packages are required to run the code:

```
* seirvodin
* dplyr
* socialmixr
* odin.dust
* mcstate
* tidyr
* rlang
* arrow
* ggplot2
* data.table
* cowplot
```
and can be installed in R by running:
```R
install.packages(c('dplyr', 'socialmixr', 'tidyr','rlang', 'arrow',   'ggplot2', 'data.table', 'cowplot'))
install.packages(c('mcstate', 'odin.dust'), repos = c('https://mrc-ide.r-universe.dev', 'https://cloud.r-project.org'))
devtools::install_github('alxsrobert/seirvodin')
```

## Running the code

The code contains scripts to
* generate the different vaccination scenarios
* create simulations with different vaccination coverage scenarios
* generate figures
* to analyse the results stratfied by region and year



Firstly, to generate the different vaccination scenarios, run the following code:

```R
source('R/Measles_coverage_scenarios_creation.R')
source('R/Measles_coverage_scenarios_creation_NHS.R')
```
The first scripts generate different vaccination scenarios using data from the Clinical Practice Research Datalink Aurum (May 2022 build) which is a population-representative electronic health record dataset which is not publicly avaiable. The methods to measure vaccine uptake in electronic health records have been previously validated (https://onlinelibrary.wiley.com/doi/10.1002/pds.5848) and a description of childhood immunisation coverage in this dataset can be found here: https://www.sciencedirect.com/science/article/pii/S0264410X2300926X?via%3Dihub.
For a sensitivity analysis, we generated the same vaccination scenarios using the publicly aviable coverage data published by NHS England (https://www.england.nhs.uk/statistics/statistical-work-areas/child-immunisation/)


To generate stochastic outbreak simulations for each scenario based on the parameter estimates, run the following command:
```R
#main results
source('R/Outbreak_sencarios_CPRD.R')

#sensitivity analyses
#waning from the age of 5 since vaccination
source('R/Outbreak_scenarios_CPRD_waning.R')
#waning from the age of 3 since vaccination
source('R/Outbreak_scenarios_CPRD_waning_from3.R')
#COVER data used instead of CPRD data
source('R/Outbreak_scnenarios_COVER.R')

```
The runtime is around 34min per scenario. To reduce the runtime change the number of samples (parameter `n_samples`) in line 44 line of `R/Outbreak_scenarios_CPRD.R`. The waning and vax parameter in the create_scenario() need to be specified according to underlying assumption of waning (no = no waning, since_vax = waning from the age of five since vaccination, early = waning from the age of 3 since vaccination) and the vaccination dataset used (cprd = Clinical Research Practice Datalink, cover = COVER). The files with the parameter estimates based on the fitted model are available on the repository and were generated from parameter estimates using the actual case data.
The overall runtime does not exceed 37 hours for running 16 scenarios per script on a virtual machine with a 32-Core 3.0 GHz processor and 128 GB RAM. 

Finally, to generate the figures describing simulations for each scenario, run the following command:
```R
#defining the function to create the figures
source('R/function_figures.R')

#creating the actualy figures
source('R/all_figures.R')

```
All files for the vaccination scenarios are saved in the `Output/models` folder, and all figures are saved in the `Digures` of the folder.


## Output

The output folder contains four subfolders (one for each scenario):
* `Output/cprd_degree/`: Files and figures using CPRD coverage data, and estimating the spatial kernel.
 constant with age.
* `Output/cover_degree/`: Files and figures using COVER coverage data, and estimating the spatial kernel.

Each folder contains three files with the parameter estimates and posterior distribution, computed when fitting the model to measles case data reported in England between 2010 and 2019:
* `no.rds`: model without waning.
* `since_vax.rds`: model with waning by age.


Each file is a list, the parameter estimates are contained in the element `pars` of the list. The log-posterior, log-prior, and log-likelihood scores and contained in the element `probabilities` of the list.



Each file in the model folder contains 2,500 simulations. Each file is a 3-d array (dimension 324*2500*10), containing the number of cases by stratification (i.e. region, age and vaccination status: 324 combinations in total), by simulation (2,500 simulations per set), and by year (10 years between 2010 and 2019). The first element of the array therefore contains the number of unvaccinated cases, in region 1, in the youngest age group, in 2010, in the first simulation. 


## Data

The analysis uses various datasets. The `Data` folder contains the following files:
* `Data/regional_population.csv`: Number of inhabitants per regions and age groups from census data
* `Data/coverage_cover_extrapol.csv`: Vaccine coverage (first and second dose) at 1, 2, 3, 4, and 5 years old, from 2005 to 2019, from UKHSA's COVER data. Coverage at 3 and 4 was extrapolated using age-stratified CPRD data.
* `Data/coverage_cprd_extrapol.csv`: Vaccine coverage (first and second dose) at 1, 2, 3, 4, and 5 years old, from 2005 to 2019, from CPRD data. Coverage for 2015-2019 was extrapolated using the variations in coverage in the COVER data
* `Data/risk_assessment_ukhsa.csv`: Vaccine coverage across England and in London, from UKHSA's risk assessment for measles resurgence (https://assets.publishing.service.gov.uk/government/uploads/system/uploads/attachment_data/file/1170146/risk-assessment-for-measles-resurgence-in-the-UK-2023.pdf).
* `Data/sim_data.RDS`: Simulated case datasets, as actual 2010-2020 case data in England cannot be shared. 

To create the vaccination scenarios, run the following code, and the .csv-files will be added into the same folder:
```R
source(“R/Measles_coverage_scenarios_creation.R”)
source(“R/Measles_coverage_scenarios_creation_NHS.R”)
```

##Figures

This folder containts the figures based on the different simulations which are created using the following command:

```R
#defining the function to create the figures
source(“R/function_figures.R”)

#creating the actualy figures
source(“R/all_figures.R”)

```
