## Re-run the CPRD/no-waning reference scenario from public derived inputs.
##
## Quick test (4 simulations):
##   Rscript R/replicate_reference.R
## Full paper settings (2,500 simulations):
##   Rscript R/replicate_reference.R --full
## Optional overrides:
##   --n-samples=10 --n-part=5 --output=Output/replication/custom.rds

find_project_root <- function(){
  current <- normalizePath(getwd(), winslash = "/", mustWork = TRUE)
  if(file.exists(file.path(current, "R", "function_vaccination_data.R"))){
    return(current)
  }

  command <- commandArgs(trailingOnly = FALSE)
  file_arg <- grep("^--file=", command, value = TRUE)
  if(length(file_arg) == 1L){
    script <- normalizePath(sub("^--file=", "", file_arg), winslash = "/")
    candidate <- dirname(dirname(script))
    if(file.exists(file.path(candidate, "R", "function_vaccination_data.R"))){
      return(candidate)
    }
  }
  stop("Run this script from the repository root or with Rscript R/replicate_reference.R")
}

parse_replication_args <- function(args){
  full <- "--full" %in% args
  value <- function(prefix, default){
    hit <- grep(paste0("^", prefix), args, value = TRUE)
    if(length(hit) > 1L) stop("Argument supplied more than once: ", prefix)
    if(length(hit) == 0L) return(default)
    sub(paste0("^", prefix), "", hit)
  }

  n_samples <- as.integer(value("--n-samples=", if(full) 100L else 2L))
  n_part <- as.integer(value("--n-part=", if(full) 25L else 2L))
  output <- value(
    "--output=", "Output/replication/reference_replication.rds"
  )
  if(is.na(n_samples) || is.na(n_part) || n_samples < 2L || n_part < 2L){
    stop("n_samples and n_part must both be integers >= 2 for seirvodin 1.0")
  }
  list(n_samples = n_samples, n_part = n_part, output = output, full = full)
}

project_root <- find_project_root()
setwd(project_root)
config <- parse_replication_args(commandArgs(trailingOnly = TRUE))

required_packages <- c(
  "seirvodin", "dplyr", "socialmixr", "odin.dust", "mcstate", "tidyr",
  "data.table"
)
missing_packages <- required_packages[
  !vapply(required_packages, requireNamespace, logical(1), quietly = TRUE)
]
if(length(missing_packages)){
  stop("Missing required packages: ", paste(missing_packages, collapse = ", "))
}

suppressPackageStartupMessages({
  library(seirvodin)
  library(dplyr)
  library(socialmixr)
  library(odin.dust)
  library(mcstate)
  library(tidyr)
  library(data.table)
})

source("R/function_vaccination_data.R")
source("R/function_model_compatibility.R")

required_files <- c(
  "Data/regional_population.csv",
  "Data/Coverage_reg_year_orig_extrapol.csv",
  "Data/risk_assessment_ukhsa.csv",
  "Output/cprd_degree/no.RDS"
)
missing_files <- required_files[!file.exists(required_files)]
if(length(missing_files)){
  stop("Missing required public inputs: ", paste(missing_files, collapse = ", "))
}

create_reference_scenario <- function(n_samples, n_part, burnin = 5000L){
  year_start <- 2010L
  n_year <- 10L
  year_per_age <- c(1, 1, 1, 1, 1, 1, 4, 5, 5, 10, 10, 40)
  regions <- c(
    "North East", "North West", "Yorkshire and The Humber", "East Midlands",
    "West Midlands", "East", "London", "South East", "South West"
  )

  all_data <- import_all_data(
    year_start = year_start, N_year = n_year, scenario = "reference",
    vax = "cprd", regions = regions, year_per_age = year_per_age
  )
  all_specs <- seirvodin::specs_simulations(
    year_start = year_start, N_year = n_year, waning = "no",
    burnin = burnin, n_samples = n_samples, nowane = FALSE,
    deterministic = FALSE
  )

  pmcmc_run <- readRDS("Output/cprd_degree/no.RDS")
  pmcmc_run$pars <- clean_mcmc_pars(pmcmc_run$pars)

  seirvodin::generate_outbreaks(
    model_run = pmcmc_run,
    model = compatible_seirv_age_region(),
    list_specs = all_specs,
    list_data = all_data,
    n_part = n_part,
    verbose = TRUE,
    aggreg_year = TRUE
  )
}

set.seed(1)
message(
  "Running reference scenario: ", config$n_samples, " parameter samples x ",
  config$n_part, " particles = ", config$n_samples * config$n_part,
  " simulations."
)
elapsed <- system.time({
  reference_replication <- create_reference_scenario(
    n_samples = config$n_samples, n_part = config$n_part
  )
})

dir.create(dirname(config$output), recursive = TRUE, showWarnings = FALSE)
saveRDS(reference_replication, config$output)

metadata <- list(
  created_at = format(Sys.time(), tz = "UTC", usetz = TRUE),
  seed = 1L,
  scenario = "reference",
  fit = "Output/cprd_degree/no.RDS",
  coverage = "Data/Coverage_reg_year_orig_extrapol.csv",
  n_samples = config$n_samples,
  n_part = config$n_part,
  n_simulations = config$n_samples * config$n_part,
  dimensions = dim(reference_replication),
  elapsed = elapsed,
  package_versions = vapply(
    required_packages, function(package) as.character(packageVersion(package)),
    character(1)
  ),
  seirvodin_remote_sha = packageDescription("seirvodin")[["RemoteSha"]],
  session_info = capture.output(utils::sessionInfo())
)
metadata_file <- sub("[.]rds$", "_metadata.rds", config$output, ignore.case = TRUE)
saveRDS(metadata, metadata_file)

case_rows <- grepl("^new_I", rownames(reference_replication))
totals <- apply(reference_replication[case_rows, , , drop = FALSE], 2, sum)
message("Saved new simulations to: ", config$output)
message("Dimensions: ", paste(dim(reference_replication), collapse = " x "))
message(
  "Total cases (min / median / max): ", min(totals), " / ",
  stats::median(totals), " / ", max(totals)
)
message("Metadata: ", metadata_file)
