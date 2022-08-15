library(rmarkdown)

## render(
##   "FHP-Supplement.Rmd",
##   output_format = "officedown::rdocx_document",
##   output_options = list(
##     reference_docx = "wordref-suppl.docx",
##     number_sections = FALSE
##   )
## )

flextable::set_flextable_defaults(fonts_ignore = TRUE)
knitr::opts_chunk$set(fig.align = "center", out.width = "100%")

rmarkdown::render("FHP-Supplement.Rmd",
                  output_format = "pdf_document",
                  output_options = list(keep_tex = TRUE))
