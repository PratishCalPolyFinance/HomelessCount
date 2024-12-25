# ====================================================================
# Title: Generate California CoC Report Links
# Description: This script processes a dataset containing California 
# Continuum of Care (CoC) locations to extract CoC codes and names. 
# It generates a list of URLs pointing to PDF reports for each CoC.
# Author: Pratish Patel
# Date: December 24, 2024
# ====================================================================

# Clear workspace
# Removing all objects from the workspace to ensure a clean environment
rm(list = ls())  

# Load necessary packages
# Sources the script to load required packages
source('Code/0-LoadPackages.R')  

# Load Helper Functions
# Sources the script that contains the function to generate CoC report links
source('Code/HelperFunctions/GenerateCoCLinksFunc.R')  

# 2023 Report Download
# Call the function to generate CoC report links for 2023
Report_2023 <- generate_coc_report_links(2023)
