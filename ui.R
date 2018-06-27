library(shiny)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
  
  # Application title
  navbarPage("Groundwater Data", id = 'nav', collapsible = TRUE, position = "fixed-top",
             
             # Sidebar with a slider input for number of bins 
             tabPanel("Interactive map",
                      
                      div(class="outer",
                          
                          tags$head(
                            # Include  custom CSS
                            includeCSS("styles.css")
                          ),
                          
                          absolutePanel(id = "controls", class = "panel panel-default", 
                                        fixed = TRUE, draggable = TRUE, style="z-index:500;",
                                        top = 60, right = "auto", left = 60, bottom = "auto", width = 500, 
                                        h2("Data explorer"), height = 650,
                                        
                                        sliderInput("bins",
                                                    "Number of bins:",
                                                    min = 1,
                                                    max = 50,
                                                    value = 30),
                                        
                                        plotOutput("plot.bounds", height = "200px"),
                                        plotOutput("plot.clicked", height = "200px")
                                        
                          ),
                          
                          # Mapa de Leaflet 
                          
                          leafletOutput("map", height = "100%", width = "100%")
                      )
             ),
             
             tabPanel("Data",
                      
                      dataTableOutput("data") 
                      
             )
             
  )
))