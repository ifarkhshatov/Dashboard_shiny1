
library(shiny)

# Define UI for application that draws a histogram
fluidPage( tabsetPanel(id = "tabsetPanel1",
  tabPanel("Home", uiOutput("start_page")), 
  tabPanel("Dashboard", 
           sidebarLayout(
             sidebarPanel(uiOutput("combinedName")
                          ),
             mainPanel(uiOutput("timeline"),
               leafletOutput("world_map"))
           ),
           )),   tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "./custom.css"),
    tags$script(src = "./js/geo_chart.js"),
    tags$script(src = "./js/chart.js"),
    # tags$script(src = "./chart-js/bar.js")
  ),)