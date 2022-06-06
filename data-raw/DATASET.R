## code to prepare `DATASET` dataset goes here

AP.BottledWater = readr::read_csv("data-raw/AP.BottledWater.csv")

usethis::use_data(AP.BottledWater, overwrite = TRUE)

####################################################################




library(tidyverse)
# look at text of html file
readLines("http://www.isi-stats.com/isi/data.html") %>%
  # each line is content in data frame
  tibble(text = .) %>%
  filter(str_detect(text, "\\.txt")) %>%
  mutate(href =
           str_extract(text, "http.+\\.txt"),
         .before = 1) %>%
  mutate(dataset_name =
           str_extract(href, "\\w+\\.txt"),
         .before = 1) %>%
  mutate(dataset_name =
           str_remove(dataset_name, "\\.txt")) ->
  href_df

# a list that will populate with data
isi_datasets <- list()

# go through each row of href_df (which has .txt webaddresses)
for (i in 1:nrow(href_df)){

  # pause so you don't hit isi website too often
  Sys.sleep(time = .2)

  # attempt to harvest data
  tryCatch(


    href_df %>%
      .$href %>%
      .[i] %>%
      readr::read_delim(delim = "\t") %>%
      janitor::clean_names() ->
    isi_datasets[[i]]

  )

  assign(x = href_df$dataset_name[i], value = isi_datasets[[i]])


  save(list = href_df$dataset_name[i],
       file = paste0("data/",href_df$dataset_name[i], ".rda"))

  }



# Write docs

list.files(path = "data") %>%
  str_remove(".rda$") %>%
  paste0("'", .,"'") %>%
  writeLines("R/my_datasets_listed.R")


