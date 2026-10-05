## Compare a newly generated reference simulation set with the repository copy.
## Run only after R/replicate_reference.R.

args <- commandArgs(trailingOnly = TRUE)
replication_file <- if(length(args)) args[[1L]] else
  "Output/replication/reference_replication.rds"
original_file <- "Output/models/reference.rda"

if(!file.exists(replication_file)){
  stop("Replication not found. Run R/replicate_reference.R first: ", replication_file)
}
if(!file.exists(original_file)) stop("Original comparison file not found: ", original_file)

replication <- readRDS(replication_file)
original <- readRDS(original_file)

validate_output <- function(x, label){
  if(!is.array(x) || length(dim(x)) != 3L){
    stop(label, " must be a three-dimensional array")
  }
  if(is.null(rownames(x)) || !any(grepl("^new_I", rownames(x)))){
    stop(label, " has no named new-infection rows")
  }
}
validate_output(replication, "replication")
validate_output(original, "original")

summarise_total <- function(x, dataset){
  cases <- x[grepl("^new_I", rownames(x)), , , drop = FALSE]
  totals <- apply(cases, 2, sum)
  probabilities <- c(0, 0.025, 0.25, 0.5, 0.75, 0.975, 1)
  values <- stats::quantile(totals, probabilities, names = FALSE)
  data.frame(
    dataset = dataset,
    n_simulations = dim(x)[2],
    minimum = values[1],
    lower_95 = values[2],
    q1 = values[3],
    median = values[4],
    q3 = values[5],
    upper_95 = values[6],
    maximum = values[7]
  )
}

summarise_year <- function(x, dataset){
  cases <- x[grepl("^new_I", rownames(x)), , , drop = FALSE]
  by_simulation_year <- apply(cases, c(2, 3), sum)
  if(is.null(dim(by_simulation_year))){
    by_simulation_year <- matrix(by_simulation_year, nrow = dim(x)[2])
  }
  years <- 2010 + seq_len(ncol(by_simulation_year)) - 1L
  result <- lapply(seq_along(years), function(index){
    values <- stats::quantile(
      by_simulation_year[, index], c(0.025, 0.25, 0.5, 0.75, 0.975),
      names = FALSE
    )
    data.frame(
      dataset = dataset, year = years[index], lower_95 = values[1],
      q1 = values[2], median = values[3], q3 = values[4], upper_95 = values[5]
    )
  })
  do.call(rbind, result)
}

structure_comparison <- data.frame(
  dataset = c("new_replication", "repository_original"),
  class = c(paste(class(replication), collapse = "/"), paste(class(original), collapse = "/")),
  n_strata = c(dim(replication)[1], dim(original)[1]),
  n_simulations = c(dim(replication)[2], dim(original)[2]),
  n_years = c(dim(replication)[3], dim(original)[3]),
  same_stratum_names = c(
    identical(rownames(replication), rownames(original)),
    identical(rownames(replication), rownames(original))
  )
)
overall_comparison <- rbind(
  summarise_total(replication, "new_replication"),
  summarise_total(original, "repository_original")
)
yearly_comparison <- rbind(
  summarise_year(replication, "new_replication"),
  summarise_year(original, "repository_original")
)

metadata_file <- sub("[.]rds$", "_metadata.rds", replication_file, ignore.case = TRUE)
matched_trajectories <- NULL
if(file.exists(metadata_file)){
  metadata <- readRDS(metadata_file)
  original_n_samples <- 100L
  original_n_part <- 25L
  posterior_rows_after_burnin <- 15000L
  new_parameter_rows <- seq(
    1, posterior_rows_after_burnin,
    posterior_rows_after_burnin / metadata$n_samples
  )
  original_parameter_rows <- seq(
    1, posterior_rows_after_burnin,
    posterior_rows_after_burnin / original_n_samples
  )

  comparisons <- list()
  counter <- 0L
  for(new_sample in seq_along(new_parameter_rows)){
    original_sample <- match(new_parameter_rows[new_sample], original_parameter_rows)
    if(!is.na(original_sample)){
      for(particle in seq_len(min(metadata$n_part, original_n_part))){
        counter <- counter + 1L
        new_column <- (new_sample - 1L) * metadata$n_part + particle
        original_column <- (original_sample - 1L) * original_n_part + particle
        comparisons[[counter]] <- data.frame(
          posterior_row_after_burnin = new_parameter_rows[new_sample],
          new_column = new_column,
          original_column = original_column,
          identical = identical(
            replication[, new_column, ], original[, original_column, ]
          ),
          max_absolute_difference = max(abs(
            replication[, new_column, ] - original[, original_column, ]
          ))
        )
      }
    }
  }
  if(length(comparisons)) matched_trajectories <- do.call(rbind, comparisons)
}

output_dir <- dirname(replication_file)
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
utils::write.csv(
  structure_comparison, file.path(output_dir, "reference_structure_comparison.csv"),
  row.names = FALSE
)
utils::write.csv(
  overall_comparison, file.path(output_dir, "reference_total_cases_comparison.csv"),
  row.names = FALSE
)
utils::write.csv(
  yearly_comparison, file.path(output_dir, "reference_yearly_cases_comparison.csv"),
  row.names = FALSE
)
if(!is.null(matched_trajectories)){
  utils::write.csv(
    matched_trajectories,
    file.path(output_dir, "reference_matched_trajectories.csv"),
    row.names = FALSE
  )
}

print(structure_comparison)
print(overall_comparison)
print(yearly_comparison)
if(!is.null(matched_trajectories)){
  message("Matched trajectories: ", nrow(matched_trajectories))
  message("All matched trajectories identical: ",
          all(matched_trajectories$identical))
  message("Maximum absolute difference: ",
          max(matched_trajectories$max_absolute_difference))
}
