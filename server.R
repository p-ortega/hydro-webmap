library(shiny)


# Define server logic required to draw a histogram
shinyServer(function(input, output) {
  
  output$map <- renderLeaflet({ # Agrega mapa de leaflet
    leaflet()%>%
      # Base groups
      addProviderTiles(providers$OpenStreetMap, group = "Base")%>%
      addProviderTiles(providers$Esri.WorldStreetMap, group = "Street")%>%
      addProviderTiles(providers$Esri.WorldImagery, group = "Terrain")%>%  
      
      setView(-69.7, -23, zoom = 10)%>%
      
      # Add points
      addCircleMarkers(data = pts, ~long, ~lat, layerId = ~id, 
                       label = ~htmlEscape(id),
                       radius=5, group = "Monitoring points")%>%
      
      # Layers control
      addLayersControl(
        baseGroups = c("Base", "Street", "Terrain"),
        overlayGroups = c("Monitoring points"),
        options = layersControlOptions(collapsed = TRUE)
      )%>%
      addMiniMap(position = 'bottomright', toggleDisplay = TRUE, collapsedWidth = 30, collapsedHeight = 30)
  })
  
  click = reactiveValues(clickedMarker=list())
  
  # store the click
  observeEvent(input$map_marker_click,{
    click2 = input$map_marker_click
    click$clickedMarker = c(click$clickedMarker, click2$id)
    dups = unique(click$clickedMarker[duplicated(click$clickedMarker)])
    if(length(dups) > 0){
      print("1")
      print(dups)
      click$clickedMarker = click$clickedMarker[-which(click$clickedMarker %in% dups)]
      # g[-which(rownames(g) %in% remove), ]
    }
    else {
      print("0")
      click$clickedMarker = click$clickedMarker
      }
  })
  
 filtered.data = reactive({
   na.omit(subset(gw.level, gw.level$id %in% click$clickedMarker))
 })
  
 # A reactive expression that returns the set of points that are in bounds right now
 ptsinbounds <- reactive({
   if (is.null(input$map_bounds))
     return(pts[FALSE,])
   bounds <- input$map_bounds
   latRng <- range(bounds$north, bounds$south)
   lngRng <- range(bounds$east, bounds$west)
   
   a = subset(pts, lat >= latRng[1] & lat <= latRng[2] & long >= lngRng[1] & long <= lngRng[2])
   na.omit(subset(gw.level, gw.level$id %in% a$id)) 
   
 })
 
    # Plot subset of data selected by clicking
  output$plot.clicked = renderPlot({
    ggplot(filtered.data(), aes(x = date, y = level.mbgl, color = id)) + geom_line(size = 1.5) +
      scale_y_reverse() +
      theme_bw() + theme(panel.grid = element_blank())
    })
  
  # Plot subset of data in zoom bounds
  output$plot.bounds = renderPlot({
    if (nrow(ptsinbounds()) == 0)
      return(NULL)
    ggplot(ptsinbounds(), aes(x = date, y = level.mbgl, color = id)) + geom_line(size = 1.5) +
      scale_y_reverse() +
      theme_bw() + theme(panel.grid = element_blank())
  })
  
  # filtered.pts = reactive({
  #   subset(pts, pts$id %in% click$clickedMarker)
  # })
  
  # change color of icon
  # observe({
  #   leafletProxy("map")%>%
  #     clearMarkers(data = filtered.pts())%>%
  #     addCircleMarkers(data = filtered.pts(),
  #                      radius = 5, color = "red")
  # })
  
  
  # Render table with data
  output$data <- renderDataTable({
    gw.level
  })
  
})
