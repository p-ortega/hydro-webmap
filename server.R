#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
#

library(shiny)

## Layout plotly
m = list(
  l = 50,
  r = 10,
  b = 150,
  t = 30,
  pad = 0
) 


# EPSG32719 = leafletCRS(crsClass = "L.Proj.CRS", code = "EPSG:32719",
#            proj4def = "+proj=utm +zone=19 +south +ellps=WGS84 +datum=WGS84 +units=m +no_defs", 
#            resolutions = (20:1))



# Define server logic required to draw a histogram
shinyServer(function(input, output) {
   
  output$map <- renderLeaflet({ # Agrega mapa de leaflet
    leaflet()%>%
    # Base groups
    addProviderTiles(providers$OpenStreetMap, group = "Base")%>%
    addProviderTiles(providers$Esri.WorldStreetMap, group = "Street")%>%
    addProviderTiles(providers$Esri.WorldImagery, group = "Terrain")%>%  
    
    setView(-69.35, -22.85, zoom = 7)%>%
      
    # Add points
    addCircleMarkers(data = pts, ~long, ~lat, popup = ~id, layerId = ~id,
                     radius=5, group = "Monit. Points")%>%
    
    # Layers control
    addLayersControl(
      baseGroups = c("Base", "Street", "Terrain"),
      options = layersControlOptions(collapsed = TRUE)
      )%>%
    
    addMiniMap(position = 'bottomright', toggleDisplay = TRUE, collapsedWidth = 30, collapsedHeight = 30)
      
    })

  # Render table with data
  output$data <- renderDataTable({
    gw.level
  })
  my.mapdata <- reactiveValues(clickedMarker=NULL)
  # Oberserve when marker clicked
  observeEvent(input$map_marker_click,{
    print("observed map_marker_click")
    my.mapdata$clickedMarker = input$map_marker_click
    print(my.mapdata$clickedMarker$id)
    my.leveldata = subset(gw.level, gw.level$id == my.mapdata$clickedmarker$id)
    print(my.leveldata$id)
    })
  
  # Render plot with groundwater levels
  output$plot.level = renderPlotly({
    plot_ly(gw.level, x = ~date, y = ~level.mbgl, 
            color = ~id, type = "scatter", mode =  "lines",
            marker = list(size = 8, line = list(color = ~id,
                                                width = 1.5))) %>%
      layout( width = 450, height = 400, margin = m,
              yaxis = list(autorange = "reversed", zeroline = FALSE, showgrid = FALSE,
                           showline = TRUE, title = "Groundwater Level [mbgl]", 
                           ticks = "outside", nticks = 10, tickwidth = 2,
                           linewidth = 2),
              xaxis = list(zeroline = TRUE, showline = TRUE, title = FALSE, 
                           showgrid = FALSE, ticks = "outside", nticks = 10,
                           tickwidth = 2, linewidth = 2, tickangle = -90),
              showlegend = FALSE)
    
  })  
  
})
