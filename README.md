# 🌍 Earth in Crisis: Climate Visual Analytics of Heat Extremes & Natural Disasters
## Overview

Earth in Crisis is an end-to-end data visualization project that explores the accelerating impacts of climate change through global temperature anomalies, heatwaves, and natural disasters.
The project combines static scientific visualizations, critical visual redesign, and an interactive analytics dashboard to support climate awareness, interpretation, and decision-making.

This repository consolidates multiple academic visual analytics tasks into a single, cohesive portfolio project, structured and documented to reflect industry best practices.

---

## Objectives

* Visualize global surface temperature anomalies and long-term climate trends
* Communicate the intensification of heatwaves, with a focus on Australia
* Analyze natural disaster frequency and impact across regions since 2000
* Demonstrate effective visual design, accessibility, and storytelling
* Deliver an interactive dashboard for exploratory climate impact analysis

---

## Data Sources

* NOAA Global Surface Temperature Dataset (NetCDF format)
* NASA Climate Change – Global Temperature Records
* EM-DAT International Disaster Database (Natural disasters, 2000–present)
* ARC Centre of Excellence for Climate Extremes (contextual references)

All datasets are publicly available and cited appropriately in the reports.

---

## Project Structure

```text
Earth-in-Crisis-Climate-Visual-Analytics/
│
├── README.md
│
├── data/
│   ├── raw/                # Original climate & disaster datasets
│   └── processed/          # Cleaned and transformed datasets
│
├── scripts/
│   ├── climate_temperature_analysis.R
│   ├── spatial_temperature_mapping.R
│   ├── disaster_data_cleaning.R
│   └── disaster_summary_metrics.R
│
├── visualizations/
│   ├── global_temperature_map.png
│   ├── global_temperature_trend.png
│   └── disaster_impact_charts.png
│
├── dashboards/
│   └── shiny_app/
│       └── app.R
│
├── reports/
    ├── methodology.md
    ├── insights.md
    └── limitations.md
```

---

## Methodology (High Level)

1. Data Preparation

* Cleaned and standardized temperature and disaster datasets
* Addressed missing values and extreme outliers (IQR-based handling)
* Aggregated disaster metrics by year, region, and type

2. Exploratory & Statistical Analysis

* Long-term temperature anomaly trend analysis (1961–2021)
* Comparative analysis of disaster frequency and impact
* Regional and temporal aggregation for meaningful comparison

3. Visualization Design

* Spatial mapping using sf and Natural Earth boundaries
* Perceptually uniform, color-blind-safe palettes
* Explicit encoding of missing data
* Reduction of chart junk and improved visual hierarchy

4. Interactive Dashboard

* Built using Shiny, Plotly, and Leaflet
* Time-series trends, choropleth maps, and animated bubble plots
* User-driven exploration by disaster type, region, and year

----

## Key Features

* Global temperature anomaly maps with temporal context
* ong-term climate trend visualization
* Natural disaster analytics by type, region, and impact
* Interactive world maps with hover-based insights
* Animated visualizations showing disaster evolution over time
* Accessibility-aware design (color and perceptual considerations)

---

## Interactive Dashboard

The Shiny application provides:
* Disaster trends over time
* Regional distribution by disaster type
* Comparative impact analysis (deaths, damage, affected population)
* Animated exploration of climate disaster dynamics

Live App: [Dashboard](https://8toyn5-hishikesh-phukan.shinyapps.io/project/)


---

Tools & Technologies

* R
* ggplot2, dplyr, tidyr
* sf, rnaturalearth
* ncdf4 (NetCDF climate data)
* Shiny, shinydashboard
* Plotly, Leaflet

---

## Insights (Summary)

* Global temperature anomalies show a clear upward trajectory over the past six decades
* Heat extremes are becoming more frequent, intense, and prolonged
* Natural disasters have increased in both frequency and socio-economic impact since 2000
* Climate impacts are unevenly distributed, with certain regions disproportionately affected

Detailed findings are documented in reports/insights.md.

---

## Limitations

* Disaster records may contain reporting inconsistencies across regions
* Economic damage estimates vary in reliability between countries
* Climate datasets rely on historical interpolation in low-coverage regions

See reports/limitations.md for full discussion.

---

## Author

Hishikesh Phukan
Master of Data Science – RMIT University

---

## Disclaimer

This project is based on academic coursework and publicly available datasets.
All analyses and interpretations are presented for educational and portfolio purposes only.
