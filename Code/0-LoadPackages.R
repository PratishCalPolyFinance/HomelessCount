# Load the required packages

list_of_packages <- c("janitor", "here", "tidyverse", "readr", "rvest",
                      "stringr","tesseract","pdftools","openxlsx")
lapply(list_of_packages, library, character.only = TRUE)