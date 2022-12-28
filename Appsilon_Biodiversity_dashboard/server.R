library(tidyverse)
library(leaflet)
library(sf)
library(shiny)

# Define server logic required to draw a histogram
function(input, output, session) {

      output$combinedName <- renderUI({
      choices <- occurence %>% select(scientificName, vernacularName) %>%
        mutate(combinedName = paste0(vernacularName, " (", scientificName,")")) %>%
        select(Species = combinedName) %>% c()
      
      
      selectizeInput(inputId = "combinedName",
                     multiple = TRUE,
                     choices = choices,
                     label = "Choose species (possible multiple)"
                     )
      
      })
      
    output$timeline <- renderUI({
      sliderInput(
        label = "Select time:",
        inputId = "timeline",
        min = as.Date("2020-01-01"),
        max = as.Date("2020-12-31"),
        value = c(as.Date("2020-01-01"), as.Date("2020-12-31")),
        step = 1,
        animate = TRUE,
        timeFormat = "%Y-%m-%d",
        )
    })
    
    
    data <- eventReactive(input$combinedName,{
      req(input$combinedName)
      # split input names into scientific and classic one
      split_name <- strsplit(input$combinedName, " \\(|\\)")
      scientificNameV <- sapply(split_name, function(x) x[2])
      data <- occurence %>% 
        filter(scientificName %in% scientificNameV)
      data      
    }) 
    
    output$world_map <- renderLeaflet({
      
      req(data())
      leaflet(
        data = data()
      ) %>%
      addTiles() %>%
        addMarkers(~longitudeDecimal, ~latitudeDecimal) %>%
        addProviderTiles(providers$Esri.WorldStreetMap)
    })
    
    output$start_page <- renderUI({
      includeHTML("www/index.html")
    })
    # maybe will remove...
    observe({
      # last clicked input value
        id <- tail(input$combinedName, n=1)
          insertTab(
            inputId = "tabsetPanel1",
            tabPanel(id, "Test"),
            target = "Dashboard")
   
        
      
    })

    }
