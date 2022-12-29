library(leaflet)
library(shiny)

# Define UI for application that draws a histogram
fluidPage(
  tabsetPanel(
    id = "tabsetPanel1",
    tabPanel("Home", uiOutput("start_page")),
    tabPanel("Dashboard",
             sidebarLayout(
               sidebarPanel(
                 uiOutput("countryChoice"),
                 uiOutput("combinedName"),
                 uiOutput("search_by_name"),
                 div(id= "addFilters", style = "display: none",
                uiOutput("taxonRank"),
                 uiOutput("kingdom"),
                 uiOutput("family"),
                 # uiOutput("animationSlider")
                ),
                 width = 3),
               mainPanel(
                 uiOutput("introduction"),
                 uiOutput("timeline"),
                 leafletOutput("world_map", height = "70vh"),
                 width = 9
               )
             ),)
  ),
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "./custom.css"),
    tags$script(src = "./js/timeline.js"),
    tags$script(src = "./js/chart.js")
    # tags$script(src = "./chart-js/bar.js")
  ),
)