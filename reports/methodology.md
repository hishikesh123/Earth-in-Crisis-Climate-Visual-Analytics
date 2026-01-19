# Methodology

## Project Overview

This project presents an end-to-end data visualisation workflow exploring global climate trends and natural disaster impacts. It integrates static climate visualisations, critical visual redesign, and an interactive dashboard to communicate complex climate-related data to both technical and non-technical audiences.

The methodology follows a structured pipeline: data acquisition, cleaning and preprocessing, exploratory analysis, visual design, interactivity development, and narrative synthesis.

------------------------------------------------------------------------

## Data Sources

Multiple authoritative datasets were used to ensure reliability and coverage:

-   **EM-DAT International Disaster Database**\
    Used to analyse global natural disaster occurrences, impacts, fatalities, and economic damage from 2000 onwards.

-   **HadCRUT Global Surface Temperature Dataset**\
    Used for historical global temperature anomaly analysis and climate trend visualisation.

-   **NOAA Global Surface Temperature Dataset**\
    Utilised during visual reconstruction to improve spatial coverage and reduce missing data artefacts.

------------------------------------------------------------------------

## Data Cleaning and Preprocessing

Raw datasets were cleaned using R with the following steps:

-   Filtering for **natural disasters only**
-   Standardising column names and country identifiers
-   Handling missing values by imputation or exclusion where appropriate
-   Detecting and mitigating outliers using the Interquartile Range (IQR) method
-   Aggregating disaster impacts by year, region, and disaster type
-   Restricting analysis to post-2000 data to ensure consistency and completeness

Processed datasets were stored separately to preserve raw data integrity and reproducibility.

------------------------------------------------------------------------

## Visual Design and Reconstruction

The project applied established data visualisation principles:

-   **Color Accessibility**: Perceptually uniform and colorblind-safe palettes (e.g., Cividis, Scico)
-   **Data Transparency**: Explicit representation of missing data rather than silent omission
-   **Contextualisation**: Supplementing spatial maps with temporal time-series views
-   **Minimal Cognitive Load**: Clear legends, annotations, and restrained visual encoding

An original climate map visualisation was deconstructed and reconstructed to improve interpretability, accessibility, and analytical depth.

------------------------------------------------------------------------

## Interactive Dashboard Development

An interactive dashboard was built using **R Shiny** and **shinydashboard**, featuring:

-   Time-series trend exploration
-   Disaster-type filtering
-   Interactive world maps using Leaflet
-   Animated visualisations using Plotly
-   Multi-dimensional impact comparisons (deaths, damage, affected population)

This allowed users to explore patterns dynamically rather than passively consuming static graphics.

------------------------------------------------------------------------

## Tools and Technologies

-   **Programming Language**: R
-   **Libraries**: ggplot2, dplyr, shiny, plotly, leaflet, sf, rnaturalearth
-   **Frameworks**: Shiny, Shinydashboard
-   **Design Principles**: Grammar of Graphics, perceptual design, narrative visualisation

------------------------------------------------------------------------

## Reproducibility

All steps in the pipeline are script-driven and modular, ensuring transparency, reproducibility, and ease of extension for future analyses.
