# Interactive Climate Disaster Dashboard (Shiny)

## Overview

This folder contains an **interactive R Shiny dashboard** developed as part of the *Earth in Crisis: Climate Visual Analytics* project. The dashboard provides an exploratory, data-driven view of **global natural disasters since 2000**, focusing on trends, geographic distribution, and human and economic impacts.

The application is designed to support **public awareness, exploratory analysis, and decision-support discussions** around climate-related disasters.

------------------------------------------------------------------------

## Key Features

The dashboard is organised into three analytical views:

### 1. Overview

-   Time-series visualization of the **number of natural disasters over time**

-   Interactive pie chart showing **regional distribution by disaster type**

-   Animated bubble plot illustrating how **deaths, affected population, and economic damage evolve over time**

### 2. Disaster Distribution by Region

-   Interactive **choropleth world map** displaying disaster counts by country

-   User-selectable disaster type

-   Hover-based inspection for country-level details

### 3. Impact Analysis

-   Bubble plots comparing disaster types by:

    -   Total deaths

    -   Total affected population

    -   Total economic damage

-   Animated views to highlight **temporal dynamics of disaster severity**

------------------------------------------------------------------------

## Data Source

-   **EM-DAT: The International Disaster Database**

    -   Provider: Centre for Research on the Epidemiology of Disasters (CRED)

    -   URL: <https://www.emdat.be/>

    -   Scope: Global natural disasters (filtered to year ≥ 2000)

        Raw data files are stored in `data/raw/`, and cleaned datasets are stored in `data/processed/`.

------------------------------------------------------------------------

## Data Preparation Summary

Before visualization, the data undergoes:

-   Filtering to **natural disasters only**

-   Missing value handling (deaths, damage, affected population)

-   Outlier treatment using **IQR-based detection**

-   Country name standardisation for spatial joins

-   Aggregation for temporal and categorical analysis

    All preprocessing logic is implemented directly within `app.R`.

------------------------------------------------------------------------

## Technology Stack

-   **Language:** R

-   **Framework:** Shiny, shinydashboard

-   **Visualization:** ggplot2, plotly, leaflet

-   **Data Manipulation:** dplyr, readr

-   **Spatial Data:** sf, rnaturalearth

------------------------------------------------------------------------

## Running the Dashboard Locally

### Prerequisites

Ensure the following R packages are installed:

```         
install.packages(c(
  "shiny",
  "shinydashboard",
  "ggplot2",
  "dplyr",
  "readr",
  "plotly",
  "leaflet",
  "sf",
  "rnaturalearth",
  "RColorBrewer"
))
```

### Launch the App

From the `dashboards/shiny_app/` directory:

```         
shiny::runApp("app.R")
```

------------------------------------------------------------------------

## Live Deployment

The dashboard is deployed on **shinyapps.io** and can be accessed here:

👉 <https://8toyn5-hishikesh-phukan.shinyapps.io/project/>

------------------------------------------------------------------------

## Purpose in the Overall Project

This dashboard represents the **interactive analytics layer** of the broader project:

-   Vodcast → Narrative framing

-   Static visualizations → Scientific evidence

-   **Shiny dashboard → Exploratory and decision-support analytics**

Together, these components demonstrate end-to-end **data visualization, storytelling, and interactive analysis** capabilities.

------------------------------------------------------------------------

## Author

**Hishikesh Phukan**

Master of Data Science\
RMIT University
