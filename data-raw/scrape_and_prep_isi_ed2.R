## code to prepare `DATASET` dataset goes here
#
# AP.BottledWater = readr::read_csv("data-raw/AP.BottledWater.csv")
#
# usethis::use_data(AP.BottledWater, overwrite = TRUE)

####################################################################


library(tidyverse)
# look at text of html file
readLines("http://www.isi-stats.com/isi2nd/data.html") %>%
  # each line is content in data frame
  tibble(text = .) %>%
  filter(str_detect(text, "\\.txt")) %>%
  mutate(href =
           str_extract(text, "http.+\\.txt"),
         .before = 1) %>%
  mutate(dataset_name = str_extract(href, "data.+"),
         .before = 1) %>%
  mutate(dataset_name =
           str_remove(dataset_name, "data."),
         .before = 1) %>%
  mutate(dataset_name =
           str_remove(dataset_name, "\\.txt")) %>%
  mutate(dataset_name =
           str_replace(dataset_name, "\\/", "_")) ->
  href_df

href_df$dataset_name


## Download raw data .txt files in isi folder in data-raw
isi_dir <- "data-raw/isi_txt_data/"
dir.create(isi_dir)

for (i in 1:length(href_df$href)){

  Sys.sleep(time = 1)
  try(
  download.file(url = href_df$href[i],
                destfile = paste0(isi_dir, href_df$dataset_name[i], ".txt"))
  )
}

# clean a bit and convert to .rda files, send to package data folder

isi_file_paths <- fs::dir_ls("data-raw/isi_txt_data/")
length(isi_file_paths)

dataset_name <- isi_file_paths %>%
  str_remove("data-raw/isi_txt_data/") %>%
  str_remove(".txt$")

## a list that populates with datasets
isi_datasets <- list()


for (i in 1:length(isi_file_paths)){


  # pause so you don't hit isi website too often
  Sys.sleep(time = .2)

  # attempt to harvest data
  tryCatch(

    isi_file_paths[i] %>%
      readr::read_delim(delim = "\t") %>%
      janitor::clean_names() ->
    isi_datasets[[i]]

  )

  assign(x = dataset_name[i], value = isi_datasets[[i]])

  save(list = dataset_name[i],
       file = paste0("data/", dataset_name[i], ".rda"))

  }
