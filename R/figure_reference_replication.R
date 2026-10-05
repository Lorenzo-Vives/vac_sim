## Recreate the reference-versus-surveillance figure from NEW simulations.
## Run only after R/replicate_reference.R.

args <- commandArgs(trailingOnly = TRUE)
replication_file <- if(length(args)) args[[1L]] else
  "Output/replication/reference_replication.rds"
figure_file <- if(length(args) >= 2L) args[[2L]] else
  "Output/replication/Reference_Surveillance_replication.png"

if(!file.exists(replication_file)){
  stop("Replication not found. Run R/replicate_reference.R first: ", replication_file)
}
if(!requireNamespace("ggplot2", quietly = TRUE)) stop("Package ggplot2 is required")

reference <- readRDS(replication_file)
case_rows <- grepl("^new_I", rownames(reference))
by_simulation_year <- apply(
  reference[case_rows, , , drop = FALSE], c(2, 3), sum
)
if(is.null(dim(by_simulation_year))){
  by_simulation_year <- matrix(by_simulation_year, nrow = dim(reference)[2])
}

years <- 2010 + seq_len(ncol(by_simulation_year)) - 1L
surveillance <- c(374, 1064, 1897, 1447, 104, 92, 522, 248, 964, 792)
summary <- do.call(rbind, lapply(seq_along(years), function(index){
  interval <- stats::quantile(
    by_simulation_year[, index], c(0.025, 0.25, 0.5, 0.75, 0.975),
    names = FALSE
  )
  data.frame(
    year = years[index], lower_95 = interval[1], lower_50 = interval[2],
    median = interval[3], upper_50 = interval[4], upper_95 = interval[5],
    surveillance = surveillance[index]
  )
}))

plot <- ggplot2::ggplot(summary, ggplot2::aes(x = year)) +
  ggplot2::geom_line(ggplot2::aes(y = median), color = "#2c5985") +
  ggplot2::geom_point(
    ggplot2::aes(y = surveillance), color = "darkgrey", size = 3
  ) +
  ggplot2::geom_ribbon(
    ggplot2::aes(ymin = lower_50, ymax = upper_50),
    fill = "#2c5985", alpha = 0.5
  ) +
  ggplot2::geom_ribbon(
    ggplot2::aes(ymin = lower_95, ymax = upper_95),
    fill = "#2c5985", alpha = 0.2
  ) +
  ggplot2::scale_x_continuous(breaks = c(2011, 2013, 2015, 2017, 2019)) +
  ggplot2::scale_y_continuous(breaks = seq(0, 4000, 500), limits = c(0, 4000)) +
  ggplot2::labs(x = "Year", y = "N measles cases") +
  ggplot2::theme_classic() +
  ggplot2::theme(
    legend.position = "bottom",
    axis.text.x = ggplot2::element_text(
      color = "grey20", size = 20, angle = 45, hjust = 0.5, vjust = 0.5
    ),
    axis.text.y = ggplot2::element_text(color = "grey20", size = 20),
    axis.title.x = ggplot2::element_text(color = "grey20", size = 22, face = "italic"),
    axis.title.y = ggplot2::element_text(color = "grey20", size = 22, face = "italic")
  )

dir.create(dirname(figure_file), recursive = TRUE, showWarnings = FALSE)
ggplot2::ggsave(
  figure_file, plot, width = 7, height = 6, bg = "white", dpi = 300
)
message("Saved figure based on NEW simulations to: ", figure_file)
