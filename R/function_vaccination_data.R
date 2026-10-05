## Import population data
import_pop_data <- function(year_start){
  ## Import population data
  dt_pop_all <- read.csv2("Data/regional_population.csv", row.names = 1)
  
  ## Keep only columns with overall number of inhabitants (not stratified m/f)
  dt_pop_select <- dt_pop_all[dt_pop_all$Area != "Country", 
                              which(colnames(dt_pop_all) != "Area" & 
                                      (colnames(dt_pop_all) == "Name" |
                                         !grepl("_", colnames(dt_pop_all))))]
  # Extract the number of regions / age
  N_reg <- length(unique(dt_pop_select$Name))
  N_age <- sum(grepl("age", colnames(dt_pop_select)))
  # Fix typo in column name
  colnames(dt_pop_select)[colnames(dt_pop_select) == "age16t20"] <- "age16to20"
  
  ## Create population vector 2006, 2013, 2019
  N_2006 <- t(dt_pop_select[dt_pop_select$Year == 2006, grep("age", colnames(dt_pop_select))])
  N_2013 <- t(dt_pop_select[dt_pop_select$Year == 2013, grep("age", colnames(dt_pop_select))])
  N_2019 <- t(dt_pop_select[dt_pop_select$Year == 2019, grep("age", colnames(dt_pop_select))])
  
  colnames(N_2006) <- colnames(N_2013) <- colnames(N_2019) <- unique(dt_pop_select$Name)
  if(year_start == 2006 || year_start == 2010)N <- N_2006 else stop("Define N")
  return(N)
}

## Import vaccine data => USE IF SCENARIO == "" TO ADD MORE SCENARIOS
import_ehr_vaccine <- function(vax, scenario){
  if(vax == "cprd") adj <- "Yes" else adj <- "No"
  
  if(vax == "cover" & scenario == "reference") {
    cov_per_year <- read.csv2("Data/Coverage_reg_year_nhs_extrapol.csv",
                              sep = ";") %>% 
      as.data.table()
  } else if(vax == "cprd" & scenario == "reference"){
    cov_per_year <- read.csv2("Data/Coverage_reg_year_orig_extrapol.csv",
                              sep = ";") %>% 
      as.data.table()
  }
  
  else if(vax == "cprd" & scenario == "early speedy"){
    cov_per_year <- read.csv2("Data/Coverage_reg_year_earlytimely2nd_extrapol.csv",
                              sep = ";") %>% 
      as.data.table()
  }
  else if(vax == "cprd" & scenario == "early slow"){
    cov_per_year <- read.csv2("Data/Coverage_slowearlysecond.csv",
                              sep = ";") %>% 
      as.data.table()
  }
  else if(vax == "cprd" & scenario == "London"){
    cov_per_year <- read.csv2("Data/Coverage_reg_year_Londonpattern_extrapol.csv",
                              sep = ";") %>% 
      as.data.table()
  }
  else if(vax == "cprd" & scenario == "D1_025"){
    cov_per_year <- read.csv2("Data/d1_025.csv",
                              sep = ";") %>% 
      as.data.table()
    
  }
  else if(vax == "cprd" & scenario == "D1_05"){
    cov_per_year <- read.csv2("Data/d1_05.csv",
                              sep = ";") %>% 
      as.data.table()
    
  }
  else if(vax == "cprd" & scenario == "D1_1"){
    cov_per_year <- read.csv2("Data/d1_1.csv",
                              sep = ";") %>% 
      as.data.table()
    
  }
  else if(vax == "cprd" & scenario == "D2_025"){
    cov_per_year <- read.csv2("Data/d2_025.csv",
                              sep = ";") %>% 
      as.data.table()
    
  }
  else if(vax == "cprd" & scenario == "D2_05"){
    cov_per_year <- read.csv2("Data/d2_05.csv",
                              sep = ";") %>% 
      as.data.table()
    
  }
  else if(vax == "cprd" & scenario == "D2_1"){
    cov_per_year <- read.csv2("Data/d2_1.csv",
                              sep = ";") %>% 
      as.data.table()
    
  }
  else if(vax == "cprd" & scenario == "D2_3"){
    cov_per_year <- read.csv2("Data/d2_3.csv",
                              sep = ";") %>% 
      as.data.table()
    
  }
  else if(vax == "cprd" & scenario == "D2_earlyplus025"){
    cov_per_year <- read.csv2("Data/Coverage_earlyplus025.csv",
                              sep = ";") %>% 
      as.data.table()
    
  }
  else if(vax == "cprd" & scenario == "D2_earlyplus05"){
    cov_per_year <- read.csv2("Data/Coverage_earlyplus05.csv",
                              sep = ";") %>% 
      as.data.table()
    
  }
  else if(vax == "cprd" & scenario == "D2_earlyplus1"){
    cov_per_year <- read.csv2("Data/Coverage_earlyplus1.csv",
                              sep = ";") %>% 
      as.data.table()
    
  }
  
  else if(vax == "cprd" & scenario == "MMR2_as_MMR1"){
    cov_per_year <- read.csv2("Data/Coverage_MMR2likeMMR1.csv",
                              sep = ";") %>% 
      as.data.table()
    
  }
  else if(vax == "cprd" & scenario == "MMR2_at5"){
    cov_per_year <- read.csv2("Data/MMR2_at_5.csv",
                              sep = ";") %>% 
      as.data.table()
    
  }
  
  else if(vax == "cprd" & scenario == "old"){
    cov_per_year <- read.csv2("Data/Coverage_reg_year_orig_extrapol.csv",
                              sep = ";") %>% 
      as.data.table()
    
  }
  #lower uptake in early second dose
  else if(vax == "cprd" & scenario == "earlyminus05"){
    cov_per_year <- read.csv2("Data/Coverage_earlyminus05.csv",
                              sep = ";") %>% 
      as.data.table()
    
  }
  else if(vax == "cprd" & scenario == "earlyminus1"){
    cov_per_year <- read.csv2("Data/Coverage_earlyminus1.csv",
                              sep = ";") %>% 
      as.data.table()
    
  }
  else if(vax == "cprd" & scenario == "earlyminus3"){
    cov_per_year <- read.csv2("Data/Coverage_earlyminus3.csv",
                              sep = ";") %>% 
      as.data.table()
    
  }
  else if(vax == "cprd" & scenario == "earlyminus5"){
    cov_per_year <- read.csv2("Data/Coverage_earlyminus5.csv",
                              sep = ";") %>% 
      as.data.table()
    
  }
  else if(vax == "cprd" & scenario == "earlyminus10"){
    cov_per_year <- read.csv2("Data/Cov2minus10.csv",
                              sep = ";") %>% 
      as.data.table()
    
  }
  else if(vax == "cprd" & scenario == "earlyminus50"){
    cov_per_year <- read.csv2("Data/Cov2minus50.csv",
                              sep = ";") %>% 
      as.data.table()
    
  }
  else if(vax == "cprd" & scenario == "earlyminusall"){
    cov_per_year <- read.csv2("Data/Cove2zero.csv",
                              sep = ";") %>% 
      as.data.table()
    
  }
  
  #sensitivity analsysis data
  else if(vax == "cover" & scenario == "early"){
    cov_per_year <- read.csv2("Data/COVER_earlyMMR2.csv",
                              sep = ";") %>% 
      as.data.table()
    
  }
  else if(vax == "cover" & scenario == "cover_early"){
    cov_per_year <- read.csv2("Data/COVER_earlyMMR2.csv",
                              sep = ";") %>% 
      as.data.table()
    
  }
  else if(vax == "cover" & scenario == "cover_MMR2likeMMR1"){
    cov_per_year <- read.csv2("Data/COVER_earlyMMR2_likeMMR1.csv",
                              sep = ";") %>% 
      as.data.table()
    
  }
  else if(vax == "cover" & scenario == "cover_MMR2minus3"){
    cov_per_year <- read.csv2("Data/COVER_earlyMMR2_minus3.csv",
                              sep = ";") %>% 
      as.data.table()
    
  }
  
  else if(vax == "cover" & scenario == "cover_MMR2minus5"){
    cov_per_year <- read.csv2("Data/COVER_earlyMMR2_minus5.csv",
                              sep = ";") %>% 
      as.data.table()
    
  }

  else if(vax == "cover" & scenario == "cover_lateMMR2"){
    cov_per_year <- read.csv2("Data/COVER_lateMMR2.csv",
                              sep = ";") %>% 
      as.data.table()
    
  }
  else if(vax == "cover" & scenario == "cover_MMR1plus1"){
    cov_per_year <- read.csv2("Data/COVER_MMR1plus1.csv",
                              sep = ";") %>% 
      as.data.table()
    
  }
  else if(vax == "cover" & scenario == "cover_MMR1plus05"){
    cov_per_year <- read.csv2("Data/COVER_MMR1plus05.csv",
                              sep = ";") %>% 
      as.data.table()
    
  }
  
  
  else if(vax == "cover" & scenario == "cover_MMR2plus1"){
    cov_per_year <- read.csv2("Data/COVER_MMR2plus1.csv",
                              sep = ";") %>% 
      as.data.table()
    
  }
  else if(vax == "cover" & scenario == "cover_MMR2plus3"){
    cov_per_year <- read.csv2("Data/COVER_MMR2plus3.csv",
                              sep = ";") %>% 
      as.data.table()
    
  }
  else if(vax == "cover" & scenario == "cover_earlyMMR2plus1"){
    cov_per_year <- read.csv2("Data/COVER_earlyMMR2plus1.csv",
                              sep = ";") %>% 
      as.data.table()
    
  }
  else if(vax == "cover" & scenario == "cover_earlyMMR2plus3"){
    cov_per_year <- read.csv2("Data/COVER_earlyMMR2plus3.csv",
                              sep = ";") %>% 
      as.data.table()
    
  }
  else if(vax == "cover" & scenario == "cover_earlyMMR2minus3"){
    cov_per_year <- read.csv2("Data/COVER_earlyMMR2_minus3.csv",
                              sep = ";") %>% 
      as.data.table()
    
  }
  else if(vax == "cover" & scenario == "cover_earlyMMR2minus5"){
    cov_per_year <- read.csv2("Data/COVER_earlyMMR2_minus5.csv",
                              sep = ";") %>% 
      as.data.table()
    
  }
  #sensitivity analysis startinf in 2015
  else if(vax == "cprd" & scenario == "CPRD_earlyMMR2_2015"){
    cov_per_year <- read.csv2("Data/EarlyMMR2_2015.csv",
                              sep = ";") %>% 
      as.data.table()
    
  }
  
  

  ## Formatting changes
  cov_per_year[, region := toupper(region)]
  cov_per_year[, dose := as.numeric(n_dose)]
  cov_per_year[, n_dose := NULL]
  cov_per_year[, year := as.numeric(year)]
  
  cov_per_year[, cov1y := as.numeric(cov1y)]
  cov_per_year[, cov2y := as.numeric(cov2y)]
  cov_per_year[, cov3y := as.numeric(cov3y)]
  cov_per_year[, cov4y := as.numeric(cov4y)]
  cov_per_year[, cov5y := as.numeric(cov5y)]
  
  ## Switch to long format 
  cov_per_year_long <- pivot_longer(cov_per_year, cols = paste0("cov", 1:5, "y"),
                                    names_to = "age", values_to = "coverage") %>% 
    as.data.table
  

  ## Remove "covXy" from the column "age" => only keep age
  cov_per_year_long[, age := as.numeric(substr(age, 4, 4))]
  ## Compute year of birth
  cov_per_year_long[, yob := year - age]
  ## Set NA values to 0
  cov_per_year_long[is.infinite(coverage), coverage := 0]
  
  ## Set dt_vacc by selecting some of the columns
  dt_vacc <- cov_per_year_long[, .(year, region, vaccine, coverage, yob, dose, age)]
  
  ## Coverage at 1 is 75% of coverage at 2
  dt_vacc[age == 1 & dose == 1, coverage := dt_vacc[age == 2 & dose == 1, coverage] * .75]
  ## Second dose coverage
  if(!scenario %in% c("early slow", "early speedy", "MMR2_at5", "MMR2_as_MMR1",
                      "D2_earlyplus025", "D2_earlyplus05", "D2_earlyplus1",
                      "earlyminus3", "earlyminus5", "year_2015")){
    dt_vacc[age == 3 & dose == 2, coverage := dt_vacc[age == 4 & dose == 2, coverage] * .5]
  }

  dt_vacc[age == 1 & dose == 2, coverage := 0]
  
  ### Avoid individuals going from S to V2 within 1 year
  ## Set id
  dt_vacc[, id := paste(year, tolower(region), dose, age, sep = "_")]
  setkey(dt_vacc, id)
  ## Compute 1st dose coverage at 1, for entries where age = 2 and dose = 2
  dt_vacc[age == 2 & dose == 2, 
          cov1 := dt_vacc[paste(dt_vacc[age == 2 & dose == 2, year - 1],
                                dt_vacc[age == 2 & dose == 2, tolower(region)],
                                1, 1, sep = "_"), coverage]
  ]
  ## If 1st dose coverage at 1 is below 2nd dose coverage at 2, set 2nd dose 
  ## coverage to 1st dose coverage at 1
  dt_vacc[cov1 < coverage, coverage := cov1]
  ## Remove columns cov1 and id
  dt_vacc[, cov1 := NULL]
  dt_vacc[, id := NULL]

  dt_vacc[region == "EAST OF ENGLAND", region := "EAST"]
  dt_vacc <- dt_vacc[yob > 2004,]
  
  past_cov <- as.data.table(read.csv2("Data/risk_assessment_ukhsa.csv", sep = ","))
  past_cov[, Coverage := as.numeric(Coverage) / 100]
  colnames(past_cov) <- c("region", "yob", "dose", "adjusted", "coverage")
  past_cov[, region := toupper(region)]
  past_cov <- past_cov[c(
    rep(which(region == "ENGLAND"), each = length(unique(dt_vacc$region)) - 1),
    which(region == "LONDON")),]
  
  past_cov[region == "ENGLAND", 
           region := rep(unique(dt_vacc[region != "LONDON", region]), 
                         sum(past_cov$region == "LONDON"))]
  
  past_cov <- past_cov[yob <= 2004,]
  past_cov <- past_cov[dose != "suscep",]
  past_cov[, vaccine := "MMR"]
  past_cov <- past_cov[adjusted == adj,]
  past_cov[, dose := as.numeric(gsub("MMR", "", dose))]
  past_cov[, year := 2019]
  past_cov[, age := NA]
  past_cov[, adjusted := NULL]
  dt_vacc <- as.data.table(rbind.data.frame(
    dt_vacc, past_cov[,colnames(dt_vacc), with = F]))
  dt_vacc <- dt_vacc[!is.na(coverage),]
  
  dt_vacc[, id := paste(year, tolower(region), dose, age, sep = "_")]
  colnames(dt_vacc) <- c("years", "region", "vac_code", "coverage", "yob", "dose",
                         "age", "id")
  setkey(dt_vacc, id)
  
  return(dt_vacc)
}

# Import number of births
compute_n_birth <- function(year_start, N_year){
  ## Import population data
  dt_pop_all <- read.csv2("Data/regional_population.csv", row.names = 1)
  
  dt_pop_select <- dt_pop_all[dt_pop_all$Area != "Country", 
                              which(colnames(dt_pop_all) != "Area" & 
                                      (colnames(dt_pop_all) == "Name" |
                                         !grepl("_", colnames(dt_pop_all))))]
  colnames(dt_pop_select)[colnames(dt_pop_select) == "age16t20"] <- "age16to20"
  
  ## Compute number of births per year
  ## Initialise the empty matrix
  n_birth_per_year <- matrix(, nrow = max(dt_pop_select$Year) - min(dt_pop_select$Year) + 6,
                             ncol = length(unique(dt_pop_select$Name)))
  rownames(n_birth_per_year) <- seq(min(dt_pop_select$Year) - 5, max(dt_pop_select$Year))
  colnames(n_birth_per_year) <- unique(dt_pop_select$Name)
  
  ## At each year, compute the number of new births as the number of inhabitants on yob
  age_n_birth <- c(0, 1, 2, 3, 4, 5)
  for(i in seq_len(nrow(dt_pop_select))){
    n_birth_per_year[as.character(dt_pop_select$Year[i] - age_n_birth), 
                     dt_pop_select$Name[i]] <- 
      as.numeric(dt_pop_select[i, paste0("age", 0:5)])
  }
  ## For NA values, use the number of births at the previous year 
  n_birth_per_year[is.na(n_birth_per_year[,1]),] <- n_birth_per_year[which(is.na(n_birth_per_year[,1])) - 1,]
  ## Keep data from 2010 onwards
  n_birth_per_year <- n_birth_per_year[as.character(seq(year_start, year_start + N_year - 1)),]
  ## Compute the number of births per year
  new_birth <- t(n_birth_per_year[rep(seq_len(nrow(n_birth_per_year)), each = 365), ]) / 365
  return(new_birth)
}

compute_contact_matrix <- function(year_per_age){
  ## Define contact matrix
  data("polymod", package = "socialmixr", envir = environment())
  age_limits <- cumsum(year_per_age) - year_per_age

  ## Freeze the 2005 UK population used by socialmixr's former implicit
  ## wpp2017 lookup.  Passing it explicitly avoids deprecated API calls and
  ## preserves the contact matrix used by the original analysis exactly.
  published_age_limits <- c(0, 1, 2, 3, 4, 5, 6, 10, 15, 20, 30, 40)
  if(!identical(as.numeric(age_limits), published_age_limits)){
    stop("The frozen POLYMOD demography is defined for the published age bands only")
  }
  polymod_uk_population_2005 <- data.frame(
    lower.age.limit = published_age_limits,
    population = c(
      690734, 690734, 690734, 690734, 690734, 711777,
      2847110, 3826567, 3960166, 7661709, 8864593, 28961159
    )
  )
  ## Get the contact matrix from socialmixr
  contact <- socialmixr::contact_matrix(
    survey = polymod,
    countries = "United Kingdom",
    survey_pop = polymod_uk_population_2005,
    age_limits = age_limits,
    symmetric = TRUE)
  
  ## Transform the matrix to the (symetrical) transmission matrix
  ## rather than the contact matrix. This transmission matrix is
  ## weighted by the population in each age band (equal to the contact 
  ## rate per capita).
  ref_m <- 1e6 * contact$matrix /
    rep(contact$demography$population, each = ncol(contact$matrix))
  
  # # The number of contacts between groups is smaller than within groups
  rownames(ref_m) <- colnames(ref_m) <- 
    paste(cumsum(year_per_age) - year_per_age, cumsum(year_per_age), sep = "-")
  return(ref_m)
}

## Compute contact matrix between regions
compute_region_matrix <- function(regions){
  ## Create the neighbour matrix
  ref_d <- matrix(c(1, 2, 2, 3, 3, 4, 5, 4, 4,
                    2, 1, 2, 2, 2, 3, 4, 3, 3,
                    2, 2, 1, 2, 3, 3, 4, 3, 4,
                    3, 2, 2, 1, 2, 2, 3, 2, 3,
                    3, 2, 3, 2, 1, 3, 3, 2, 2,
                    4, 3, 3, 2, 3, 1, 2, 2, 3,
                    5, 4, 4, 3, 3, 2, 1, 2, 3,
                    4, 3, 3, 2, 2, 2, 2, 1, 2,
                    4, 3, 4, 3, 2, 3, 3, 2, 1), nrow = length(regions))
  colnames(ref_d) <- rownames(ref_d) <- regions
  return(ref_d)  
}

compute_importation <- function(regions, N_age, scenario_import = "per_year"){
  ## Define number of import per day
  if(scenario_import == "pop"){
    mean_import_per_reg <- sum(c(1.6, 3.2, 3.0, 2.0, 2.3, 3.2, 20.1, 7.6, 3.2)) / 365.25 /  N_age *
      colSums(N) / sum(N)
  } else if(scenario_import == "per_year"){ 
    # Cases classified as imported or possible import in the epi data. 
    mean_import_per_reg <- matrix(c(4, 2,  4,  1, 1,  8, 12, 10, 2,
                                    1, 6,  3,  3, 10, 4, 55, 30, 10,
                                    2, 10, 4,  2, 6,  3, 10, 7,  5,
                                    6, 5,  3,  2, 2,  6, 7,  3,  2,
                                    1, 4,  1,  2, 3,  3, 19, 4,  1,
                                    1, 2,  0,  1, 2,  1, 11, 1,  4,
                                    0, 1,  1,  0, 0,  3, 15, 5,  3,
                                    2, 6,  2,  1, 4,  4, 19, 3,  2,
                                    1, 3,  13, 4, 5,  1, 36, 10, 4,
                                    1, 6,  4,  6, 2,  8, 39, 14, 4),
                                  ncol = length(regions), byrow = T
    )/365.25/  N_age
    colnames(mean_import_per_reg) <- regions
  } else {
    mean_import_per_reg <- (c(1.6, 3.2, 3.0, 2.0, 2.3, 3.2, 20.1, 7.6, 3.2) / N_age) / 365.25# * 5
  }
  return(mean_import_per_reg)
}

## Import all data using all other functions, and return in a list
import_all_data <- function(year_start, N_year, scenario, vax, regions,
                            year_per_age){
  ## Number of inhabitants per age group
  N <- import_pop_data(year_start)
  
  ## Create the neighbour matrix
  ref_d <- compute_region_matrix(regions)
  
  ## compute the number of births per year
  new_birth <- compute_n_birth(year_start, N_year)
  
  # Import vaccine coverage
  dt_vacc <- import_ehr_vaccine(vax, scenario)
  
  ## Compute contact matrix between age groups
  ref_m <- compute_contact_matrix(year_per_age = year_per_age)
  
  ## Compute number of importations per region / year
  mean_import_per_reg <- compute_importation(regions, N_age = nrow(N))
  
  ## Return a list containing all data
  list_data <- 
    list(
      ref_m = ref_m, ref_d = ref_d, new_birth = new_birth, 
      mean_import_per_reg = mean_import_per_reg, year_per_age = year_per_age, 
      dt_vacc = dt_vacc, N = N
    )
  return(list_data)
}
