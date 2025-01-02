# Load necessary packages and functions ---------------------------------------------------
source('Code/0-LoadPackages.R')  # Load required packages for data manipulation and visualization

# Load and preprocess the dataset --------------------------------------------------------
TotalHomelessData <- read.csv('Data/StatePanel.csv')  # Load the dataset

# Calculate Unsheltered Chronically Homeless Population -----------------------------------
UnshelteredData <- TotalHomelessData %>%
  group_by(state, year) %>%
  mutate(
    # Calculate unsheltered chronically homeless by subtracting sheltered numbers
    unsheltered_chronically_homeless = pmax(0, overall_chronically_homeless - sheltered_total_chronically_homeless)
  ) %>%
  ungroup() %>%
  select(state, year, unsheltered_chronically_homeless)  # Retain relevant columns

# Identify Top States for Visualization ---------------------------------------------------
TopStates <- UnshelteredData %>%
  filter(year == 2023, state != "Total") %>%  # Filter for 2023 data, exclude "Total"
  mutate(
    state_group = fct_lump_n(
      f = state,                                # Factor column for state names
      n = 5,                                   # Keep top 5 states by unsheltered count
      w = unsheltered_chronically_homeless,    # Use homeless count for weighting
      other_level = "Other States"            # Group others under "Other States"
    )
  ) %>%
  group_by(state_group) %>%
  summarise(
    unsheltered_chronically_homeless = sum(unsheltered_chronically_homeless)  # Aggregate counts
  )

# Record visualization for animation (optional) ------------------------------------------
camcorder::gg_record(
  dir = "img",   # Directory for saving the recording
  width = 1400,  # Width in pixels
  height = 1400, # Height in pixels
  units = "px",
  bg = "white",
  dpi = 300
)

# Aggregate and reorder data for plotting -------------------------------------------------
PlotData <- UnshelteredData %>%
  mutate(
    state_group = if_else(state %in% TopStates$state_group, state, "Other States")  # Group states
  ) %>%
  group_by(state_group, year) %>%
  summarise(
    unsheltered_chronically_homeless = sum(unsheltered_chronically_homeless)  # Aggregate counts
  ) %>%
  ungroup() %>%
  mutate(
    state_group = as.factor(state_group)  # Convert to factor
  )

# Ensure states are ordered in descending order for the plot -----------------------------
StateOrdering <- PlotData %>%
  filter(year == 2023) %>%
  arrange(desc(unsheltered_chronically_homeless)) %>%
  pull(state_group)  # Extract ordered state levels

PlotData$state_group <- factor(PlotData$state_group, levels = StateOrdering)  # Reorder factor levels

# Define custom color palette ------------------------------------------------------------
ColorPalette <- c(
  "#003f5c", "#2f4b7c", "#665191", "#a05195", 
  "#d45087", "#f95d6a", "#ff7c43", "#ffa600"
)

# Create the ggplot visualization --------------------------------------------------------
HomelessnessPlot <- PlotData %>%
  ggplot(aes(x = year, y = unsheltered_chronically_homeless, fill = state_group)) +
  geom_area() +
  theme_minimal(base_size = 12, base_family = 'Source Sans Pro') +
  theme(
    axis.text.x = element_text(face = "bold"),
    axis.text.y = element_text(face = "bold"),
    panel.grid.minor = element_blank(),
    panel.grid.major.x = element_blank(),
    panel.grid.major.y = element_blank(),
    legend.position = "top",
    legend.key.size = unit(0.01, 'cm'),
    legend.key.width = unit(0.3, 'cm'),
    legend.title = element_blank(),
    legend.key.height = unit(0.3, 'cm'),
    legend.text = element_text(size = 8, face = "bold"),
    legend.justification = "left",
    plot.title.position = "plot",
    plot.caption.position = "plot",
    plot.caption = element_text(size = 6, face = "bold", family = "Source Sans Pro"),
    plot.title = element_text(size = 20, family = "Source Sans Pro", face = "bold"),
    plot.subtitle = element_text(size = 12, family = "Source Sans Pro", face = "italic")
  ) +
  scale_fill_manual(values = ColorPalette) +
  scale_x_continuous(
    breaks = c(2011, 2014, 2017, 2020, 2023),
    labels = c("2011", "2014", "2017", "2020", "2023")
  ) +
  scale_y_continuous(
    expand = c(0, 0),
    labels = scales::label_comma(),
    limits = c(0, 200000),
    breaks = seq(0, 200000, 50000)
  ) +
  coord_cartesian(clip = "off") +
  labs(
    x = NULL,
    y = NULL,
    title = "Number of Chronically Homeless \nWho Remain Unsheltered",
    subtitle = "CA is the worst at addressing chronically homeless",
    caption = "Source: US Department of Housing and Urban Development \nContinuum of Care Reports"
  ) +
  guides(fill = guide_legend(title.position = "top", nrow = 1, label.position = "left")) +
  annotate(
    "segment",
    x = 2011, xend = 2011,
    y = 0, yend = 200000
  ) 

# Print the plot -------------------------------------------------------------------------
print(HomelessnessPlot)
