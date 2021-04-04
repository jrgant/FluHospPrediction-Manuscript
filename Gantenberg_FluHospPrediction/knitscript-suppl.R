library(rmarkdown)

render(
  "FHP-Supplement.Rmd",
  output_format = "officedown::rdocx_document",
  output_options = list(
    reference_docx = "wordref-suppl.docx"
  )
)
