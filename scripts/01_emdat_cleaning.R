# ============================================================
# Script: 01_emdat_cleaning.R
# Purpose: Clean and preprocess EM-DAT disaster data
# Output: data/processed/emdat_cleaned_2000_present.csv
# ============================================================

library(dplyr)
library(readr)
library(stringr)

# ---- Load raw data ----
raw_path <- "data/raw/public_emdat_2025-05-26.csv"

emdat_raw <- read_csv(
  raw_path,
  locale = locale(encoding = "latin1"),
  show_col_types = FALSE
)

# ---- Helper function: outlier handling (IQR method) ----
replace_outliers <- function(x) {
  q1 <- quantile(x, 0.25, na.rm = TRUE)
  q3 <- quantile(x, 0.75, na.rm = TRUE)
  iqr <- q3 - q1
  lower <- q1 - 1.5 * iqr
  upper <- q3 + 1.5 * iqr
  
  x[x < lower | x > upper] <- mean(x[x >= lower & x <= upper], na.rm = TRUE)
  x
}

# ---- Clean & transform ----
emdat_clean <- emdat_raw %>%
  filter(
    `Disaster Group` == "Natural",
    !is.na(`Start Year`),
    `Start Year` >= 2000
  ) %>%
  transmute(
    Year        = `Start Year`,
    Country     = Country,
    Region      = Region,
    Subregion   = Subregion,
    Disaster    = `Disaster Type`,
    Subtype     = `Disaster Subtype`,
    Deaths      = replace_na(`Total Deaths`, 0),
    Affected    = replace_na(`Total Affected`, 0),
    Damage_USD  = replace_na(`Total Damage ('000 US$)`, 0),
    Latitude    = Latitude,
    Longitude   = Longitude
  ) %>%
  group_by(Country) %>%
  mutate(
    Deaths     = replace_outliers(Deaths),
    Affected   = replace_outliers(Affected),
    Damage_USD = replace_outliers(Damage_USD)
  ) %>%
  ungroup()

# ---- Save processed dataset ----
output_path <- "data/processed/emdat_cleaned_2000_present.csv"
write_csv(emdat_clean, output_path)

message("EM-DAT cleaning complete. File saved to: ", output_path)
