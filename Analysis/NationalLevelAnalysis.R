# Load necessary packages
source('Code/0-LoadPackages.R')

# Load the data
TotalHomelessData <- read.csv('Data/StatePanel.csv') %>% 
                    as.data.frame() %>%
                    filter(state == "Total", year > 2013) %>%
                    mutate(year = make_date(year = year, month = 1, day = 1)) %>%
                    select(-c("state", "X"))

names(TotalHomelessData)[1] <- "Total Homeless Population"
names(TotalHomelessData)[2] <- "Chronically Homeless"
names(TotalHomelessData)[3] <- "Sheltered Chornically Homeless"

HomelessDataWide <- TotalHomelessData %>% pivot_longer(
  cols = -year,
  names_to = 'type',
  values_to = 'count'
) %>%
  mutate(
    count = as.numeric(count),
    count = round(count/1000,0),
    type = as.factor(type)
  )

UniqueTypes = as.character(unique(HomelessDataWide$type))

HomelessDataWide %>%
  ggplot(aes(year, count, col = type)) +
  geom_line(linewidth = 0.9) +
  theme_minimal(
    base_size = 12, 
    base_family = 'Source Sans Pro'
  ) +
  geom_rect(xmin = make_date(2020,1,1), xmax = make_date(2022,1,1),
            ymin = 0, ymax = Inf, alpha = .04, 
            fill="azure1", col = "azure1")+
  geom_text(
    data = HomelessDataWide %>% filter(year == make_date(2015,1,1),
                                       type == UniqueTypes[1]),
    aes(label = type),
    nudge = 1,
    hjust = 0.2,
    vjust = -1.0,
    fontface = 'bold',
    family = 'Source Sans Pro',
    color = "#262a18"
  ) +
  geom_text(
    data = HomelessDataWide %>% filter(year == make_date(2016,1,1),
                                       type == UniqueTypes[3]),
    aes(label = type),
    nudge = 1,
    hjust = 0.3,
    vjust = -0.5,
    fontface = 'bold',
    family = 'Source Sans Pro',
    color = "#366785"
  )+
  geom_text(
    data = HomelessDataWide %>% filter(year == make_date(2021,1,1),
                                       type == UniqueTypes[2]),
    aes(label = type),
    nudge = 1,
    hjust = 0.4,
    vjust = -2.8,
    fontface = 'bold',
    family = 'Source Sans Pro',
    color = "#c85200"
  )+
  theme(
    panel.grid.minor = element_blank(),
    panel.grid.major.x = element_blank(),
    panel.grid.major.y = element_line(linetype = 2,linewidth = 0.6),
    legend.position = "none",
    axis.text.y = ggtext::element_markdown(),
  ) +
  scale_color_manual(
    values = c("#c85200", "#262a18", "#366785")
  ) +
  labs(
    x = element_blank(), 
    y = element_blank(),
    title = 'Homelessness: A Problem That Refuses to Fade',
    subtitle = 'Point in Time (PIT) Count',
    caption = 'Source: US Department of Housing and Urban Development \n Continuum of Care Reports'
  ) +
scale_y_continuous(
  labels = scales::label_number(
    suffix = '<span style="font-size:8px;">K</span>'
  )) + 
  scale_x_date(expand = expansion(mult = c(0,0)),
                     labels = scales::label_date(format = "%Y"))
