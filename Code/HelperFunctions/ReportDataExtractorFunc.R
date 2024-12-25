# ====================================================================
# Function: extract_total_homeless_data
# Purpose: Extract and process numerical data for a specified category 
#          (e.g., "Total Homeless Households") from cleaned text.
# Parameters:
#   - cleaned_text (character): The cleaned text extracted from the PDF, 
#                               containing the relevant data for processing.
#   - label (character): The label identifying the data category (e.g., 
#                        "Total Homeless Households").
#   - coc_code (character): The Continuum of Care (CoC) code for the current report.
#   - coc_name (character): The Continuum of Care (CoC) name for the current report.
#   - year (character): The year of the report (default is "2023").
# Returns:
#   A dataframe containing the extracted data for the specified category, 
#   including the number of households across different types (e.g., Emergency 
#   Shelter, Transitional Housing, Unsheltered), the total count, and metadata 
#   like CoC code, name, year, and type.
# Dependencies:
#   - Requires the `stringr` library for string manipulation.
# ====================================================================
extract_total_homeless_data <- function(cleaned_text, label, coc_code, coc_name, year = "2023") {
  
  # Extract the line that contains the provided label (e.g., "Total Homeless Households")
  label_line <- str_extract(cleaned_text, paste0(label, "[^\\n]*"))
  
  # Extract numeric values using regular expressions
  values <- str_extract_all(label_line, "\\d{1,3},?\\d{0,3}")[[1]]
  
  # Remove commas from the extracted values and convert to numeric
  numeric_values <- as.numeric(gsub(",", "", values))
  
  # Create a dataframe to store the processed data
  total_homeless_df <- data.frame(
    Emergency_Shelter = numeric_values[1],          # Number in Emergency Shelter
    Transitional_Housing = numeric_values[2],       # Number in Transitional Housing
    Unsheltered = numeric_values[3],                # Number Unsheltered
    Total = numeric_values[4],                      # Total count across all categories
    CoC_Code = coc_code,                            # CoC code
    CoC_Name = coc_name,                            # CoC name
    Year = year,                                    # Year of the report
    Type = label                                    # Data category type
  )
  
  # Return the resulting dataframe
  return(total_homeless_df)
}
