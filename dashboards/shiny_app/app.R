library(shiny)
library(shinydashboard)
library(ggplot2)
library(dplyr)
library(readr)
library(plotly)
library(leaflet)
library(rnaturalearth)
library(sf)
# Load and clean data
raw_data <- read_csv('data/raw/public_emdat_2025-05-26.csv',
                     locale = locale(encoding = "latin1"))
# Function to identify outliers
is_outlier <- function(x) {
  Q1 <- quantile(x, 0.25, na.rm = TRUE)
  Q3 <- quantile(x, 0.75, na.rm = TRUE)
  IQR_val <- Q3 - Q1
  x < (Q1 - 1.5 * IQR_val) | x > (Q3 + 1.5 * IQR_val)
}
clean_data <- raw_data %>%
  filter(`Disaster Group` == "Natural", !is.na(`Start Year`)) %>%
  rename(
    Year = `Start Year`,
    Country = Country,
    Region = Region,
    Subregion = Subregion,
    Type = `Disaster Type`,
    Subtype = `Disaster Subtype`,
    Deaths = `Total Deaths`,
    Damage_USD = `Total Damage ('000 US$)`,
    Affected = `Total Affected`,
    Latitude = Latitude,
    Longitude = Longitude
  ) %>%
  select(Year, Country, Region, Subregion, Type, Subtype,
         Deaths, Damage_USD, Affected, Latitude, Longitude) %>%
  mutate(
    Deaths = ifelse(is.na(Deaths), 0, Deaths),
    Damage_USD = ifelse(is.na(Damage_USD), 0, Damage_USD),
    Affected = ifelse(is.na(Affected), 0, Affected)
  ) %>%
  group_by(Country) %>%
  mutate(
    Deaths = ifelse(is_outlier(Deaths),
                    mean(Deaths[!is_outlier(Deaths)], na.rm = TRUE),
                    Deaths),
    Damage_USD = ifelse(is_outlier(Damage_USD),
                        mean(Damage_USD[!is_outlier(Damage_USD)], na.rm = TRUE),
                        Damage_USD),
    Affected = ifelse(is_outlier(Affected),
                      mean(Affected[!is_outlier(Affected)], na.rm = TRUE),
                      Affected)
  ) %>%
  ungroup() %>%
  filter(Year >= 2000)
disaster_data <- clean_data
disaster_types <- unique(disaster_data$Type)
animated_data <- disaster_data %>%
  filter(!is.na(Deaths), Deaths > 0) %>%
  group_by(Year, Type) %>%
  summarise(
    Total_Deaths = sum(Deaths, na.rm = TRUE),
    Total_Affected = sum(Affected, na.rm = TRUE),
    Total_Damage = sum(Damage_USD, na.rm = TRUE),
    .groups = "drop"
  )
# Load world map with natural earth, class sf
regions_spdf <- ne_countries(returnclass = "sf")
# Rename country names in disaster_data for map join consistency
disaster_data <- disaster_data %>%
  mutate(Country = recode(Country,
                          "Iran (Islamic Republic of)" = "Iran",
                          "Russian Federation" = "Russia",
                          "Congo" = "Republic of Congo",
                          "Democratic Republic of the Congo" = "Democratic Republic of the Congo",
                          "Bolivia (Plurinational State of)" = "Bolivia",
                          "Czechia" = "Czech Republic",
                          "TÃ¼rkiye" = "Turkey",
                          "Republic of Korea" = "South Korea",
                          "Serbia Montenegro" = "Serbia",
                          "Micronesia (Federated States of)" = "Micronesia",
                          "United Kingdom of Great Britain and Northern Ireland" = "United Kingdom",
                          "Lao People's Democratic Republic" = "Laos",
                          "Taiwan (Province of China)" = "Taiwan",
                          "Democratic People's Republic of Korea" = "North Korea",
                          "Syrian Arab Republic" = "Syria",
                          "CÃ´te dâ\u0080\u0099Ivoire" = "Ivory Coast",
                          "Myanmar" = "Myanmar",
                          "Viet Nam" = "Vietnam",
                          "Republic of Moldova" = "Moldova",
                          "United States of America" = "United States",
                          "China, Hong Kong Special Administrative Region" = "Hong Kong",
                          "China, Macao Special Administrative Region" = "Macao",
                          "State of Palestine" = "Palestine",
                          "RÃ©union" = "Reunion",
                          "Eswatini" = "Eswatini",
                          "Saint BarthÃ©lemy" = "Saint Barthelemy"
  ))
# UI
ui <- dashboardPage(
  title = "Earth in Crisis: A Data Story of Climate Disasters",
  dashboardHeader(
    title = tags$a(
      href = "#",
      style = "color: #FFFFFF; font-weight: bold; font-size: 24px;",
      icon("globe-americas"),
      " Earth in Crisis"
    ),
    titleWidth = 300
  ),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Overview", tabName = "overview", icon = icon("globe")),
      menuItem("Disasters in Various Region", tabName = "types", icon = icon("map")),
      menuItem("Impact", tabName = "impact", icon = icon("exclamation-triangle"))
    )
  ),
  dashboardBody(
    tabItems(
      # Overview tab
      tabItem(
        tabName = "overview",
        # Title / Intro Box
        fluidRow(
          box(width = 10, height = 60, status = "primary", solidHeader = FALSE,
              p("Explore how natural disasters have affected the world since 2000. This dashboard offers
insights into disaster trends and impacts, aiming to inform public awareness and support resilience
planning.")
          )
        ),
        # Two plots side-by-side (Line Chart + Pie Chart)
        fluidRow(
          box(width = 6, title = "Disasters Over Time", status = "info", solidHeader = TRUE,
              plotlyOutput("summaryPlot", height = "300px")
          ),
          box(width = 6, title = "Disaster Types by Region", status = "info", solidHeader = TRUE,
              selectInput("selectedDisaster", "Select Disaster Type:",
                          choices = disaster_types, selected = disaster_types[1]),
              plotlyOutput("pieChart", height = "250px")
          )
        ),
        # Full-width Animated Bubble Plot
        fluidRow(
          box(width = 12, title = "Animated Disaster Impact Over Time", status = "warning", solidHeader =
                TRUE,
              plotlyOutput("animatedPlot", height = "350px")
          )
        )
      ),
      # Types tab
      tabItem(tabName = "types",
              fluidRow(
                box(width = 12, title = "Distribution of Disaster Types by Country", status = "warning",
                    solidHeader = TRUE,
                    selectInput("selectedType", "Select Disaster Type:",
                                choices = unique(disaster_data$Type),
                                selected = unique(disaster_data$Type)[1]),
                    leafletOutput("mapPlot", height = "700px"),
                    p("Select a disaster type from the dropdown to see the distribution of disaster occurrences by
country. Hover over countries to view counts.")
                )
              )
      ),
      # Impact tab
      tabItem(tabName = "impact",
              fluidRow(
                box(width = 12, title = "Disaster Impact Bubble Plot", status = "danger", solidHeader = TRUE,
                    plotlyOutput("impactBubblePlot", height = "300px"),
                    p(style = "font-size: 12px; margin-top: 5px;",
                      "Bubble plot comparing disaster types by deaths, damage, and affected population.")
                )
              ),
              fluidRow(
                box(width = 12, title = "Animated Disaster Impact by Year", status = "danger", solidHeader =
                      TRUE,
                    plotlyOutput("animatedBubblePlot", height = "300px"),
                    p(style = "font-size: 12px; margin-top: 5px;",
                      "Animated plot showing trends in disaster impacts over time.")
                )
              )
      )
    )
  )
)
# Server
server <- function(input, output) {
  output$summaryPlot <- renderPlotly({
    plot <- disaster_data %>%
      group_by(Year) %>%
      summarise(Count = n()) %>%
      ggplot(aes(x = Year, y = Count)) +
      geom_line(color = 'steelblue') +
      geom_point() +
      labs(title = "Number of Natural Disasters Over Time", x = "Year", y = "Number of Disasters") +
      theme_minimal()
    ggplotly(plot)
  })
  output$pieChart <- renderPlotly({
    filtered_data <- disaster_data %>% filter(Type == input$selectedDisaster)
    plot <- filtered_data %>%
      group_by(Region) %>%
      summarise(Count = n()) %>%
      arrange(desc(Count)) %>%
      plot_ly(
        labels = ~Region,
        values = ~Count,
        type = 'pie',
        textinfo = 'label+percent',
        hoverinfo = 'label+percent+value',
        marker = list(colors = RColorBrewer::brewer.pal(min(length(unique(.$Region)), 8), "Set2"))
      ) %>%
      layout(title = paste("Regional Distribution for", input$selectedDisaster),
             legend = list(font = list(size = 10)))
    plot
  })
  output$animatedPlot <- renderPlotly({
    animated_bubble <- plot_ly(
      data = animated_data,
      x = ~Total_Affected,
      y = ~Total_Damage,
      size = ~Total_Deaths,
      frame = ~Year,
      color = ~Type,
      type = 'scatter',
      mode = 'markers',
      marker = list(sizemode = 'area', sizeref = 0.05, sizemin = 3, line = list(width = 1)),
      text = ~paste(
        "Type:", Type,
        "<br>Year:", Year,
        "<br>Deaths:", Total_Deaths,
        "<br>Affected:", Total_Affected,
        "<br>Damage (USD '000):", Total_Damage
      ),
      hoverinfo = "text"
    ) %>%
      layout(
        title = "Disaster Impact Over Time",
        xaxis = list(title = "Total Affected"),
        yaxis = list(title = "Total Damage (USD in '000s)", type = "log"),
        showlegend = TRUE
      ) %>%
      animation_opts(frame = 1000, transition = 400, redraw = TRUE)
  })
  output$mapPlot <- renderLeaflet({
    filtered_data <- disaster_data %>% filter(Type == input$selectedType)
    country_counts <- filtered_data %>%
      group_by(Country) %>%
      summarise(Count = n(), .groups = "drop")
    # Join counts with map data by country name
    map_data <- regions_spdf %>%
      left_join(country_counts, by = c("name" = "Country"))
    map_data$Count[is.na(map_data$Count)] <- 0
    domain_range <- if (all(map_data$Count == 0)) c(0, 1) else range(map_data$Count, na.rm = TRUE)
    pal <- colorNumeric("YlOrRd", domain = domain_range, na.color = "lightgray")
    leaflet(map_data, options = leafletOptions(zoomControl = FALSE)) %>%
      addTiles() %>%
      addPolygons(
        fillColor = ~pal(Count),
        fillOpacity = 0.7,
        color = "black",
        weight = 1,
        popup = ~paste0(name, ": ", Count, " disasters"),
        highlightOptions = highlightOptions(
          weight = 3,
          color = "#666",
          fillOpacity = 0.9,
          bringToFront = TRUE
        )
      ) %>%
      addLegend(pal = pal, values = map_data$Count, opacity = 0.7,
                title = "Disaster Count", position = "bottomright") %>%
      htmlwidgets::onRender("
function(el, x) {
var map = this;
L.control.zoom({ position: 'bottomright' }).addTo(map);
}
")
  })
  output$impactBubblePlot <- renderPlotly({
    impact_data <- disaster_data %>%
      group_by(Type) %>%
      summarise(
        Total_Deaths = sum(Deaths, na.rm = TRUE),
        Total_Damage = sum(Damage_USD, na.rm = TRUE),
        Total_Affected = sum(Affected, na.rm = TRUE)
      )
    max_affected <- max(impact_data$Total_Affected, na.rm = TRUE)
    plot_ly(
      data = impact_data,
      x = ~Total_Deaths,
      y = ~Total_Damage,
      size = ~Total_Affected,
      color = ~Type,
      type = "scatter",
      mode = "markers",
      text = ~paste(
        "Type:", Type,
        "<br>Deaths:", Total_Deaths,
        "<br>Damage (USD): $", format(Total_Damage, big.mark = ","),
        "<br>Affected:", Total_Affected
      ),
      sizes = c(20, 100),
      marker = list(
        sizemode = "area",
        sizeref = 2.0 * max_affected / (100^2),
        sizemin = 5,
        line = list(width = 1, color = '#FFFFFF'),
        opacity = 0.8
      )
    ) %>%
      layout(
        title = "Disaster Impact by Type",
        xaxis = list(title = "Total Deaths", type = "log"),
        yaxis = list(title = "Total Damage (USD)", type = "log"),
        legend = list(title = list(text = "Disaster Type"))
      )
  })
  output$animatedBubblePlot <- renderPlotly({
    plot_ly(
      data = disaster_data,
      x = ~Deaths,
      y = ~Damage_USD,
      size = ~Affected,
      frame = ~Year,
      color = ~Type,
      type = "scatter",
      mode = "markers",
      text = ~paste(
        "Year:", Year,
        "<br>Type:", Type,
        "<br>Deaths:", Deaths,
        "<br>Damage (USD): $", format(Damage_USD, big.mark = ","),
        "<br>Affected:", Affected
      ),
      sizes = c(10, 70),
      marker = list(sizemode = "area", sizeref = 0.1, sizemin = 3, line = list(width = 1, color = '#FFFFFF'))
    ) %>%
      layout(
        title = "Animated Disaster Impact by Year",
        xaxis = list(title = "Deaths", type = "log"),
        yaxis = list(title = "Damage (USD)", type = "log"),
        legend = list(title = list(text = "Disaster Type"))
      ) %>%
      animation_opts(frame = 1000, transition = 500, redraw = TRUE)
  })
}
shinyApp(ui = ui, server = server)