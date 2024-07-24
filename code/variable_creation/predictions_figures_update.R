
#### Setup ####

rm(list=ls())
setwd("C:/Users/giorg/OneDrive/Documenti/RA Silvia Pianta/Political Parties Climate Discourse")

library(rio)
library(lubridate)
library(stargazer)
library(ggplot2)
library(labelled)
library(countrycode)
library(viridis)
library(tidyverse)
library(tmap)
library(sp)
library(data.table)
library(readr)
library(rgdal)
library(RColorBrewer)
library(terra)
library(sf)
library(cartogram)
library(hrbrthemes)
library(scales)
library(zoo)
library(ggrepel)



#### Data cleaning ####

# Import manifesto data
import("Dati/manifesto_level_meta_24Jun24.csv") %>%
  mutate(iso2c = countrycode(country, origin = 'country.name', destination = 'iso2c')) %>%
  mutate(parfam_name = case_when(parfam_fixed == 10 ~ 'ECO',
                                 parfam_fixed==20 ~ 'LEF',
                                 parfam_fixed==30 ~ 'SOC',
                                 parfam_fixed==40 ~ 'LIB',
                                 parfam_fixed==50 ~ 'CHR',
                                 parfam_fixed==60 ~ 'CON',
                                 parfam_fixed==70 ~ 'NAT',
                                 parfam_fixed==80 ~ 'AGR',
                                 parfam_fixed==90 ~ 'ETH',
                                 parfam_fixed==95 ~ 'SIP',
                                 parfam_fixed==98 ~ 'DIV' ),
         parfam_name_full = case_when(parfam_fixed == 10 ~ 'Ecological',
                                      parfam_fixed==20 ~ 'Socialist and other left',
                                      parfam_fixed==30 ~ 'Social democratic',
                                      parfam_fixed==40 ~ 'Liberal',
                                      parfam_fixed==50 ~ 'Christian democratic',
                                      parfam_fixed==60 ~ 'Conservative',
                                      parfam_fixed==70 ~ 'Nationalist and radical right',
                                      parfam_fixed==80 ~ 'Agrarian',
                                      parfam_fixed==90 ~ 'Ethnic and regional',
                                      parfam_fixed==95 ~ 'Special issue parties',
                                      parfam_fixed==98 ~ 'DIV' )) -> predictions

# Average climate salience by year and country
predictions %>%
  dplyr::select(-date, -country)  %>%
  group_by(iso2c, year) %>%
  summarise(climate_broad_mean = mean(final_broad, na.rm=T),
            climate_broad_w_mean = sum(final_broad*(pervote))/
              (sum(pervote))) -> predictions_cy



#### Map old and new broad climate salience ####

# World countries
world <- st_as_sf(rnaturalearth::countries110)
# Europe
world %>%
  filter(REGION_UN == "Europe" & NAME != "Russia") %>%
  # Add unique ID column
  mutate(id = row_number(), .before = NAME_IT) -> europe

# Bounding box for continental Europe.
europe.bbox <- st_as_sf(SpatialPolygons(list(Polygons(list(Polygon(
  matrix(c(-25,29,45,29,45,70,-25,70,-25,29),byrow = T,ncol = 2)
)), ID = 1)), proj4string = CRS(proj4string(rnaturalearth::countries110))))

# Get polygons that are only in continental Europe.
europe.clipped <- st_intersection(europe, europe.bbox)

# Check
europe.clipped %>% ggplot() + geom_sf()

# Retain only relevant variables and clean
europe.clipped %>%
  dplyr::select(GEOUNIT, NAME_LONG, ISO_A2) %>%
  rename(iso2c = ISO_A2, name_long = NAME_LONG,
         geounit = GEOUNIT) %>%
  # Fix France and Norway
  mutate(iso2c = case_when(geounit == "France" ~  "FR",
                           geounit == "Norway" ~  "NO", .default = iso2c)) -> europe.tidy


### Map climate salience in the oldest and most recent election by country

# Prepare
predictions_cy %>%
  group_by(iso2c) %>%
  filter(year == min(year) | year == max(year)) %>%
  mutate(election = case_when(year == min(year) ~ 1,
                              year == max(year) ~ 2),
         election_label = case_when(election == 1 
                                    ~ "Oldest elections (1990-2006)",
                                    election == 2 
                                    ~ "Most recent elections (2013-2021)"),
         election_label = reorder(election_label, election)
         ) -> for_plot
dplyr::full_join(europe.tidy, for_plot, by = "iso2c") %>%
  filter(!is.na(election)) -> for_plot

# Check time range of oldest elections and most recent elections
for_plot %>%
  group_by(election) %>%
  summarise(min_year = min(year), max_year = max(year)) -> check
# View(check)

# Map (Mean climate salience)
for_plot %>%
  ggplot() +
  geom_sf(data = europe.tidy) +
  geom_sf(aes(fill = climate_broad_mean)) +
  facet_wrap(~election_label) + theme_void() +
  scale_fill_viridis_c(name = "Climate salience in manifestos",
                       direction = -1,
                       limits = c(0, .1),
                       oob = squish,
                       guide = guide_colorbar(barwidth = unit(50, units = "mm"),
                                              barheight = unit(4, units = "mm"),
                                              title.position = 'top',
                                              title.theme = element_text(size=10),
                                              title.hjust = 0.4,
                                              nrow = 1, ticks = FALSE)) +
  theme(legend.position = "bottom")
ggsave("Figures/clim_salience_map_time.png",
       width = 6.41, height = 3.67
       )

# Map (Climate salience weighed by vote share)
for_plot %>%
  ggplot() +
  geom_sf(data = europe.tidy) +
  geom_sf(aes(fill = climate_broad_w_mean)) +
  facet_wrap(~election_label) + theme_void() +
  scale_fill_viridis_c(name = "Climate salience in manifestos",
                       direction = -1,
                       limits = c(0, .1),
                       oob = squish,
                       guide = guide_colorbar(barwidth = unit(50, units = "mm"),
                                              barheight = unit(4, units = "mm"),
                                              title.position = 'top',
                                              title.theme = element_text(size=10),
                                              title.hjust = 0.4,
                                              nrow = 1, ticks = FALSE)) +
  theme(legend.position = "bottom")
ggsave("Figures/clim_salience_w_map_time.png",
       width = 6.41, height = 3.67
)



#### Plot time trends of salience by country, left-right ####


### Left-Right based on party score

# Clean
summary(predictions$rile)
predictions %>%
  mutate(pol_orientation = case_when(rile < 0 ~  "Left-wing parties",
                                     rile > 0 ~  "Right-wing parties")) %>%
  filter(!is.na(pol_orientation)) %>%
  group_by(iso2c, year, pol_orientation, country) %>%
  summarise(climate_broad_mean = mean(final_broad, na.rm=T),
            climate_broad_w_mean = sum(final_broad*(pervote))/
              (sum(pervote))) -> for_plot

# Plot
for_plot %>%
  ggplot() +
  geom_line(aes(x = year, y = climate_broad_mean, color = pol_orientation),
            lwd = 0.6) +
  facet_wrap(~country, ncol = 7) +
  scale_color_discrete(name = "Type of party",
                       guide = guide_legend(title.position = "top",
                                            title.hjust = 0.5)) +
  scale_x_continuous(breaks = c(1992, 2005, 2017)) +
  theme(legend.position = "bottom", axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        panel.border = element_rect(colour="black", fill = 'transparent'),
        panel.background= element_rect(fill = 'transparent'),
        legend.background=element_rect(fill = 'transparent'),
        legend.key=element_rect(fill = 'transparent'),
        strip.background=element_rect(fill = 'transparent'))
ggsave("Figures/climate_rile.png",
       width = 6.78, height = 5.02
       )


### Left-Right-Green parties

# Clean
predictions %>%
  mutate(pol_orientation = case_when(rile < 0 & parfam_name != "ECO"
                                     ~  "Left-wing parties",
                                     rile > 0 & parfam_name != "ECO"
                                     ~  "Right-wing parties",
                                     parfam_name == "ECO" ~ "Green parties")) %>%
  filter(!is.na(pol_orientation)) %>%
  group_by(iso2c, year, pol_orientation, country) %>%
  summarise(climate_broad_mean = mean(final_broad, na.rm=T),
            climate_broad_w_mean = sum(final_broad*(pervote))/
              (sum(pervote))) -> for_plot

# Plot
for_plot %>%
  ggplot() +
  geom_line(aes(x = year, y = climate_broad_mean, color = pol_orientation),
            lwd = 0.6) +
  facet_wrap(~country, ncol = 7) +
  scale_color_manual(values = c("Green parties" = "#009900",
                                "Left-wing parties" = "red",
                                "Right-wing parties" = "blue"),
                     name = "Type of party",
                     guide = guide_legend(title.position = "top",
                                            title.hjust = 0.5)) +
  scale_x_continuous(breaks = c(1992, 2005, 2017)) +
  theme(legend.position = "bottom", axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        panel.border = element_rect(colour="black", fill = 'transparent'),
        panel.background= element_rect(fill = 'transparent'),
        legend.background=element_rect(fill = 'transparent'),
        legend.key=element_rect(fill = 'transparent'),
        strip.background=element_rect(fill = 'transparent'))
ggsave("Figures/climate_rile_green.png",
       width = 6.78, height = 5.02
)


### Only salience by country, no left-right division

# Plot
predictions_cy %>%
  ggplot() +
  geom_line(aes(x = year, y = climate_broad_mean, color = iso2c)) +
  facet_wrap(~iso2c) +
  theme(legend.position = "none", 
        panel.border = element_rect(colour="black", fill = 'transparent'),
        panel.background= element_rect(fill = 'transparent'),
        legend.background=element_rect(fill = 'transparent'),
        legend.key=element_rect(fill = 'transparent'),
        strip.background=element_rect(fill = 'transparent')) +
  scale_x_continuous(breaks = c(1992, 2005, 2018)) +
  xlab("Year") + ylab("Salience of Climate Change")
ggsave("Figures/climate_by_country.png",
       width = 6.05, height = 4.56
)



#### Plot stacked time trends of salience by party family ####

# Clean
predictions %>%
  # Sum salience by year and party family and count the n. of parties by
  # party family
  mutate(party_n = 1) %>%
  group_by(year, parfam_name, parfam_name_full) %>%
  summarise(salience = mean(final_broad, na.rm = T),
            salience_sd = sd(final_broad, na.rm = T)) %>%
  mutate(salience_sd = case_when(is.na(salience_sd) ~ 0,
                                 .default = salience_sd)) -> predictions_pfy

# Fill holes with zero
cbind(year = c(1990, 1990, 2021, 2021),
      parfam_name = c("AGR", "SIP", "CON", "ETH"),
      salience = c(0, 0, 0, 0),
      salience_sd = c(0, 0, 0, 0)) %>% as.data.frame() %>%
  mutate(year = as.numeric(year), salience = as.numeric(salience),
         salience_sd = as.numeric(salience_sd)) -> fill
rbind(predictions_pfy, fill) -> predictions_pfy
  
# Compute rolling average
predictions_pfy %>%
  group_by(parfam_name, parfam_name_full) %>% arrange(year) %>%
  mutate(salience_sm5 = zoo::rollmean(salience, k = 4, fill = salience)
  ) -> predictions_pfy

# # Smooth out the edges
# predictions_pfy %>%
#   group_by(parfam_name) %>% arrange(year) %>%
#   mutate(salience_sm5 = case_when(year == 1990 ~ (salience+lead(salience)+lead(salience,n=2))/3,
#                                   year == 1991 ~ (lag(salience)+salience+lead(salience)+lead(salience,n=2))/4,
#                                   year == 2020 ~ (lag(salience,n=2)+lag(salience)+salience+lead(salience))/4,
#                                   year == 2021 ~ (lag(salience,n=2)+lag(salience)+salience)/3,
#                                   .default = salience_sm5)) -> predictions_pfy


### Stacked plot with alphabetical ordering

# Prepare
predictions_pfy %>%
  mutate(parfam_name = factor(parfam_name,
                              levels = c("SOC", "SIP", "NAT", "LIB", "LEF", "ETH",
                                         "ECO", "DIV", "CON", "CHR", "AGR"))) %>%
  # Drop "DIV" party family (too few observations) 
  filter(parfam_name != "DIV") -> for_plot

# Plot
for_plot %>%
  ggplot() +
  geom_area(aes(x = year, y = salience_sm5, fill = parfam_name)) +
  scale_fill_viridis_d(name = "Party family", option = "H", direction = -1,
                       guide = guide_legend(nrow = 2, title.position = "top",
                                            title.hjust = 0.5)) +
  theme(panel.background = element_rect(fill = "transparent"),
        panel.grid = element_line(colour = "grey"),
        legend.position = "bottom") +
  xlab("Year") + ylab("Salience of Climate Change")
ggsave("Figures/party_fam_stacked.png",
       width = 6.05, height = 4.56
       )


### Stacked plot with right-left political orientation

# Prepare
predictions %>%
  group_by(parfam_name) %>%
  summarise(avg_rile = mean(rile, na.rm = T)) %>%
  arrange(avg_rile) -> order
predictions_pfy %>%
  mutate(parfam_name = factor(parfam_name,
                              levels = c("ECO", order$parfam_name[-2]))) %>%
  # Drop "DIV" party family (too few observations)
  filter(parfam_name != "DIV") -> for_plot

# Plot
for_plot %>%
  ggplot() +
  geom_area(aes(x = year, y = salience_sm5, fill = parfam_name)) +
  scale_fill_manual(values = c("ECO" = "#00B050",
                               "LEF" = "#7A0403FF",
                               "SOC" = "#CB2A04FF",
                               "ETH" = "#F66B19FF",
                               "SIP" = "#FABA39FF",
                               "AGR" = "#C7EF34FF",
                               "LIB" = "#1AE4B6FF",
                               "CHR" = "#36AAF9FF",
                               "CON" = "#4662D7FF",
                               "NAT" = "#30123BFF"),
                    aesthetics = "fill",
                    name = "Party family",
                    guide = guide_legend(nrow = 2, title.position = "top",
                                            title.hjust = 0.5)) +
  theme(panel.background = element_rect(fill = "transparent"),
        panel.grid = element_line(colour = "grey"),
        legend.position = "bottom") +
  xlab("Year") + ylab("Salience of Climate Change") 
ggsave("Figures/party_fam_stacked_rile.png",
       width = 6.05, height = 4.56
       )



#### Plot time trends of salience by party family ####

# Clean
predictions %>%
  # Sum salience by year and party family and count the n. of parties by
  # party family
  mutate(party_n = 1) %>%
  group_by(year, parfam_name, parfam_name_full) %>%
  summarise(salience = mean(final_broad, na.rm = T),
            salience_sd = sd(final_broad, na.rm = T)) %>%
  mutate(salience_sd = case_when(is.na(salience_sd) ~ 0,
                                 .default = salience_sd)) -> predictions_pfy

# Compute rolling average
predictions_pfy %>%
  group_by(parfam_name, parfam_name_full) %>% arrange(year) %>%
  mutate(salience_sm5 = zoo::rollmean(salience, k = 4, fill = salience)
  ) -> predictions_pfy


### Line graph

# Prepare
predictions %>%
  group_by(parfam_name) %>%
  summarise(avg_rile = mean(rile, na.rm = T)) %>%
  arrange(avg_rile) -> order
predictions_pfy %>%
  mutate(parfam_name = factor(parfam_name,
                              levels = c("ECO", order$parfam_name[-2]))) -> for_plot
  
# Plot
for_plot %>%
  ggplot() +
  geom_line(aes(x = year, y = salience_sm5, color = parfam_name)) +
  scale_color_manual(values = c("ECO" = "#00B050",
                                "LEF" = "#7A0403FF",
                                "SOC" = "#CB2A04FF",
                                "ETH" = "#F66B19FF",
                                "SIP" = "#FABA39FF",
                                "AGR" = "#C7EF34FF",
                                "LIB" = "#1AE4B6FF",
                                "CHR" = "#36AAF9FF",
                                "CON" = "#4662D7FF",
                                "NAT" = "#30123BFF"),
                    aesthetics = "color",
                    name = "Party family",
                    guide = guide_legend(nrow = 2, title.position = "top",
                                         title.hjust = 0.5)) +
  theme(panel.background = element_rect(fill = "transparent"),
        legend.position = "bottom", legend.key = element_blank()) +
  xlab("Year") + ylab("Salience of Climate Change") 
ggsave("Figures/party_fam_line.png",
       width = 6.05, height = 4.56
       )


### Line graph wrapped by party family

# Prepare
predictions %>%
  group_by(parfam_name, parfam_name_full) %>%
  summarise(avg_rile = mean(rile, na.rm = T)) %>%
  arrange(avg_rile) -> order
predictions_pfy %>%
  mutate(parfam_name = factor(parfam_name,
                              levels = c("ECO", order$parfam_name[-2])),
         parfam_name_full = factor(parfam_name_full,
                                   levels = c("Ecological", order$parfam_name_full[-2]))) %>%
  # Drop "DIV" party family (too few observations)
  filter(parfam_name != "DIV") -> for_plot

# Plot V1
for_plot %>%
  ggplot() +
  geom_line(aes(x = year, y = salience_sm5, color = parfam_name)) +
  facet_wrap(~ parfam_name, ncol = 5) +
  scale_color_manual(values = c("ECO" = "#00B050",
                                "LEF" = "#7A0403FF",
                                "SOC" = "#CB2A04FF",
                                "ETH" = "#F66B19FF",
                                "SIP" = "#FABA39FF",
                                "AGR" = "#C7EF34FF",
                                "LIB" = "#1AE4B6FF",
                                "CHR" = "#36AAF9FF",
                                "CON" = "#4662D7FF",
                                "NAT" = "#30123BFF"),
                     aesthetics = "color",
                     name = "Party family",
                     guide = guide_legend(nrow = 2, title.position = "top",
                                          title.hjust = 0.5)) +
  scale_x_continuous(breaks = c(1992, 2005, 2018)) +
  theme(legend.position = "bottom", 
        panel.border = element_rect(colour="black", fill = 'transparent'),
        panel.background= element_rect(fill = 'transparent'),
        legend.background=element_rect(fill = 'transparent'),
        legend.key=element_rect(fill = 'transparent'),
        strip.background=element_rect(fill = 'transparent')) +
  xlab("Year") + ylab("Salience of Climate Change") 
ggsave("Figures/party_fam_line_wrapped_v1.png",
       width = 6.05, height = 4.56
       )

# Plot (full party family names in the legend)
for_plot %>%
  ggplot() +
  geom_line(aes(x = year, y = salience_sm5, color = parfam_name_full)) +
  facet_wrap(~ parfam_name, ncol = 5) +
  scale_color_manual(values = c("Ecological" = "#00B050",
                                "Socialist and other left" = "#7A0403FF",
                                "Social democratic" = "#CB2A04FF",
                                "Ethnic and regional" = "#F66B19FF",
                                "Special issue parties" = "#FABA39FF",
                                "Agrarian" = "#C7EF34FF",
                                "Liberal" = "#1AE4B6FF",
                                "Christian democratic" = "#36AAF9FF",
                                "Conservative" = "#4662D7FF",
                                "Nationalist and radical right" = "#30123BFF"),
                     aesthetics = "color",
                     name = "Party family",
                     guide = guide_legend(nrow = 4, title.position = "top",
                                          title.hjust = 0.5)) +
  scale_x_continuous(breaks = c(1992, 2005, 2018)) +
  theme(legend.position = "bottom", 
        panel.border = element_rect(colour="black", fill = 'transparent'),
        panel.background= element_rect(fill = 'transparent'),
        legend.background=element_rect(fill = 'transparent'),
        legend.key=element_rect(fill = 'transparent'),
        strip.background=element_rect(fill = 'transparent')) +
  xlab("Year") + ylab("Salience of Climate Change") 
ggsave("Figures/party_fam_line_wrapped_v2.png",
       width = 6.05, height = 4.56
       )

# Plot (full party family names in the wrap and legend)
for_plot %>%
  filter(!is.na(parfam_name_full)) %>%
  ggplot() +
  geom_line(aes(x = year, y = salience_sm5, color = parfam_name_full)) +
  facet_wrap(~ parfam_name_full, ncol = 5) +
  scale_color_manual(values = c("Ecological" = "#00B050",
                                "Socialist and other left" = "#7A0403FF",
                                "Social democratic" = "#CB2A04FF",
                                "Ethnic and regional" = "#F66B19FF",
                                "Special issue parties" = "#FABA39FF",
                                "Agrarian" = "#C7EF34FF",
                                "Liberal" = "#1AE4B6FF",
                                "Christian democratic" = "#36AAF9FF",
                                "Conservative" = "#4662D7FF",
                                "Nationalist and radical right" = "#30123BFF"),
                     aesthetics = "color",
                     name = "Party family",
                     guide = guide_legend(nrow = 4, title.position = "top",
                                          title.hjust = 0.5)) +
  scale_x_continuous(breaks = c(1992, 2005, 2018)) +
  theme(legend.position = "bottom", 
        panel.border = element_rect(colour="black", fill = 'transparent'),
        panel.background= element_rect(fill = 'transparent'),
        legend.background=element_rect(fill = 'transparent'),
        legend.key=element_rect(fill = 'transparent'),
        strip.background=element_rect(fill = 'transparent')) +
  xlab("Year") + ylab("Salience of Climate Change") 
ggsave("Figures/party_fam_line_wrapped_v3.png",
       width = 6.05, height = 4.56
)


### Line graph wrapped by party family and with shaded area behind

# Prepare
predictions %>%
  group_by(parfam_name, parfam_name_full) %>%
  summarise(avg_rile = mean(rile, na.rm = T)) %>%
  arrange(avg_rile) -> order
predictions_pfy %>%
  mutate(parfam_name = factor(parfam_name,
                              levels = c("ECO", order$parfam_name[-2])),
         parfam_name_full = factor(parfam_name_full,
                                   levels = c("Ecological", order$parfam_name_full[-2]))) %>%
  # Drop "DIV" party family (too few observations)
  filter(parfam_name != "DIV") %>%
  # Add interval of -10%/+10% standard deviation
  mutate(salience_min_1sd = salience-(salience_sd),
         salience_max_1sd = salience+(salience_sd),
         salience_min_2sd = salience-(salience_sd*2),
         salience_max_2sd = salience+(salience_sd*2),
         salience_sm5_min_1sd = salience_sm5-(salience_sd),
         salience_sm5_max_1sd = salience_sm5+(salience_sd),
         salience_sm5_min_2sd = salience_sm5-(salience_sd*2),
         salience_sm5_max_2sd = salience_sm5+(salience_sd*2)) -> for_plot

# Plot (full party family names in the legend) - 1 Standard deviation
for_plot %>%
  ggplot() +
  geom_ribbon(aes(x = year, ymin = salience_sm5_min_1sd,
                  ymax = salience_sm5_max_1sd, fill = parfam_name_full),
              alpha = 0.4) +
  geom_line(aes(x = year, y = salience_sm5, color = parfam_name_full)) +
  facet_wrap(~ parfam_name, ncol = 5) +
  scale_color_manual(values = c("Ecological" = "#00B050",
                                "Socialist and other left" = "#7A0403FF",
                                "Social democratic" = "#CB2A04FF",
                                "Ethnic and regional" = "#F66B19FF",
                                "Special issue parties" = "#FABA39FF",
                                "Agrarian" = "#C7EF34FF",
                                "Liberal" = "#1AE4B6FF",
                                "Christian democratic" = "#36AAF9FF",
                                "Conservative" = "#4662D7FF",
                                "Nationalist and radical right" = "#30123BFF"),
                     aesthetics = c("color", "fill"),
                     name = "Party family",
                     guide = guide_legend(nrow = 4, title.position = "top",
                                          title.hjust = 0.5)) +
  scale_x_continuous(breaks = c(1992, 2005, 2018)) +
  guides(fill="none") +
  theme(legend.position = "bottom", 
        panel.border = element_rect(colour="black", fill = 'transparent'),
        panel.background= element_rect(fill = 'transparent'),
        legend.background=element_rect(fill = 'transparent'),
        legend.key=element_rect(fill = 'transparent'),
        strip.background=element_rect(fill = 'transparent')) +
  xlab("Year") + ylab("Salience of Climate Change") 
ggsave("Figures/party_fam_line_wrapped_intervals_1sd.png",
       width = 6.05, height = 4.56
)

# Plot (full party family names in the legend) - 2 Standard deviations
for_plot %>%
  ggplot() +
  geom_ribbon(aes(x = year, ymin = salience_sm5_min_2sd,
                  ymax = salience_sm5_max_2sd, fill = parfam_name_full),
              alpha = 0.4) +
  geom_line(aes(x = year, y = salience_sm5, color = parfam_name_full)) +
  facet_wrap(~ parfam_name, ncol = 5) +
  scale_color_manual(values = c("Ecological" = "#00B050",
                                "Socialist and other left" = "#7A0403FF",
                                "Social democratic" = "#CB2A04FF",
                                "Ethnic and regional" = "#F66B19FF",
                                "Special issue parties" = "#FABA39FF",
                                "Agrarian" = "#C7EF34FF",
                                "Liberal" = "#1AE4B6FF",
                                "Christian democratic" = "#36AAF9FF",
                                "Conservative" = "#4662D7FF",
                                "Nationalist and radical right" = "#30123BFF"),
                     aesthetics = c("color", "fill"),
                     name = "Party family",
                     guide = guide_legend(nrow = 4, title.position = "top",
                                          title.hjust = 0.5)) +
  scale_x_continuous(breaks = c(1992, 2005, 2018)) +
  guides(fill="none") +
  theme(legend.position = "bottom", 
        panel.border = element_rect(colour="black", fill = 'transparent'),
        panel.background= element_rect(fill = 'transparent'),
        legend.background=element_rect(fill = 'transparent'),
        legend.key=element_rect(fill = 'transparent'),
        strip.background=element_rect(fill = 'transparent')) +
  xlab("Year") + ylab("Salience of Climate Change") 
ggsave("Figures/party_fam_line_wrapped_intervals_2sd.png",
       width = 6.05, height = 4.56
)



#### Scatter right-left score and climate change salience ####


### Scatter of right-left score and salience at the manifesto level

# No trend line
predictions %>% 
  ggplot(aes(x = rile, y = final_broad)) +
  geom_point() +
  labs(x = "Right-Left score", y = "Salience of Climate Change") +
  theme(panel.background = element_blank(),
        panel.border = element_rect(color = "black", fill = "transparent"),
        panel.grid = element_line(color = "grey"))
ggsave("Figures/scatter_rile_salience.png",
       height = 4.28, width = 6.51)
  
# Trend line
predictions %>% 
  ggplot(aes(x = rile, y = final_broad)) +
  geom_point() +
  geom_smooth(method = "lm", color = "#C00000") +
  labs(x = "Right-Left score", y = "Salience of Climate Change") +
  theme(panel.background = element_blank(),
        panel.border = element_rect(color = "black", fill = "transparent"),
        panel.grid = element_line(color = "grey"))
ggsave("Figures/scatter_rile_salience_tl.png",
       height = 4.28, width = 6.51)


### Scatter of right-left score and salience for manifestos from the most
### recent election

# No trend line
predictions %>%
  group_by(country, party) %>% 
  filter(year == max(year)) %>%
  ggplot(aes(x = rile, y = final_broad)) +
  geom_point() +
  labs(x = "Right-Left score", y = "Salience of Climate Change") +
  theme(panel.background = element_blank(),
        panel.border = element_rect(color = "black", fill = "transparent"),
        panel.grid = element_line(color = "grey"))
ggsave("Figures/scatter_rile_salience_lastele.png",
       height = 4.28, width = 6.51)

# Trend line
predictions %>% 
  group_by(country, party) %>% 
  filter(year == max(year)) %>%
  ggplot(aes(x = rile, y = final_broad)) +
  geom_point() +
  geom_smooth(method = "lm", color = "#C00000") +
  labs(x = "Right-Left score", y = "Salience of Climate Change") +
  theme(panel.background = element_blank(),
        panel.border = element_rect(color = "black", fill = "transparent"),
        panel.grid = element_line(color = "grey"))
ggsave("Figures/scatter_rile_salience_tl_lastele.png",
       height = 4.28, width = 6.51)


### Scatter of salience and right-left score at the party level (average of
### manifesto scores across years for each party)

# No trend line
predictions %>%
  group_by(country, party) %>% 
  summarise(rile = mean(rile, na.rm = T),
            final_broad = mean(final_broad, na.rm = T)) %>%
  ggplot(aes(x = rile, y = final_broad)) +
  geom_point() +
  labs(x = "Right-Left score", y = "Salience of Climate Change") +
  theme(panel.background = element_blank(),
        panel.border = element_rect(color = "black", fill = "transparent"),
        panel.grid = element_line(color = "grey"))
ggsave("Figures/scatter_rile_salience_avg.png",
       height = 4.28, width = 6.51)

# Trend line
predictions %>% 
  group_by(country, party) %>% 
  summarise(rile = mean(rile, na.rm = T),
            final_broad = mean(final_broad, na.rm = T)) %>%
  ggplot(aes(x = rile, y = final_broad)) +
  geom_point() +
  geom_smooth(method = "lm", color = "#C00000") +
  labs(x = "Right-Left score", y = "Salience of Climate Change") +
  theme(panel.background = element_blank(),
        panel.border = element_rect(color = "black", fill = "transparent"),
        panel.grid = element_line(color = "grey"))
ggsave("Figures/scatter_rile_salience_tl_avg.png",
       height = 4.28, width = 6.51)


### Scatter of salience and right-left score with refined level of detail

# Prepare
rbind(c("DK", "Northern Europe"), c("FI", "Northern Europe"),
      c("LT", "Northern Europe"), c("LV", "Northern Europe"),
      c("EE", "Northern Europe"), c("FR", "Western Europe"),
      c("DE", "Western Europe"), c("BE", "Western Europe"),
      c("IE", "Western Europe"), c("GB", "Western Europe"), 
      c("NL", "Western Europe"), c("LU", "Western Europe"),
      c("AT", "Western Europe"), c("IT", "Southern Europe"),
      c("ES", "Southern Europe"), c("GR", "Southern Europe"),
      c("PT", "Southern Europe"), c("CY", "Southern Europe"),
      c("SE", "Northern Europe"), c("SI", "Central and Eastern Europe"),
      c("BG", "Central and Eastern Europe"),
      c("HR", "Central and Eastern Europe"),
      c("CZ", "Central and Eastern Europe"),
      c("HU", "Central and Eastern Europe"),
      c("PL", "Central and Eastern Europe"),
      c("RO", "Central and Eastern Europe"),
      c("SK", "Central and Eastern Europe")) %>%
  as.data.frame() -> regions
colnames(regions) <- c("iso2c", "region")
predictions %>% left_join(regions, by = "iso2c") %>%
  mutate(region = factor(region, levels = c("Northern Europe",
                                            "Western Europe",
                                            "Central and Eastern Europe",
                                            "Southern Europe"))) -> for_plot

# Manifesto level, color coding based on regions
for_plot %>%
  ggplot(aes(x = rile, y = final_broad)) +
  geom_point(aes(color = region)) +
  labs(x = "Right-Left score", y = "Salience of Climate Change") +
  scale_color_viridis_d(option = "H", begin = 0.2, end = 0.8,
                        name = "Regions",
                        guide = guide_legend(title.position = "top",
                                             title.hjust = 0.5, nrow = 2)) +
  theme(panel.background = element_blank(), legend.position = "bottom",
        panel.border = element_rect(color = "black", fill = "transparent"),
        panel.grid = element_line(color = "grey"), legend.key = element_blank())
ggsave("Figures/scatter_rile_salience_reg.png",
       height = 4.28, width = 6.51)

# Party level (avg), color coding based on regions
for_plot %>%
  group_by(country, region, party) %>%
  summarise(rile = mean(rile, na.rm = T),
            final_broad = mean(final_broad, na.rm = T)) %>%
  ggplot(aes(x = rile, y = final_broad)) +
  geom_point(aes(color = region)) +
  labs(x = "Right-Left score", y = "Salience of Climate Change") +
  scale_color_viridis_d(option = "H", begin = 0.2, end = 0.8,
                        name = "Regions",
                        guide = guide_legend(title.position = "top",
                                             title.hjust = 0.5, nrow = 2)) +
  theme(panel.background = element_blank(), legend.position = "bottom",
        panel.border = element_rect(color = "black", fill = "transparent"),
        panel.grid = element_line(color = "grey"), legend.key = element_blank())


## Single out specific parties

# Prepare
for_plot %>%
  group_by(country, region, party, partyname) %>%
  summarise(rile = mean(rile, na.rm = T),
            final_broad = mean(final_broad, na.rm = T)) -> check
  
# Check
check %>%
  filter(final_broad > 0.15) %>% View()
check %>%
  filter(rile > 37 & final_broad < 0.05) %>% View()

# Movement Now (Finland)
finland <- check %>% filter(country == "Finland" & final_broad > 0.15)
# 5SM (Italy)
italy <- check %>% filter(country == "Italy" & final_broad > 0.15)
# Chega (Portugal)
portugal <- check %>% filter(country == "Portugal" & final_broad < 0.02)
# Liberal Forum (Austria) 
austria <- check %>% filter(country == "Austria" & partyname == "Liberal Forum")

# Plot (V1)
for_plot %>%
  group_by(country, region, party) %>%
  summarise(rile = mean(rile, na.rm = T),
            final_broad = mean(final_broad, na.rm = T)) %>%
  ggplot(aes(x = rile, y = final_broad)) +
  geom_point(aes(color = region)) +
  geom_text(data = italy, label = "5SM (Italy)", size = 3, nudge_x = 7) +
  geom_text(data = finland, label = "Movement Now \n(Finland)", size = 3,
            nudge_x = -9, lineheight = 0.9) +
  geom_text(data = portugal, label = "Chega \n(Portugal)", size = 3,
            nudge_y = 0.013, lineheight = 0.9) +
  geom_smooth(method = "lm", color = "#002060") +
  labs(x = "Right-Left score", y = "Salience of Climate Change") +
  scale_color_viridis_d(option = "H", begin = 0.2, end = 0.8,
                        name = "Regions",
                        guide = guide_legend(title.position = "top",
                                             title.hjust = 0.5, nrow = 2)) +
  theme(panel.background = element_blank(), legend.position = "bottom",
        panel.border = element_rect(color = "black", fill = "transparent"),
        panel.grid = element_line(color = "grey"), legend.key = element_blank())
ggsave("Figures/scatter_rile_salience_reg_details.png",
       height = 5.16, width = 6.33)

# Plot (V2)
for_plot %>%
  group_by(country, region, party) %>%
  summarise(rile = mean(rile, na.rm = T),
            final_broad = mean(final_broad, na.rm = T)) %>%
  ggplot(aes(x = rile, y = final_broad)) +
  geom_point(aes(color = region)) +
  geom_text(data = italy, label = "5SM (Italy)", size = 3, nudge_x = 7) +
  geom_text(data = finland, label = "Movement Now \n(Finland)", size = 3,
            nudge_x = -9, lineheight = 0.9) +
  geom_text_repel(data = portugal, label = "Chega \n(Portugal)", size = 3,
            nudge_y = 0.025, nudge_x = -4, lineheight = 0.9) +
  geom_text_repel(data = austria, label = "Liberal Forum \n(Austria)", size = 3,
                  nudge_y = 0.05, nudge_x = 3, lineheight = 0.9) +
  geom_smooth(method = "lm", color = "#002060") +
  labs(x = "Right-Left score", y = "Salience of Climate Change") +
  scale_color_viridis_d(option = "H", begin = 0.2, end = 0.8,
                        name = "Regions",
                        guide = guide_legend(title.position = "top",
                                             title.hjust = 0.5, nrow = 2)) +
  theme(panel.background = element_blank(), legend.position = "bottom",
        panel.border = element_rect(color = "black", fill = "transparent"),
        panel.grid = element_line(color = "grey"), legend.key = element_blank())
ggsave("Figures/scatter_rile_salience_reg_details_v2.png",
       height = 5.16, width = 6.33)



#### Plot time trends of salience, env. and sustain. by country ####


### Wrapped plot

# Clean
predictions %>%
  group_by(iso2c, year, country) %>%
  rename("environment" = "501_meta_dec",
         "sustainability" = "416_meta_dec") %>%
  summarise(climate_mean = mean(final_broad, na.rm=T),
            climate_sd = sd(final_broad, na.rm = T),
            environment_mean = mean(environment, na.rm = T),
            environment_sd = sd(environment, na.rm = T),
            sustainability_mean = mean(sustainability, na.rm = T),
            sustainability_sd = mean(sustainability, na.rm = T)) %>%
  pivot_longer(cols = !c("iso2c", "year", "country"),
               names_to = c("variable", ".value"), names_sep = "_") %>% 
  mutate(name = case_when(variable == "climate" ~ "Salience of climate change",
                          variable == "environment" ~ "Environment 501",
                          variable == "sustainability" ~ "Sustainability 416"),
         name = factor(name, levels = c("Salience of climate change",
                                        "Environment 501",
                                        "Sustainability 416"))) -> for_plot

# Plot
for_plot %>%
  ggplot() +
  geom_line(aes(x = year, y = mean, color = name),
            lwd = 0.6) +
  facet_wrap(~country, ncol = 7) +
  scale_x_continuous(breaks = c(1992, 2005, 2017)) +
  theme(legend.position = "bottom", axis.title.x = element_blank(),
        legend.title = element_blank(),
        axis.title.y = element_blank(),
        panel.border = element_rect(colour="black", fill = 'transparent'),
        panel.background= element_rect(fill = 'transparent'),
        legend.background=element_rect(fill = 'transparent'),
        legend.key=element_rect(fill = 'transparent'),
        strip.background=element_rect(fill = 'transparent'))
ggsave("Figures/climate_env_sust_cy.png",
       width = 6.78, height = 4.39
)

# Plot (with shaded areas corresponding to +/- 1 standard deviation)
for_plot %>%
  ggplot() +
  geom_line(aes(x = year, y = mean, color = variable),
            lwd = 0.6) +
  geom_ribbon(aes(x = year, ymin = (mean - sd),  ymax = (mean + sd),
                  fill = variable), alpha = 0.3) +
  facet_wrap(~country, ncol = 7) +
  scale_x_continuous(breaks = c(1992, 2005, 2017)) +
  theme(legend.position = "bottom", axis.title.x = element_blank(),
        legend.title = element_blank(),
        axis.title.y = element_blank(),
        panel.border = element_rect(colour="black", fill = 'transparent'),
        panel.background= element_rect(fill = 'transparent'),
        legend.background=element_rect(fill = 'transparent'),
        legend.key=element_rect(fill = 'transparent'),
        strip.background=element_rect(fill = 'transparent'))
ggsave("Figures/climate_env_sust_cy_sd.png",
       width = 6.78, height = 4.39
)

# Plot (free x scale)
for_plot %>%
  ggplot() +
  geom_line(aes(x = year, y = mean, color = variable),
            lwd = 0.6) +
  facet_wrap(~country, ncol = 7, scales = "free_x") +
  theme(legend.position = "bottom", axis.title.x = element_blank(),
        legend.title = element_blank(),
        axis.title.y = element_blank(),
        panel.border = element_rect(colour="black", fill = 'transparent'),
        panel.background= element_rect(fill = 'transparent'),
        legend.background=element_rect(fill = 'transparent'),
        legend.key=element_rect(fill = 'transparent'),
        strip.background=element_rect(fill = 'transparent'))
ggsave("Figures/climate_env_sust_cy_freex.png",
       width = 6.78, height = 4.39
)

# Plot (bars of country averages)
for_plot %>%
  group_by(country, name) %>%
  summarise(value = mean(value, na.rm = T)) %>%
  ggplot() +
  geom_bar(aes(x = name, y = value, fill = name), stat = "identity") +
  facet_wrap(~country, ncol = 7, scales = "free_x") +
  theme(legend.position = "bottom", axis.title.x = element_blank(),
        legend.title = element_blank(),
        axis.title.y = element_blank(),
        axis.ticks.x = element_blank(), axis.text.x = element_blank(),
        panel.border = element_rect(colour="black", fill = 'transparent'),
        panel.background= element_rect(fill = 'transparent'),
        legend.background=element_rect(fill = 'transparent'),
        legend.key=element_rect(fill = 'transparent'),
        strip.background=element_rect(fill = 'transparent'))
ggsave("Figures/climate_env_sust_bars.png",
       width = 6.78, height = 4.39
)

  
