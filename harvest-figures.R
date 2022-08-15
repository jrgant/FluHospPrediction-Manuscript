## Load libraries
library(data.table)
library(magrittr)
library(stringr)

## Get asset directory and save to environment
setuplines <- readLines("manuscript-setup.R")
eval(parse(text = setuplines[which(setuplines %like% "^assetdir")]))
assetdir

## Match figure files to their number in the manuscript
figs <- data.table(
  Figure = 1:5,
  Slug = c(
    "Simulation-Curves-by-Template-Boxplot",
    "TargetDists-Emp-vs-Sim",
    "Ensemble-Summary_All-Targets(_[0-9]|\\-Panel)",
    "Ensemble-Summary_All-Targets_Regular-Scale",
    "Prospective-Observed-Application"
  ),
  File = c(
    rep("06.2_tables-figures-simul.R", 2),
    "06.3_tables-figures-main.R",
    "06.7_tables-figures-sens-comb.R",
    "09_tables-figures-sub-prosp-obs.R"
  )
)

## Get full filenames in assetdir
fntab <- lapply(seq_len(nrow(figs)), function(x) {
  lf <- list.files(assetdir, pattern = figs[x, Slug])
  lf <- lf[!lf %like% "png" & !lf %like% "Panel.*pdf"]
  data.table(files = lf, fignum = figs[x, Figure])
}) %>% rbindlist

## Make new filenames
fnslug <- paste("AJE-01433-2020", "Gantenberg", "Figure")
fntab[, newname := fcase(
  # combined figures
  !files %like% "Panel",
  paste0(paste(fnslug, fignum), ".", str_extract(files, "[a-z]{3}$")),
  # panels
  files %like% "Panel",
  paste(fnslug, paste0(fignum,
                       str_extract(files, "(?<=Panel\\-)[A-Z]"), ".",
                       str_extract(files, "[a-z]{3}$")))
)][]

## Check to make sure the only files included match file date selected
## in manuscript-setup.R
eval(parse(text = setuplines[which(setuplines %like% "^global_date")]))
fntab[, good_date :=
          str_extract(files, "[0-9]{4}\\-[0-9]{2}\\-[0-9]{2}") == global_date]

bad_date_bool <- fntab[, any(good_date == FALSE)]
cat("Any bad dates?", bad_date_bool, "\n", sep = " ")
if (bad_date_bool == TRUE) stop("Bad file dates are present.")

dupfiles_bool <- fntab[, .N, newname][, any(N > 1)]
cat("Any duplicates?", dupfiles_bool, "\n", sep = " ")
if (dupfiles_bool == TRUE) stop("Duplicate files are present.")

## Copy figures into this manuscript directory
if (!dir.exists("figures")) dir.create("figures")
fntab[, file.copy(from = file.path(assetdir, files),
                  to = file.path("figures", newname))]

list.files("figures")
