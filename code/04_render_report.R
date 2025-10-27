rmarkdown::render(
  input         = "data550_final.Rmd",
  output_format = "all",
  output_dir    = ".",   # <-- save to base project directory
  clean         = TRUE,
  envir         = new.env(parent = globalenv()),
  encoding      = "UTF-8"
)
