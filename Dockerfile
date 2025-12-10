FROM rocker/tidyverse:4.4.1

WORKDIR /home/rstudio/project

RUN mkdir -p code outputs raw_data report renv

COPY code/ code/
COPY raw_data/ raw_data/

COPY Makefile .
COPY report.Rmd .

COPY .Rprofile .
COPY renv.lock .
COPY renv/activate.R renv/

RUN R -e "install.packages('renv', repos = 'https://cloud.r-project.org'); renv::restore(prompt = FALSE)"

ENTRYPOINT ["R", "-e", "rmarkdown::render('report.Rmd', output_dir = 'report')"]
