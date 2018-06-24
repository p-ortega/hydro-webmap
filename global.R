library(leaflet)
library(plotly)


# Read data

## Read points
pts = read.csv("./data/points.csv")

## Read levels
gw.level = read.csv("./data/gw-level.csv")
gw.level$level.mbgl = gw.level$level.mbtoc - gw.level$stick.up
gw.level$date = as.Date(gw.level$date, origin = "1899-12-30")



