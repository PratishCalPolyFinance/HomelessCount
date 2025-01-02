# Clear the environment
rm(list = ls()) 

# List of required packages
list_of_packages <- c("janitor", "here", "tidyverse", "readr", "rvest",
                      "stringr", "tesseract", "pdftools", "openxlsx", "readxlsb",
                      "usmap", "gganimate", "extrafont", "ggstream", "sysfonts",
                      "camcorder")

# Install and load packages
for (package in list_of_packages) {
  if (!requireNamespace(package, quietly = TRUE)) {
    # If the package is not installed, install it
    install.packages(package)
  }
  # Load the package
  library(package, character.only = TRUE)
}
