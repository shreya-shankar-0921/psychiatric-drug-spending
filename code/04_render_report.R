rmarkdown::render(
  input         = "report.Rmd",
  output_format = "all",
  output_dir    = "report",   
  clean         = TRUE,
  envir         = new.env(parent = globalenv()),
  encoding      = "UTF-8"
)
