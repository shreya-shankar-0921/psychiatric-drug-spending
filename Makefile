
data550_final.html: code/04_render_report.R data550_final.Rmd analyses
	Rscript code/04_render_report.R

outputs/00_clean_data.rds: code/00_clean_data.R raw_data/drugspending_data.csv
	Rscript code/00_clean_data.R
	
outputs/table1.rds: code/01_make_table1.R outputs/00_clean_data.rds
	Rscript code/01_make_table1.R
	
outputs/figure1.png: code/02_make_figure.R outputs/00_clean_data.rds
	Rscript code/02_make_figure.R
	
PHONY: clean
clean:
	rm outputs/*
	
PHONY: analyses
analyses: outputs/00_clean_data.rds outputs/table1.rds outputs/figure1.png
