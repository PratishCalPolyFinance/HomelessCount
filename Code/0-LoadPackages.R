# Load the required packages

rm(list = ls()) 

list_of_packages <- c("janitor", "here", "tidyverse", "readr", "rvest",
                      "stringr","tesseract","pdftools","openxlsx", "readxlsb",
                      "usmap","gganimate","extrafonts")
lapply(list_of_packages, library, character.only = TRUE)