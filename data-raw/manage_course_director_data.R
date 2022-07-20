

library(tidyverse)
# look at text of html file

# csvs were
fs::dir_ls(path = "data-raw/course_director_data/") ->
  course_director_csvs

# clean a bit and convert to .rda files, send to package data folder


dataset_name <- course_director_csvs %>%
  str_remove("data-raw/course_director_data/") %>%
  str_remove(".csv$")

## a list that populates with datasets
course_director_datasets <- list()


for (i in 1:length(course_director_csvs)){


  # attempt to harvest data
  tryCatch(

    course_director_csvs[i] %>%
      readr::read_csv() %>%
      janitor::clean_names() ->
    course_director_datasets[[i]]

  )

  assign(x = dataset_name[i], value = course_director_datasets[[i]])

  save(list = dataset_name[i],
       file = paste0("data/", dataset_name[i], ".rda"))

  }



# Write 'docs' (minimal possible)

list.files(path = "data") %>%
  str_remove(".rda$") %>%
  paste0("'", .,"'") %>%
  writeLines("R/my_course_director_datasets_listed.R")
