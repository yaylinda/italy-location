setwd("~/Developer/italy-location")

library(ggplot2)
library(jsonlite)
library(lubridate)
library(zoo)
library(ggmap)
library(gganimate)
library(gifski)

#################################################
# Read and massage locations data
#################################################
data = fromJSON('location.json')
locations = data$locations

locations$time = as.POSIXct(as.numeric(data$locations$timestampMs)/1000, origin = "1970-01-01", tz = "CET")
locations$lat = locations$latitudeE7 / 1e7
locations$lon = locations$longitudeE7 / 1e7

locations = locations[which(locations$lat > 41), ]

locations$date = as.factor(substr(locations$time, 1, 10))
  
#################################################
# Plot locations on map
#################################################

#------------------
# Get map
#------------------

register_google(key = "AIzaSyBRDszv_djY3cg90hiqtdxCxiDiIF4fe70")
italy = get_map(location = c(lon = 11, lat = 43.5), zoom = 7, maptype = "roadmap", color = "bw")

#------------------
# Plot location points
#------------------

locations_animation = ggmap(italy) + 
  geom_point(
    data = locations, 
    aes(x = lon, y = lat, color = date, size = 10), 
    alpha = 0.5
  ) + 
  labs(
    title = "Journey Through Italy",
    subtitle = "{frame_time}"
  ) +
  theme(
    legend.position = "none",
    axis.title.x=element_blank(),
    axis.text.x=element_blank(),
    axis.ticks.x=element_blank(),
    axis.title.y=element_blank(),
    axis.text.y=element_blank(),
    axis.ticks.y=element_blank(),
  ) +
  transition_time(locations$time)
  + shadow_mark(past = TRUE, alpha = 0.5, color = 'black', size = 5)

animate(
  locations_animation, 
  duration = 10,
  width = 500, 
  height = 500, 
  renderer = gifski_renderer()
)

anim_save("locations.gif", path = "~/Developer/italy-location")
