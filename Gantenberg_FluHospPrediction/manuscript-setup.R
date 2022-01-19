pacman::p_load(
  FluHospPrediction,
  ggplot2,
  ggthemes,
  gridExtra,
  data.table,
  tidyverse,
  kableExtra,
  knitr,
  flextable,
  officedown
)

opts_chunk$set(
  echo = FALSE,
  cache = FALSE,
  tab.cap.style = "Table Caption",
  tab.cap.pre = "Table ",
  tab.cap.sep = ": ",
  fig.cap.style = "Image Caption",
  fig.cap.pre = "Figure ",
  fig.cap.sep = ": ",
  fig.width = 6.5,
  reference_num = FALSE
)

# paper output directory
assetdir <-
  "/mnt/HDD/projects/FluHospPrediction/results/00_paper_output/"

# table font
global_table_font <- "Times New Roman"

# function to get a set of files based on their creation date
global_date <- "2021-06-07"     # set accordingly

get_asset <- function(type, descr, date = global_date) {

  if (!type %in% c("FIG", "TAB", "VAL")) stop("Invalid asset type.")

  if (type == "FIG") {
    ext <- "png"
  } else if (type == "TAB") {
    ext <- "csv"
  } else {
    ext <- "Rds"
  }

  file.path(assetdir, paste0(type, "_", descr, "_", date, ".", ext))
}

# results objects
prop_weeks_transformed <- readRDS(
  get_asset("VAL", "Proportion-Weeks-Transformed")
)

# Set up supplemental material numbering/labeling

## This function makes a caption for the component prediction risk
## distribution tables in the supplement.
rttab_cap <- function(target, analysis, component = FALSE) {
  rateslug <- "hospitalization rate per 100,000 population"
  texts <- c(
    "Peak rate" = paste("peak", rateslug),
    "Peak week" = "peak week",
    "Cumulative rate" = paste("cumulative", rateslug))
  t <- match(target, names(texts))

  if (component) {
  paste0(
    "Weekly risks across all component learners used to predict ", texts[t], " (", analysis, " analysis). Estimates presented as summary statistics across cross-validation folds. SD, standard deviation."
  )
  } else {
    paste0("Prediction risks for the ensemble and discrete super learner predictions of ", texts[t], ", by week of influenza season (", analysis, " analysis). Estimates presented as mean (standard error). The risks presented for the discrete super learner are cross-validated, while risks for the ensemble super learner are estimated in the full dataset. Consequently, risks for the ensemble may be optimistic.")
  }
}

# This function makes the footnote for a prediction risk table.
risktabfn <- function(target, sqe = FALSE) {
  texts <- c(
    "Peak rate" = "peak hospitalization rate",
    "Peak week" = "week in which the peak hospitalization rate occurred",
    "Cumulative rate" = "cumulative hospitalization rate"
  )

  paste(
    "The ensemble super learner (EnsembleSL) is the prediction generated as a weighted combination of component model predictions. The discrete super learner (DiscreteSL) is the best-performing component model. The super learner was optimized to minimize the",
    ifelse(sqe, "squared error loss", "absolute error loss"),
    "and, hence, the prediction error for the",
    ifelse(sqe, "mean", "median"),
    ifelse(
      length(target) == 1,
      paste0(texts[names(texts) == target], "."),
      paste0(
        texts[1], " (peak rate), the ",
        texts[2], " (peak week), and the ",
        texts[3], " (cumulative rate).")
    ),
    "The risks presented for the discrete super learner are cross-validated, while risks for the ensemble super learner are estimated in the full dataset. Consequently, risks for the ensemble may be optimistic."
  )
}


## This function makes a caption for the risktile figures in the supplement.
rtfig_cap <- function(target, analysis) {
  paste0(
    target, ", ",
    "ensemble learner weights as a function of log mean cross-validated risk ",
    "(", analysis, " analysis). Ensemble learner weights are assigned by regressing the prediction target on corresponding predictions made by each component learner. The coefficients estimated for each independent predictor (i.e., component learner) represent the weight given to the learner's predictions in the final ensemble super learner prediction, as assigned by the metalearner."
  )
}

## slugs for various analyses
mainslug <- "main"
lseslug <- "alternate trend filter penalty"
erfslug <- "component learner subset"
sqeslug <- "squared error loss"

## Function to make labels for the two trend filter fit plots.
tf_cap <- function(analysis) {
  paste0(
    "Linear trend filter fits to observed influenza hospitalization curves using the ",
    ifelse(analysis == "main", "$\\lambda_{min}$", "$\\lambda_{SE}$"),
    " penalty (", ifelse(analysis == "main", mainslug, lseslug), " analysis)."
    )
}


supp <- data.table(
  type = c(
    ## Main analysis
    "Figure", "Table", "Figure",
    "Table", "Table", "Table",
    "Figure", "Figure", "Figure",
    ## Alternate trend filter penalty
    "Figure", "Table", "Table", "Table", "Figure", "Figure", "Figure",
    ## Component learner subset
    "Table", "Table", "Table", "Figure", "Figure", "Figure",
    ## Squared error loss
    "Table", "Table", "Table", "Figure", "Figure", "Figure", "Figure"
  ),
  file = c(
    ## Main analysis
    "TF-Predictions_lambda.min",
    "Simulation-Template-Counts",
    "Simulation-Curves-by-Template-Rand10",
    "Risk-Week_Peak-Rate",
    "Risk-Week_Peak-Week",
    "Risk-Week_Cum-Hosp",
    "Risktiles_Peak-Rate",
    "Risktiles_Peak-Week",
    "Risktiles_Cum-Hosp",
    ## Alternate trend filter penalty
    "TF-Predictions_lambda.1se",
    "Risks-EDSL-Mean_PeakRate-L1SE",
    "Risks-EDSL-Mean_PeakWeek-L1SE",
    "Risks-EDSL-Mean_CumHosp-L1SE",
    "Risktiles_Peak-Rate-L1SE",
    "Risktiles_Peak-Week-L1SE",
    "Risktiles_Cum-Hosp-L1SE",
    ## Component learner subset
    "Risks-EDSL-Mean_PeakRate-ERF",
    "Risks-EDSL-Mean_PeakWeek-ERF",
    "Risks-EDSL-Mean_CumHosp-ERF",
    "Risktiles_Peak-Rate-ERF",
    "Risktiles_Peak-Week-ERF",
    "Risktiles_Cum-Hosp-ERF",
    ## Squared error loss
    "Risks-EDSL-Mean_PeakRate-SQE",
    "Risks-EDSL-Mean_PeakWeek-SQE",
    "Risks-EDSL-Mean_CumHosp-SQE",
    "Ensemble-Summary_All-Targets-SQE",
    "Risktiles_Peak-Rate-SQE",
    "Risktiles_Peak-Week-SQE",
    "Risktiles_Cum-Hosp-SQE"
  ),
  cap = c(
    ## Main analysis
    tf_cap("main"),
    "Number of simulated curves based on each empirical shape template (Emerging Infections Program).",
    "**Ten random simulated hospitalization curves, by empirical shape template.** All simulated curves were based on linear trend filter fits using the $\\lambda_{min}$ trend filter penalty. Note that because each parameter used in the curve-generating function was drawn independently, simulated hospitalization curves based on an empirical shape template should have a similar shape (i.e., unimodal, bimodal) but may have different peak and/or cumulative hospitalization rates compared to the empirical template. Empirical data source: CDC, Emerging Infections Program (omitting 2009--2010 pandemic influenza season).",
    rttab_cap("Peak rate", mainslug, component = TRUE),
    rttab_cap("Peak week", mainslug, component = TRUE),
    rttab_cap("Cumulative rate", mainslug, component = TRUE),
    rtfig_cap("Peak rate", mainslug),
    rtfig_cap("Peak week", mainslug),
    rtfig_cap("Cumulative rate", mainslug),
    ## Alternate trend filter sensitivity
    tf_cap("lse"),
    rttab_cap("Peak rate", lseslug),
    rttab_cap("Peak week", lseslug),
    rttab_cap("Cumulative rate", lseslug),
    rtfig_cap("Peak rate", lseslug),
    rtfig_cap("Peak week", lseslug),
    rtfig_cap("Cumulative rate", lseslug),
    ## Component learner subset sensitivity
    rttab_cap("Peak rate", erfslug),
    rttab_cap("Peak week", erfslug),
    rttab_cap("Cumulative rate", erfslug),
    rtfig_cap("Peak rate", erfslug),
    rtfig_cap("Peak week", erfslug),
    rtfig_cap("Cumulative rate", erfslug),
    ## Squared error loss sensitivity
    rttab_cap("Peak rate", sqeslug),
    rttab_cap("Peak week", sqeslug),
    rttab_cap("Cumulative rate", sqeslug),
    "Ensemble, component learner, and naive mean prediction risks by week of simulated flu season and prediction target (squared error sensitivity analysis). Learners assigned zero weights by the metalearner are omitted. The risks presented for the discrete super learner are cross-validated, while risks for the ensemble super learner are estimated in the full dataset. Consequently, risks for the ensemble may be optimistic. Week 30 omitted from cumulative hospitalization rate to avoid distorting the y-axis; the true cumulative hospitalization rates are known to the algorithm at this point in the season.",
    rtfig_cap("Peak rate", sqeslug),
    rtfig_cap("Peak week", sqeslug),
    rtfig_cap("Cumulative rate", sqeslug)
  )
)

supp[, number := .I]
supp

## A function to output a supplemental material caption
## as Markdown markup.
supp_cap <- function(fileslug) {
  info <- supp[file == fileslug]
  cat(info[, paste0("Supplemental Item ", number, ", ", type, ". ", cap)])
}

## A function to output the risk tables.
risktab_cnames_word <- function(dat) {
  set_header_labels(
    dat,
    Week = "Week",
    SuperLearner = "EnsembleSL",
    BestComponent = "DiscreteSL"
  )
}

## This function retrieves risks from formatted risk tables and converts
## them to numeric vectors for reporting within the text.
get_risks <- function(data, variable) {
  data[[variable]] %>%
    stringr::str_extract("[0-9]*.\\.[0-9]{1,2}") %>%
    as.numeric
}

pkrate_risks <- fread(get_asset("TAB", "Risks-EDSL-Mean_PeakRate"))
presl_num <- get_risks(pkrate_risks, "SuperLearner")
prdsl_num <- get_risks(pkrate_risks, "DiscreteSL")

pkweek_risks <- fread(get_asset("TAB", "Risks-EDSL-Mean_PeakWeek"))
pwesl_num <- get_risks(pkweek_risks, "SuperLearner")
pwdsl_num <- get_risks(pkweek_risks, "DiscreteSL")

cumhosp_risks <- fread(get_asset("TAB", "Risks-EDSL-Mean_CumHosp"))
chesl_num <- get_risks(cumhosp_risks, "SuperLearner")
chdsl_num <- get_risks(cumhosp_risks, "DiscreteSL")

prw_risks <- merge(pkrate_risks, pkweek_risks, by = "Week")
prwc_risks <- merge(prw_risks, cumhosp_risks, by = "Week")
