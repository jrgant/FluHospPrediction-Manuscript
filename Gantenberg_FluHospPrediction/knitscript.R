library(rmarkdown)

knitr::opts_chunk$set(dpi = 300)
render(
  "FHP-Main-Document.Rmd",
  output_format = "officedown::rdocx_document",
  output_options = list(
    reference_docx = "wordref.docx",
    page_margins = list(
      top = 1,
      right = 1,
      bottom = 1,
      left = 1,
      gutter = 0,
      header = 0,
      footer = 0.5
    )
  )
)
