
library(shiny)

# Define UI for application that draws a histogram
fluidPage( tabsetPanel(
  tabPanel("Start", uiOutput("start_page")), 
  tabPanel("tab 2", 
           uiOutput("species_chooser"),
           uiOutput("world_map")), 
  tabPanel("tab 3", "contents")),   tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "./custom.css"),
    # tags$script(src = "./index.js"),
    # tags$script(src = "./chart.js"),
    # tags$script(src = "./chart-js/bar.js")
  ),)