# ============================================================
# Script: 02_temperature_analysis.R
# Purpose: Global temperature anomaly trend analysis (HadCRUT)
# Output: visualizations/temperature_trend_timeseries.png
# ============================================================

library(tidyverse)
library(lubridate)

# ---- Load HadCRUT data ----
temp_path <- "data/raw/HadCRUT.5.0.2.0.analysis.summary_series.global.monthly.csv"
temp_raw <- read_csv(temp_path, show_col_types = FALSE)

# ---- Helper: find a column by candidate patterns ----
find_col <- function(df, patterns) {
  nms <- names(df)
  hit <- nms[str_detect(tolower(nms), str_c(patterns, collapse = "|"))]
  if (length(hit) == 0) return(NA_character_)
  hit[1]
}

# Try to infer relevant columns
date_col <- find_col(temp_raw, c("^time$", "^date$", "^(year|yr)$", "month"))
anom_col <- find_col(temp_raw, c("anom", "anomaly", "temperature", "temp"))

# If there is a "Time" column, it is often YYYY-MM format or a decimal year
time_col <- find_col(temp_raw, c("^time$"))

# ---- Build a usable (Date, Anomaly) dataset ----
temp_clean <- NULL

if (!is.na(time_col) && !is.na(anom_col)) {
  # Case A: There is a Time column (common in HadCRUT summaries)
  # Try parsing as YYYY-MM first, then fallback to numeric year.
  tmp <- temp_raw %>%
    transmute(
      Time = .data[[time_col]],
      Anomaly = .data[[anom_col]]
    )
  
  # Try YYYY-MM parsing
  temp_clean <- tmp %>%
    mutate(
      Date = suppressWarnings(ymd(paste0(Time, "-01")))
    )
  
  # If most dates failed, treat Time as numeric year (decimal)
  if (mean(is.na(temp_clean$Date)) > 0.5) {
    temp_clean <- tmp %>%
      mutate(
        TimeNum = as.numeric(Time),
        Year = floor(TimeNum),
        Month = pmax(1, pmin(12, round((TimeNum - Year) * 12) + 1)),
        Date = ymd(sprintf("%d-%02d-01", Year, Month))
      ) %>%
      select(Date, Anomaly)
  } else {
    temp_clean <- temp_clean %>% select(Date, Anomaly)
  }
  
} else {
  # Case B: Try Year + Month columns
  year_col <- find_col(temp_raw, c("^year$", "^yr$", "year"))
  month_col <- find_col(temp_raw, c("^month$", "month"))
  
  if (is.na(year_col) || is.na(month_col) || is.na(anom_col)) {
    stop(
      "Could not infer HadCRUT columns automatically.\n",
      "Found columns: ", paste(names(temp_raw), collapse = ", "), "\n",
      "Please share the first row/headers (e.g., head(temp_raw)) and I will map it precisely."
    )
  }
  
  temp_clean <- temp_raw %>%
    transmute(
      Date = ymd(sprintf("%d-%02d-01", .data[[year_col]], .data[[month_col]])),
      Anomaly = .data[[anom_col]]
    )
}

# ---- Aggregate yearly mean anomalies ----
temp_yearly <- temp_clean %>%
  mutate(Year = year(Date)) %>%
  group_by(Year) %>%
  summarise(
    Mean_Anomaly = mean(Anomaly, na.rm = TRUE),
    .groups = "drop"
  )

# ---- Plot ----
p <- ggplot(temp_yearly, aes(x = Year, y = Mean_Anomaly)) +
  geom_line(linewidth = 0.8) +
  geom_hline(yintercept = 0, linetype = "dashed") +
  labs(
    title = "Global Mean Surface Temperature Anomaly",
    subtitle = "Annual mean anomaly (baseline depends on HadCRUT series definition)",
    x = "Year",
    y = "Temperature Anomaly (°C)"
  ) +
  theme_minimal()

# ---- Save ----
dir.create("visualizations", showWarnings = FALSE, recursive = TRUE)

ggsave(
  filename = "visualizations/temperature_trend_timeseries.png",
  plot = p,
  width = 9, height = 5, dpi = 300
)

message("Temperature analysis completed. Saved: visualizations/temperature_trend_timeseries.png")
