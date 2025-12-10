
FROM --platform=linux/amd64 rocker/verse:4.4.1

WORKDIR /home/rstudio/project

COPY . .

RUN R -e "install.packages('renv', repos = 'https://cloud.r-project.org'); renv::restore()"

RUN mkdir -p /home/rstudio/project/report

ENTRYPOINT ["R", "-e", "rmarkdown::render('report.Rmd', output_dir = 'report')"]
