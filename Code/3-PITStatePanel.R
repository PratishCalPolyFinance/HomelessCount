# Purpose: Load and process homelessness data from the PIT counts file for all years,
#          filtering out non-state entries and preparing for analysis.

# Load necessary packages
source('Code/0-LoadPackages.R')

# Load sheet names from the Excel file to identify years
year_list <- openxlsx::getSheetNames('Code/2007-2023-PIT-Counts-by-State.xlsx') %>%
  as.data.frame() %>%
  filter(nchar(.) == 4) # Ensure only valid 4-digit years are included
names(year_list)[1] <- "year"

year_list <- year_list %>%
              filter(!(year %in% c("2010","2009","2008","2007"))) # Get data after 2010

# Initialize an empty data frame to store results
final_data <- data.frame()

# Loop through each year in the year list
for (i in seq_len(nrow(year_list))) {
  # Select the current year
  current_year <- year_list$year[i]
  
  # Load raw data for the selected year
  raw_data <- openxlsx::read.xlsx('Code/2007-2023-PIT-Counts-by-State.xlsx',
                                  sheet = current_year)
  
  # Clean and process the raw data
  cleaned_data <- raw_data %>%
    select(matches('Chronically|Overall|State')) %>% # Select relevant columns
    janitor::clean_names()                           # Standardize column names
  
  # Filter and process the data
  filtered_data <- cleaned_data %>%
    select(state, overall_homeless, 
           overall_chronically_homeless, 
           sheltered_total_chronically_homeless) %>% # Keep key metrics
    drop_na() %>%                                   # Remove rows with missing values
    filter(!(state %in% c("AS", "DC", "GU", "MP", "PR", "VI"))) %>% # Exclude non-state entries
    mutate(year = current_year)                     # Add the current year as a new column
  
  # Append the processed data to the final data frame
  final_data <- bind_rows(final_data, filtered_data)
}

