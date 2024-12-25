# ====================================================================
# Title: Extract and Process Homeless Data from 2023 PDF Reports
# Description:
#   This script processes the 'Report_2023' dataset to extract various
#   homelessness-related data points from PDF reports, including:
#     - Total Homeless Households
#     - Chronically Homeless Persons
#     - Severely Mentally Ill
#     - Chronic Substance Abuse
#     - Veterans
#     - Victims of Domestic Violence
#   The extracted data is compiled into a single dataframe ('final_data').
# Author: Pratish Patel
# Date: December 24, 2024
# Dependencies:
#   - Libraries: `stringr`, `pdftools`, `dplyr`
#   - External Scripts: `1-2023LinkScraper.R`, `ReportDataExtractorFunc.R`
# ====================================================================

# Source helper scripts
source('Code/1-2023LinkScraper.R')          # Load 'Report_2023' data
source('Code/HelperFunctions/ReportDataExtractorFunc.R')  # Load 'extract_total_homeless_data' function

# ====================================================================
# Data Preparation
# ====================================================================

# Remove duplicate rows based on 'CoC_Code'
Report_2023 <- distinct(Report_2023, CoC_Code, .keep_all = TRUE)

# Initialize an empty dataframe to store results
final_data <- data.frame(
  Emergency_Shelter = numeric(0),
  Transitional_Housing = numeric(0),
  Unsheltered = numeric(0),
  Total = numeric(0),
  CoC_Code = character(0),
  CoC_Name = character(0),
  Year = character(0),
  Type = character(0),
  stringsAsFactors = FALSE
)

# ====================================================================
# Function: Process Individual Data Category
# Purpose:
#   Extracts and processes data for a specific category (e.g., 
#   "Total Homeless Households") from a given PDF page.
# Parameters:
#   - doc: Text content of the PDF report.
#   - page: Page number from which data is extracted.
#   - regex_pattern: Regex pattern to identify the data section.
#   - label: Label describing the data category (e.g., "Veterans").
#   - coc_code: CoC code for the current report.
#   - coc_name: CoC name for the current report.
# Returns:
#   A dataframe containing the extracted data for the specified category.
# ====================================================================
process_category <- function(doc, page, regex_pattern, label, coc_code, coc_name) {
  # Extract relevant text from the specified PDF page using regex
  text_string <- doc[page]
  extracted_text <- str_extract(text_string, regex_pattern)
  
  # Clean the extracted text
  cleaned_text <- str_trim(extracted_text)
  
  # Extract data for the given label
  extract_total_homeless_data(
    cleaned_text = cleaned_text,
    label = label,
    coc_code = coc_code,
    coc_name = coc_name
  )
}

# ====================================================================
# Main Loop: Process All Rows in 'Report_2023'
# ====================================================================
for (i in seq_len(nrow(Report_2023))) {
  
  # Extract PDF URL and read its content
  pdf_url <- Report_2023$ReportLink[i]
  pdf_content <- pdf_text(pdf_url)
  
  # Define the CoC information
  coc_code <- Report_2023$CoC_Code[i]
  coc_name <- Report_2023$CoC_Name[i]
  
  # Extract and process data for each category
  total_homeless_data <- process_category(
    doc = pdf_content,
    page = 1,
    regex_pattern = "(?<=Summary by household)[\\s\\S]*?(?=Summary of persons)",
    label = "Total Homeless Households",
    coc_code = coc_code,
    coc_name = coc_name
  )
  
  chronic_homeless_data <- process_category(
    doc = pdf_content,
    page = 3,
    regex_pattern = "(?<=Summary of chronically)[\\s\\S]*?(?=Summary of all)",
    label = "Total Chronically Homeless Persons",
    coc_code = coc_code,
    coc_name = coc_name
  )
  
  mental_illness_data <- process_category(
    doc = pdf_content,
    page = 3,
    regex_pattern = "(?<=Summary of all)[\\s\\S]*?(?=Unaccompanied)",
    label = "Severely Mentally Ill",
    coc_code = coc_code,
    coc_name = coc_name
  )
  
  substance_abuse_data <- process_category(
    doc = pdf_content,
    page = 3,
    regex_pattern = "(?<=Summary of all)[\\s\\S]*?(?=Unaccompanied)",
    label = "Chronic Substance Abuse",
    coc_code = coc_code,
    coc_name = coc_name
  )
  
  veteran_data <- process_category(
    doc = pdf_content,
    page = 3,
    regex_pattern = "(?<=Summary of all)[\\s\\S]*?(?=Unaccompanied)",
    label = "Veterans",
    coc_code = coc_code,
    coc_name = coc_name
  )
  
  domestic_violence_data <- process_category(
    doc = pdf_content,
    page = 3,
    regex_pattern = "(?<=Summary of all)[\\s\\S]*?(?=Unaccompanied)",
    label = "Victims of Domestic Violence",
    coc_code = coc_code,
    coc_name = coc_name
  )
  
  # Combine all extracted data for the current CoC
  combined_data <- bind_rows(
    total_homeless_data,
    chronic_homeless_data,
    mental_illness_data,
    substance_abuse_data,
    veteran_data,
    domestic_violence_data
  )
  
  # Append the combined data to the final dataframe
  final_data <- bind_rows(final_data, combined_data)
}

# ====================================================================
# End of Script
# ====================================================================
