################################################################################
#Outbreak scnenarios
#-CPRD data
#- waning
################################################################################

#set up
options(scipen = 999)
source("R/function_figures.R")
source("R/function_vaccination_data.R")
source("R/function_model_compatibility.R")

## Import libraries 
#devtools::install_github("alxsrobert/seirvodin")
library(seirvodin)
library(dplyr)
library(socialmixr)
library(odin.dust)
library(mcstate)
library(tictoc)
library(tidyr)
library(ggplot2)
library(data.table)

clean_mcmc_pars <- function(mcmc_pars){
  colnames(mcmc_pars)[which(colnames(mcmc_pars) == "catchup")] <- "catchup_10"
  colnames(mcmc_pars)[which(colnames(mcmc_pars) == "catchup2")] <- "catchup2_7"
  colnames(mcmc_pars)[which(colnames(mcmc_pars) == "recov11to15")] <- "recov_8"
  colnames(mcmc_pars)[which(colnames(mcmc_pars) == "recov16to20")] <- "recov_9"
  colnames(mcmc_pars)[which(colnames(mcmc_pars) == "recov21to30")] <- "recov_10"
  colnames(mcmc_pars)[which(colnames(mcmc_pars) == "recov31to40")] <- "recov_11"
  colnames(mcmc_pars)[which(colnames(mcmc_pars) == "recov40plus")] <- "recov_12"
  colnames(mcmc_pars)[which(colnames(mcmc_pars) == "v_70s")] <- "v_11"
  
  return(mcmc_pars)
}


create_scenario <- function(scenario_name, burnin = 5000, waning = "since_vax",
                            vax = "cprd", n_samples = 100, n_part = 25,
                            model = compatible_seirv_age_region()){
  scenario <- scenario_name
  if(n_samples < 2L || n_part < 2L){
    stop("seirvodin 1.0 requires n_samples >= 2 and n_part >= 2 when aggreg_year = TRUE")
  }
  
  #### Import data and model fit ####
  
  year_start <- 2010
  N_year <- 10
  N_time <- t_tot <- 365 * N_year
  
  
  age <- c("[0,1)", "[1,2)", "[2,3)", "[3,4)", "[4,5)", "[5,6)", "[6,10)", "[10,15)",
           "[15,20)", "[20,30)", "[30,40)", "[40,100]")
  year_per_age <- c(1, 1, 1, 1, 1, 1, 4, 5, 5, 10, 10, 40)
  
  regions <- c("North East", "North West", "Yorkshire and The Humber", "East Midlands",
               "West Midlands", "East", "London", "South East", "South West")
  
  ## Import the different data streams into a list.
  # Use scenario to move between vaccine scenarios (early / early_timely etc..)
  all_data <- import_all_data(year_start = year_start, N_year = N_year, 
                              scenario = scenario, vax = vax, regions = regions,
                              year_per_age = year_per_age)
  
  
  all_specs <- seirvodin::specs_simulations(
    year_start = year_start, N_year = N_year, waning = waning, burnin = burnin, 
    n_samples = n_samples, nowane = FALSE, deterministic = FALSE
  )
  
  
  ## Import the parameter estimates
  if(waning == "no"){
    if(vax == "cprd"){
      pmcmc_run <- readRDS("Output/cprd_degree/no.RDS")
    } else if (vax == "cover"){
      pmcmc_run <- readRDS("Output/cover_degree/no.RDS")
    }
  } else if(waning %in% c("since_vax", "early")){
    if(vax == "cprd"){
      pmcmc_run <- readRDS("Output/cprd_degree/since_vax.RDS")
    } else if (vax == "cover"){
      pmcmc_run <- readRDS("Output/cover_degree/since_vax.RDS")
    }
  } else stop("wrong value of waning, should be `no`, `since_vax`, or `early")
  
  
  pmcmc_run$pars <- clean_mcmc_pars(mcmc_pars = pmcmc_run$pars)
  
  all_output <- 
    seirvodin::generate_outbreaks(
      model_run = pmcmc_run, model = model,
      list_specs = all_specs, list_data = all_data, n_part = n_part, 
      verbose = T, aggreg_year = TRUE  )
  
  return(all_output)  
}


set.seed(1)
#### Analysis of all_output ####
reference <- create_scenario(scenario_name = "reference")
saveRDS(reference, file="Output/models/reference_waningCPRD.rda")
rm(reference)
gc()


early_second <- create_scenario(scenario_name = "early slow")
saveRDS(early_second, file="Output/models/early_second_waningCPRD.rda")
rm(early_second)
gc()


MMR2_at_5 <- create_scenario(scenario_name = "MMR2_at5")
saveRDS(MMR2_at_5, file="Output/models/MMR2_at_5_waningCPRD.rda")
rm(MMR2_at_5)
gc()

MMR2_as_MMR1 <- create_scenario(scenario_name = "MMR2_as_MMR1")
saveRDS(MMR2_as_MMR1, file="Output/models/MMR2_as_MMR1_waningCPRD.rda")
rm(MMR2_as_MMR1)
gc()

D2_earlyplus025 <- create_scenario(scenario_name = "D2_earlyplus025")
saveRDS(D2_earlyplus025, file="Output/models/D2_earlyplus025_waningCPRD.rda")
rm(D2_earlyplus025)
gc()


D2_earlyplus05 <- create_scenario(scenario_name = "D2_earlyplus05")
saveRDS(D2_earlyplus05, file="Output/models/D2_earlyplus05_waningCPRD.rda")
rm(D2_earlyplus05)
gc()



D2_earlyplus1 <- create_scenario(scenario_name = "D2_earlyplus1")
saveRDS(D2_earlyplus1, file="Output/models/D2_earlyplus1_waningCPRD.rda")
rm(D2_earlyplus1)
gc()


D2_3 <- create_scenario(scenario_name = "D2_3")
saveRDS(D2_3, file="Output/models/D2_3_waningCPRD.rda")
rm(D2_3)
gc()

D1_1 <- create_scenario(scenario_name = "D1_1")
saveRDS(D1_1, file="Output/models/D1_1_waningCPRD.rda")
rm(D1_1)
gc()

D2_1 <- create_scenario(scenario_name = "D2_1")
saveRDS(D2_1, file="Output/models/D2_1_waningCPRD.rda")
rm(D2_1)
gc()

D1_05 <- create_scenario(scenario_name = "D1_05")
saveRDS(D1_05, file="Output/models/D1_05_waningCPRD.rda")
rm(D1_05)
gc()

D2_05 <- create_scenario(scenario_name = "D2_05")
saveRDS(D2_05, file="Output/models/D2_05_waningCPRD.rda")
rm(D2_05)
gc()

D1_025 <- create_scenario(scenario_name = "D1_025")
saveRDS(D1_025, file="Output/models/D1_025_waningCPRD.rda")
rm(D1_025)
gc()


D2_025 <- create_scenario(scenario_name = "D2_025")
saveRDS(D2_025, file="Output/models/D2_025_waningCPRD.rda")
rm(D2_025)
gc()


D2_minus3 <- create_scenario(scenario_name = "earlyminus3")
saveRDS(D2_minus3, file="Output/models/D2_minus3_waningCPRD.rda")
rm(D2_minus3)
gc()

D2_minus5 <- create_scenario(scenario_name = "earlyminus5")
saveRDS(D2_minus5, file="Output/models/D2_minus5_waningCPRD.rda")
rm(D2_minus5)
gc()



#---summary table for results
all_models <- list.files("Output/models/", pattern ="waningCPRD")
tmp <- readRDS(paste0("Output/models/", all_models[1]))
tmp <- tmp[grep("new_I", rownames(tmp)), ,]
summary_table <- summary(apply(tmp, 2, sum))
rm(tmp)
gc()



for(i in 2:length(all_models)){
  tmp <- readRDS(paste0("Output/models/", all_models[i]))
  tmp <- tmp[grep("new_I", rownames(tmp)), ,]
  row <- summary(apply(tmp, 2, sum))
  rm(tmp)
  summary_table <- rbind(summary_table, row)
  gc()
}

#generating summary table
summary_table <- cbind(c("MMR1 +0.25","MMR1 +0.5","MMR1 +1",
                         "MMR2 +0.25","MMR2 +0.5","MMR2 +1",
                         "MMR2 + 3",
                         "early +0.25", "early +0.5","early +1",
                         "MMR2 -3","MMR2 -5","early second","early MMR2 like MMR1",
                         "MMR2 at 5", "reference"), summary_table)
summary_table <- as.data.table(summary_table)
summary_table[, result := paste0(`Median`, " (", `1st Qu.`, "; ", `3rd Qu.`, ")")]
med_ref <- as.numeric(summary_table$Median[16])
summary_table[, Median := as.numeric(Median)]
summary_table[, `1st Qu.` := as.numeric(`1st Qu.`)]
summary_table[, `3rd Qu.` := as.numeric(`3rd Qu.`)]
summary_table[, diff_per := paste0(round(  (((med_ref-Median)/med_ref)*100), digits = 2),
                                   " (" , round((((med_ref-`3rd Qu.`)/med_ref)*100), digits = 2),
                                   "; ", round((((med_ref-`1st Qu.`)/med_ref)*100), digits = 2),")")]

write.csv2(summary_table, file = "Output/Summary_table_CPRD_waning.csv")


