# knitters
main_allfiles: main main_docx2pdf

main:
	Rscript-4.2.2 -e "source('knitscript.R')"

supp:
	Rscript-4.2.2 -e "source('knitscript-suppl.R')"

main_docx2pdf:
	soffice --convert-to pdf --headless FHP-Main-Document.docx

coverpage-aje:
	Rscript-4.2.2 -e "source('knitscript-cover-aje.R')"

# openers
omain:
	soffice FHP-Main-Document.docx

osupp:
	soffice FHP-Supplement.docx

ocover:
	soffice FHP-Cover-Page.docx
