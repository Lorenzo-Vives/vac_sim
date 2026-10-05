## Compatibility helpers for seirvodin 1.0.

clean_mcmc_pars <- function(mcmc_pars){
  rename <- c(
    catchup = "catchup_10",
    catchup2 = "catchup2_7",
    recov11to15 = "recov_8",
    recov16to20 = "recov_9",
    recov21to30 = "recov_10",
    recov31to40 = "recov_11",
    recov40plus = "recov_12",
    v_70s = "v_11"
  )
  old_names <- colnames(mcmc_pars)
  matched <- old_names %in% names(rename)
  old_names[matched] <- unname(rename[old_names[matched]])
  colnames(mcmc_pars) <- old_names
  mcmc_pars
}

configure_windows_rtools <- function(){
  if(.Platform$OS.type != "windows" || nzchar(Sys.which("make"))) return(invisible(TRUE))

  candidates <- unique(c(
    Sys.getenv("RTOOLS45_HOME"),
    file.path(Sys.getenv("LOCALAPPDATA"), "rtools45"),
    "C:/rtools45"
  ))
  candidates <- candidates[nzchar(candidates)]
  for(root in candidates){
    make <- file.path(root, "usr", "bin", "make.exe")
    compiler <- file.path(root, "x86_64-w64-mingw32.static.posix", "bin")
    if(file.exists(make) && dir.exists(compiler)){
      Sys.setenv(RTOOLS45_HOME = root)
      Sys.setenv(
        PATH = paste(
          file.path(root, "usr", "bin"), compiler, Sys.getenv("PATH"),
          sep = .Platform$path.sep
        )
      )
      return(invisible(TRUE))
    }
  }
  stop(
    "A working Rtools 4.5 installation is required to compile the compatible ",
    "seirvodin model on Windows."
  )
}

compatible_seirv_age_region <- local({
  cached_model <- NULL

  function(verbose = TRUE){
    if(!is.null(cached_model)) return(cached_model)

    model_source <- system.file(
      "odin", "seirv_age_region.R", package = "seirvodin"
    )
    if(!nzchar(model_source)){
      stop("Cannot find the odin source installed with seirvodin")
    }

    model_code <- readLines(model_source, warn = FALSE)
    unsafe <- grep("i >= 1 && array_cov1", model_code, fixed = TRUE)

    if(length(unsafe) == 0L){
      if(verbose) message("Using the exported seirvodin model (no unsafe index found).")
      cached_model <<- seirvodin::seirv_age_region
      return(cached_model)
    }
    if(length(unsafe) != 2L){
      stop(
        "Unexpected seirvodin model source: expected two unsafe index expressions, found ",
        length(unsafe), ". Refusing to patch an unknown model version."
      )
    }

    configure_windows_rtools()

    ## In the first age group, i - 1 is outside the odin array.  Older builds
    ## could read adjacent memory; current Windows builds terminate R with
    ## 0xC0000005. The preceding model equation already defines this group as
    ## zero, so excluding i == 1 is the intended boundary condition.
    model_code[unsafe] <- sub(
      "i >= 1 && array_cov1", "i > 1 && array_cov1",
      model_code[unsafe], fixed = TRUE
    )

    patched_source <- tempfile("seirv_age_region_compat_", fileext = ".R")
    writeLines(model_code, patched_source)
    if(verbose){
      message("Compiling a temporary seirvodin model with the first-age index fix.")
    }
    cached_model <<- odin.dust::odin_dust(patched_source, verbose = FALSE)
    cached_model
  }
})
