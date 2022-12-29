library(tidyverse)
library(leaflet)
library(sf)
library(data.table)
library(lubridate)

# read list of countries
list_of_countries <-
  fread("data_countries.csv", encoding = "UTF-8") %>%
  filter(Code %in%  sub("\\..*", "", list.files("data/")))


library(shiny)

# Define server logic required to draw a histogram
#suspendWhenHidden=FALSE 
function(input, output, session) {
  # Country choice:
  output$animationSlider <- renderUI({
    sliderInput(
      "animationSlider2",
      "Dynamic animation slider",
      min = 1,
      max = 100,
      value = 1,
      step = 1,
      animate = animationOptions(200)
    )
  })
  
  output$countryChoice <- renderUI({
    choices <- list_of_countries$Name
    selectInput(
      "countryChoice",
      label = "Choose country",
      choices = choices,
      selected =  "Poland"
    )
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
  
  # firstly show search bar
  output$combinedName <- renderUI({
    # data.table do it faster than dplyr
    choices <-
      unique(setDT(main_data())[, count := .N, by =scientificName ][
        order(count, decreasing = TRUE)
      ][, combinedName := paste0(
        vernacularName , " (", scientificName, ") count: ", count
      )][, .(combinedName)])$combinedName
    
    selectizeInput(
      inputId = "combinedName",
      multiple = FALSE,
      selected = NULL,
      choices = c("", choices),
      label = "Choose species"
    )
    
  })
  # button show advanced
  
  #Button search by name
  output$search_by_name <- renderUI({
    actionButton("search_by_name", "Show advanced option")
  })
  
  # Workaround to not use packages such shinyJS
  observeEvent(input$search_by_name, {
    session$sendCustomMessage(type = "addFilters", message = jsonlite::toJSON("click"))
  })
  
  
  
  output$taxonRank <- renderUI({
    req(main_data())
    
    taxon <-
      unique(main_data() %>% arrange(taxonRank) %>% select(taxonRank) %>% c() %>% unlist())
    
    selectInput("taxonRank", "Taxonomic rank:", choices = taxon)
  })
  outputOptions(output, "taxonRank",suspendWhenHidden = FALSE)
  
  output$kingdom <- renderUI({
    req(input$taxonRank)
    kingdom <- unique(
      main_data() %>%
        filter(taxonRank %in% input$taxonRank) %>%
        arrange(kingdom) %>%
        select(kingdom) %>% c() %>% unlist()
    )
    selectInput("kingdom",
                "Kingdom:",
                choices = kingdom,
                multiple = FALSE)
  })
  
  outputOptions(output, "kingdom",suspendWhenHidden = FALSE)
  
  output$family <- renderUI({
    req(input$kingdom)
    family <- unique(
      main_data() %>%
        filter(taxonRank %in% input$taxonRank) %>%
        filter(kingdom %in% input$kingdom) %>%
        arrange(family) %>%
        select(family) %>% c() %>% unlist()
    )
    selectInput("family",
                "Family:",
                choices = family,
                multiple = FALSE)
  })
  
  
  outputOptions(output, "family",suspendWhenHidden = FALSE)
  
  
  # it depends on country selected
  
  output$introduction <- renderUI({
    
  })
  
  # output$timeline <- renderUI({
  #   req(input$combinedName)
  #   sliderInput(
  #     label = NULL,
  #     inputId = "timeline",
  #     min = as.Date("2020-01-01"),
  #     max = Sys.Date(),
  #     value = as.Date("2020-01-01"),
  #     step = 1,
  #     animate = animationOptions() ,
  #     timeFormat = "%Y-%m-%d",
  #   )
  # })
  
  
  data_map <- eventReactive(input$combinedName, {
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
  # data for timeline. if species is "", then total distribution by year
  observeEvent({input$countryChoice
    input$combinedName }, {
    
      if (length(input$combinedName) == 0 ||input$combinedName == "") {
    df <- main_data()[, labels := year(eventDate)
    ]
    #"setkey" function to create a new column called "year" that contains the year of the "date" column.
    setkey(df, labels)
    df <- df[order(labels)][, .(data = .N), by = labels]
      } else {
        df <-  data_map() %>%
          group_by(labels = year(eventDate), drop = FALSE) %>%
          summarise(data = n(), .groups = "drop") %>%
          ungroup()
        print(df)
      }
    
    session$sendCustomMessage(type = "timelineChart", message = jsonlite::toJSON(df))
  })
  
  # data has wrong LAT LONG
  output$world_map <- renderLeaflet({
    req(data_map())

  leaflet(data = data_map()) %>%
      addTiles() %>%
      addMarkers(
        ~ latitudeDecimal,
        ~ longitudeDecimal,
        popup  = '<p>This is bla-bla-bla, here is image:</p>
<img src="image.jpg" alt="image">
<button class="detailed_tab">click this button for more info</button>' ,
        clusterOptions = markerClusterOptions()
      ) %>%
      addProviderTiles(provider = providers$Jawg.Light)
  })
  

  #welcome page
  output$start_page <- renderUI({
    includeHTML("www/index.html")
  })
  
  #render timeline chart area
  output$timeline <- renderUI({
    div(class = "timeline-chart",
        div(class = "timeline"))
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
