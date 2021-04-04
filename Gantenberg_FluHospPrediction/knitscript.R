library(rmarkdown)

render(
  "FHP-Main-Document.Rmd",
  output_format = "officedown::rdocx_document",
  output_options = list(
    reference_docx = "wordref.docx"
  )
)
