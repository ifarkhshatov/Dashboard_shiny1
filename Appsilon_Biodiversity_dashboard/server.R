library(tidyverse)
library(leaflet)
library(sf)
library(data.table)

# read list of countries
list_of_countries <-
  fread("data_countries.csv", encoding = "UTF-8") %>%
  filter(Code %in%  sub("\\..*", "", list.files("data/")))


library(shiny)

# Define server logic required to draw a histogram
function(input, output, session) {
  
  # Country choice:
  output$animationSlider <- renderUI({
    sliderInput("animationSlider2", "Dynamic animation slider", 
                min = 1, max = 100, value = 1, step = 1,
                animate = animationOptions(200))
  })
  
  output$countryChoice <- renderUI({
    choices <- list_of_countries$Name
    selectInput("countryChoice",
                label = "Choose country",
                choices = choices)
  })
  #
  main_data <- eventReactive(input$countryChoice, {
    req(input$countryChoice)
    # select country code
    country_code <-
      list_of_countries$Code[list_of_countries$Name == input$countryChoice]
    load(paste0("data/", country_code, ".RData"))
    data_to_save
  })
  
  output$taxonRank <- renderUI({
    req(main_data())
    
    taxon <- unique(main_data()$taxonRank)
    
    selectInput("taxonRank", "Taxonomic rank:", choices = taxon)
  })
  
  output$kingdom <- renderUI({
    req(input$taxonRank)
    kingdom <- unique(
      main_data() %>%
        filter(taxonRank %in% input$taxonRank) %>%
        select(kingdom) %>% c() %>% unlist()
    )
    selectInput("kingdom",
                "Kingdom:",
                choices = kingdom,
                multiple = TRUE)
  })
  
  output$family <- renderUI({
    req(input$kingdom)
    family <- unique(
      main_data() %>%
        filter(taxonRank %in% input$taxonRank) %>%
        filter(kingdom %in% input$kingdom) %>%
        select(family) %>% c() %>% unlist()
    )
    selectInput("family",
                "Family:",
                choices = family,
                multiple = TRUE)
  })
  
  #Button search by name
  output$search_by_name <- renderUI({
    actionButton("search_by_name", "Search by name instead")
  })
  # Initialize a reactive value to store the visibility of the renderUI output
  vis <- reactiveValues(visible = TRUE)
  # Observe the button click and toggle the reactive value
  observeEvent(input$button, {
    vis$visible <- !vis$visible
  })
  
  
  # it depends on country selected
  output$combinedName <- renderUI({
    req(input$family)
    choices <-
      unique(
        main_data() %>%
          filter(family %in% input$family) %>%
          select(scientificName , vernacularName) %>%
          mutate(combinedName = paste0(
            vernacularName , " (", scientificName, ")"
          )) %>%
          select(Species = combinedName) %>% c()
      )
    
    selectizeInput(
      inputId = "combinedName",
      multiple = TRUE,
      choices = unlist(choices),
      label = "Choose species (possible multiple)"
    )
    
  })
  
  output$introduction <- renderUI({
    
  })
  
  output$timeline <- renderUI({
    req(input$combinedName)
    sliderInput(
      label = NULL,
      inputId = "timeline",
      min = as.Date("2020-01-01"),
      max = Sys.Date(),
      value = as.Date("2020-01-01"),
      step = 1,
      animate = animationOptions() ,
      timeFormat = "%Y-%m-%d",
    )
  })
  
  
  data <- eventReactive(input$combinedName, {
    req(input$combinedName)
    req(main_data())
    # split input names into scientific and classic one
    split_name <- strsplit(input$combinedName, " \\(|\\)")
    scientificNameV <- sapply(split_name, function(x)
      x[2])
    data <- main_data() %>%
      filter(scientificName %in% scientificNameV)
    data
  })
  # data has wrong LAT LONG
  output$world_map <- renderLeaflet({
    req(data())
    leaflet(data = data()) %>%
      addTiles() %>%
      addMarkers(~latitudeDecimal, ~longitudeDecimal, popup  = "Will be short info and img if present, i press more and it will open next tab" ) %>%
      addProviderTiles(providers$Esri.WorldStreetMap)
   
  })
  
  output$start_page <- renderUI({
    includeHTML("www/index.html")
  })
  # maybe will remove...
  # observe({
  #   # last clicked input value
  #   id <- tail(input$combinedName, n = 1)
  #   insertTab(inputId = "tabsetPanel1",
  #             tabPanel(id, "Test"),
  #             target = "Dashboard")
  #
  #
  #
  # })
  
}
