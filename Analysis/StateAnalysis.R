# Load necessary packages
source('Code/0-LoadPackages.R')

# Load the data
HomelessChange <- read.csv('Data/StatePanel.csv') %>% 
  as.data.frame() %>%
  filter(year == 2013|year == 2023) %>%
  select(-c("X")) %>%
  select("overall_homeless", "state", "year") %>%
  group_by(state) %>%       # Group by state
  mutate(change = diff(overall_homeless, lag = 1, differences = 1)) %>%
  ungroup()

BestStates <- HomelessChange %>%
                filter(change >=0, 
                       year == 2023) %>%
                mutate(state = fct_lump_n(
                  state,
                  n = 10,
                  w = change,
                  other_level = "Other",
                )
                ) %>%
          summarise(
            change = sum(change),
            .by = state
          ) %>%
        mutate(
          change1 = if_else(state == "Other",-1,1)*change,
          state = fct_reorder(state,change1)
        ) 

bg_color <- colorspace::lighten("#366785", 1.3)
fill_color <- "#c85200"
line_and_text_color <- "#262a18"

BestStates %>%
  ggplot(aes(x=change,y = state)) +
  geom_col(
    fill = fill_color,
    width = 0.9,
  )+
  geom_text(aes(label = scales::comma(change)), position = position_dodge(0.9), 
            vjust=0.5,hjust = 1.2, colour = "white",size = 4,
            fontface = "bold") +
  theme_minimal(base_size = 12, base_family = "Source Sans Pro") +
  theme(
    panel.grid.major.y = element_blank(),
    panel.grid.minor.x = element_blank(),
    panel.grid.major.x = element_line(
      linetype = 2,
      color = "grey40",
      linewidth = 0.25
    ),
    plot.title = element_text(face = "bold"),
    plot.title.position = "plot",
    plot.caption.position = "plot",
    plot.background = element_rect(
      fill = bg_color,
      color = NA
    ),
    text = element_text(color = line_and_text_color),
    axis.text = element_text(color = line_and_text_color)
  ) +
  scale_x_continuous(
    expand = expansion(mult = c(0.005,0.05)),
    labels = scales::label_number(big.mark = ",")
  )+
  scale_y_discrete(
    expand = expansion(mult = c(0.005,0.005))
  )+
  labs(
    x = element_blank(),
    y = element_blank(),
    title = "Florida has done well to tackle homelessness",
    subtitle = "Decrease in the number of homeless between 2013 and 2023",
    caption = 'Source: US Department of Housing and Urban Development \n Continuum of Care Reports'
    
  )+ annotate("text", x = 12500, y = 2, 
              label = "NJ, IL, CT, MS, AL, ND, WI, AR, OH, \nVA, WV, NE, KY, IA, WY, TN, HI, IN, KS",
              size = 2.9, color = "#262a18", fontface ="bold")

# Do a US map now. 
StateChangeData <- HomelessChange %>%
                  filter(year == 2013) %>%
                  mutate(
                    fips = fips(state),
                    change = change * -1,
                    relative_change = round(change / overall_homeless *1,2)
                  )

p2 <- plot_usmap(data = StateChangeData, values = "relative_change",  color = "white", labels=FALSE) + 
  scale_fill_continuous(labels = scales::percent_format(accuracy = 2L)
  ) + 
  scale_color_brewer(palette = 'Oranges')+
  theme(
    legend.position = "top",
    text = element_text(
      size = 14,
      family = "Source Sans Pro"
    )
  )+
  labs(title = "Relative Change in the number of homeless between 2013 and 2023",
       subtitle = "Florida has done the best; CA has done the worst",
       fill = "Percentage change in homeless",
       caption = 'Source: US Department of Housing and Urban Development \n Continuum of Care Reports'
  ) +
  guides(
    fill = guide_colorbar(
      barwidth = unit(5,"cm"),
      barheight = unit(0.5,"cm"),
      title.position = "top"
    )
  )
p2
