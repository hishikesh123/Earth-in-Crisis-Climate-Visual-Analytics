# ============================================================
# Script: 00_run_all.R
# Purpose: Run full pipeline and generate required visual outputs
# Outputs (visualizations/):
#   - global_temperature_anomaly_map.png  (if gridded NetCDF exists)
#   - temperature_trend_timeseries.png
#   - disaster_impact_bubble.png
# ============================================================

# ---- Housekeeping: create required folders ----
dir.create("data/processed", recursive = TRUE, showWarnings = FALSE)
dir.create("visualizations", recursive = TRUE, showWarnings = FALSE)

message("=== Running pipeline: Earth in Crisis ===")

# ------------------------------------------------------------
# 1) Run EM-DAT cleaning
# ------------------------------------------------------------
message("\n[1/3] Running EM-DAT cleaning (01_emdat_cleaning.R)...")
source("scripts/01_emdat_cleaning.R", local = TRUE)

# ------------------------------------------------------------
# 2) Run temperature time-series analysis
# ------------------------------------------------------------
message("\n[2/3] Running temperature trend analysis (02_temperature_analysis.R)...")
source("scripts/02_temperature_analysis.R", local = TRUE)

# ------------------------------------------------------------
# 3) Generate required visualizations
#    3a) Disaster impact bubble plot (required)
#    3b) Global temperature anomaly map (required, but only possible
#        if a gridded dataset is available)
# ------------------------------------------------------------

# =========================
# 3a) Disaster bubble plot
# =========================
message("\n[3/3] Generating disaster_impact_bubble.png...")

suppressPackageStartupMessages({
  library(dplyr)
  library(readr)
  library(ggplot2)
  library(scales)
})

disaster_path <- "data/processed/emdat_cleaned_2000_present.csv"
disaster_data <- read_csv(disaster_path, show_col_types = FALSE)

bubble_df <- disaster_data %>%
  group_by(Disaster) %>%
  summarise(
    Total_Deaths   = sum(Deaths, na.rm = TRUE),
    Total_Affected = sum(Affected, na.rm = TRUE),
    Total_Damage   = sum(Damage_USD, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  filter(Total_Deaths > 0 | Total_Affected > 0 | Total_Damage > 0)

p_bubble <- ggplot(
  bubble_df,
  aes(x = Total_Damage, y = Total_Deaths, size = Total_Affected, label = Disaster)
) +
  geom_point(alpha = 0.75) +
  geom_text(check_overlap = TRUE, vjust = -0.7, size = 3) +
  scale_x_continuous(labels = label_number(scale_cut = cut_si(""))) +
  scale_y_continuous(labels = label_number(scale_cut = cut_si(""))) +
  scale_size_continuous(labels = label_number(scale_cut = cut_si(""))) +
  labs(
    title = "Disaster Impact Bubble Plot (Since 2000)",
    subtitle = "Damage vs deaths; bubble size indicates total affected population",
    x = "Total Damage ('000 US$)",
    y = "Total Deaths",
    size = "Total Affected"
  ) +
  theme_minimal()

ggsave(
  filename = "visualizations/disaster_impact_bubble.png",
  plot = p_bubble,
  width = 10, height = 6, dpi = 300
)

message("Saved: visualizations/disaster_impact_bubble.png")

# ======================================
# 3b) Global temperature anomaly map
# ======================================
message("\nAttempting global temperature anomaly map (global_temperature_anomaly_map.png)...")

# This requires a gridded dataset (e.g., NOAA NetCDF like used in your Assignment 2).
# If the file does not exist, we skip safely and print instructions.

candidate_netcdf <- c(
  "data/raw/NOAAGlobalTemp_v5.0.0_gridded_s188001_e202212_c20230108T133308.nc",
  "data/raw/noaa_global_temp.nc",
  "data/raw/noaa_temp_anomaly.nc"
)

nc_path <- candidate_netcdf[file.exists(candidate_netcdf)][1]

if (is.na(nc_path)) {
  message(
    "SKIPPED: global_temperature_anomaly_map.png\n",
    "Reason: No gridded NetCDF temperature anomaly file found in data/raw/.\n",
    "Your HadCRUT summary series is global-only (time series), so it cannot produce a world map.\n\n",
    "To enable the map, place a NOAA (or HadCRUT gridded) NetCDF in data/raw/ and re-run.\n",
    "Expected file name example:\n",
    "  data/raw/NOAAGlobalTemp_v5.0.0_gridded_s188001_e202212_c20230108T133308.nc\n"
  )
} else {
  suppressPackageStartupMessages({
    library(ncdf4)
    library(reshape2)
    library(rnaturalearth)
    library(sf)
    library(scico)
  })
  
  nc <- nc_open(nc_path)
  on.exit(nc_close(nc), add = TRUE)
  
  # Typical variable names in NOAA dataset
  anom <- ncvar_get(nc, "anom")
  lon  <- ncvar_get(nc, "lon")
  lat  <- ncvar_get(nc, "lat")
  time <- ncvar_get(nc, "time")
  
  origin <- as.Date(sub("days since ", "", ncatt_get(nc, "time", "units")$value))
  dates  <- origin + time
  
  # Choose Dec 2021 (as per your assignment narrative)
  target_date <- as.Date("2021-12-15")
  idx <- which.min(abs(dates - target_date))
  slice <- anom[,,idx]
  
  df <- melt(slice, varnames = c("lon_idx", "lat_idx"), value.name = "anomaly")
  df$lon <- lon[df$lon_idx]
  df$lat <- lat[df$lat_idx]
  
  # Fix longitude wrap (0..360 -> -180..180)
  df$lon <- ifelse(df$lon > 180, df$lon - 360, df$lon)
  
  world <- ne_countries(scale = "medium", returnclass = "sf")
  
  p_map <- ggplot() +
    geom_raster(data = df, aes(x = lon, y = lat, fill = anomaly)) +
    geom_sf(data = world, fill = NA, color = "white", linewidth = 0.15) +
    coord_sf(crs = "EPSG:4326", expand = FALSE) +
    scico::scale_fill_scico(palette = "roma", midpoint = 0, na.value = "grey85") +
    labs(
      title = "Global Temperature Anomaly Map",
      subtitle = "Example month: December 2021 (relative anomaly)",
      x = NULL, y = NULL, fill = "Anomaly (°C)"
    ) +
    theme_minimal()
  
  ggsave(
    filename = "visualizations/global_temperature_anomaly_map.png",
    plot = p_map,
    width = 12, height = 6.5, dpi = 300
  )
  
  message("Saved: visualizations/global_temperature_anomaly_map.png")
}

message("\n=== Pipeline complete ===")
message("Check the visualizations/ folder for outputs.")
