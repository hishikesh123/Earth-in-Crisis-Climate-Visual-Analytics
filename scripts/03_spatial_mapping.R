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
