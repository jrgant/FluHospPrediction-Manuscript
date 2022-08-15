main_allfiles: main main_docx2pdf

#supp_allfiles: supp supp_docx2pdf

main:
	Rscript -e "source('knitscript.R')"

supp:
	Rscript -e "source('knitscript-suppl.R')"

main_docx2pdf:
	soffice --convert-to pdf --headless FHP-Main-Document.docx

# supp_docx2pdf:
# 	soffice --convert-to pdf --headless FHP-Supplement.docx

coverpage:
	Rscript -e "source('knitscript-cover.R')"

coverpage-aje:
	Rscript -e "source('knitscript-cover-aje.R')"

omain:
	soffice FHP-Main-Document.docx

osupp:
	soffice FHP-Supplement.docx

ocover:
	soffice FHP-Cover-Page.docx
