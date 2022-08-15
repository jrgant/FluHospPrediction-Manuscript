library(rmarkdown)

render(
  "FHP-Cover-Page-AJE.Rmd",
  output_format = "officedown::rdocx_document",
  output_options = list(
    reference_docx = "wordref-coverpage-aje.docx"
  )
)
