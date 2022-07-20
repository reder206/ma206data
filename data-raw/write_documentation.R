

# Write 'docs' (minimal possible)

list.files(path = "data") %>%
  str_remove(".rda$") %>%
  paste0("'", .,"'") %>%
  writeLines("R/datasets_listed.R")
