# ====================================================================
# Title: Generate California CoC Report Links Function
# Description: This function processes a dataset containing California 
# Continuum of Care (CoC) locations to extract CoC codes and names. 
# It generates a list of URLs pointing to PDF reports for each CoC 
# based on a specified year.
# Author: Pratish Patel
# ====================================================================

# Function to generate CoC report links for a given year
generate_coc_report_links <- function(year) {
  
  # Validate input: ensure the year is a 4-digit numeric value
  if (!grepl("^\\d{4}$", year)) {
    stop("Error: Please provide a valid 4-digit year.")
  }
  
  # Convert year to character (in case it's numeric)
  year <- as.character(year)
  
  # Clear workspace before loading data
  rm(list = ls())  # Removes all objects from the workspace to ensure a clean environment
  
  # Load necessary packages
  source('Code/0-LoadPackages.R')  # Sources the script to load required packages
  
  # Load CoC location data
  # This CSV contains CoC codes and names for California
  CoCLocationRawFile <- read.csv(
    "https://data.ca.gov/dataset/d3f9ca4d-3e60-434b-9fa3-91ee0befd34d/resource/631c06ba-1ff9-4b69-88cc-7de2be6b3b50/download/fiscal-year-coc-and-statewide-topline-ca-spms.csv"
  )
  
  # Process the data to extract CoC codes and names
  CoCLocation <- CoCLocationRawFile %>%
    select(Location) %>%                          # Select only the Location column
    filter(str_detect(Location, "CoC")) %>%       # Keep rows that contain "CoC"
    mutate(
      CoC_Code = str_extract(Location, "CA-\\d+"), # Extract CoC code (e.g., "CA-500")
      CoC_Name = str_remove(Location, "CA-\\d+\\s") # Extract the descriptive name
    ) %>%
    select(CoC_Code, CoC_Name)                    # Retain only the CoC code and name columns
  
  # Generate URLs for PDF reports based on CoC codes and input year
  base_url <- "https://files.hudexchange.info/reports/published/CoC_PopSub_CoC_"
  CoCLocation <- CoCLocation %>%
    mutate(
      ReportLink = map(CoC_Code, ~ paste0(base_url, .x, "-", year, "_CA_", year, ".pdf")) %>% unlist()
    )
  
  # Return the processed data frame
  return(CoCLocation)
}

# Example usage:
# result <- generate_coc_report_links(2022)
# print(result)
