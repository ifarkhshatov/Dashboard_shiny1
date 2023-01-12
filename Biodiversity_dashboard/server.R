library(tidyverse)
library(leaflet)
library(sf)
library(data.table)
library(lubridate)
library(rvest)
library(DT)
# read list of countries
list_of_countries <-
  fread("data_countries.csv", encoding = "UTF-8") %>%
  filter(Code %in%  sub("\\..*", "", list.files("data/")))

library(reactlog)
library(shiny)
reactlog_enable()


# Define server logic required to draw a histogram
#suspendWhenHidden=FALSE
function(input, output, session) {

  output$countryChoice <- renderUI({
    choices <- list_of_countries$Name
    selectInput(
      "countryChoice",
      label = "Choose country",
      choices = choices,
      selected =  "Poland"
    )
  })
  
  #load prepared RData with title of country
  main_data <- reactive({
        
    req(input$countryChoice)
    # select country code
    country_code <-
      list_of_countries$Code[list_of_countries$Name == input$countryChoice]
    if (exists("data_to_save")) {rm(data_to_save)}
    load(paste0("data/", country_code, ".RData"))
    
  setDT(data_to_save)[, count := .N, by = scientificName
    ][order(count, decreasing = TRUE)
    ][, combinedName := paste0(vernacularName , " (", scientificName, 
                               ") count: ", count)
    ]
  })
  
  combinedNameChoices <- reactive({
         # data.table do it faster than dplyr
    x <- unique(main_data()[, .(combinedName)])$combinedName
          return(x)
  })
  

  # firstly show search bar
  output$combinedName <- renderUI({
    selectizeInput(
      inputId = "combinedName",
      multiple = FALSE,
      selected = NULL, options = list(maxOptions = 100000L),
      choices = c("", combinedNameChoices()),
      label = "Choose species"
    )
  })

  # button show advanced
  
  #Button search by name
  output$search_by_name <- renderUI({
    actionButton("search_by_name",
                 div(
                   "Show advanced option",
                   icon("caret-down")
                 ))
  })
  
  # Workaround to not use packages such shinyJS
  observeEvent(input$search_by_name, {
    session$sendCustomMessage(type = "addFilters", message = jsonlite::toJSON("click"))
  })
  
  
  output$taxonRank <- renderUI({
    req(main_data())
    taxon <-
     unique(main_data()[, .(taxonRank)])$taxonRank
    
    selectInput("taxonRank", "Taxonomic rank:", choices =  taxon)
  })
  outputOptions(output, "taxonRank", suspendWhenHidden = FALSE)
  
  output$kingdom <- renderUI({
   
    req(input$taxonRank)
    kingdom <- unique(main_data()[taxonRank %in% input$taxonRank
                                          ][, .(kingdom)])$kingdom
    
    selectInput("kingdom",
                "Kingdom:",
                choices = kingdom,
                multiple = FALSE)
  })
  
  outputOptions(output, "kingdom", suspendWhenHidden = FALSE)
  
  output$family <- renderUI({
    req(input$kingdom)
 
    family <-unique(
      main_data()[
        taxonRank %in% input$taxonRank
      ][
        kingdom %in% input$kingdom][, .(family)])$family
   
    selectInput("family",
                "Family:",
                choices = family,
                multiple = FALSE)
  })
  
  outputOptions(output, "family", suspendWhenHidden = FALSE)
  
  # Create a reactive value to store the button state
  button_state <- reactiveValues(state = FALSE)
  
  observeEvent(input$search_by_name, {
    button_state$state <- !button_state$state
    })
  # Behavior of filter:
  
  observeEvent({
    input$search_by_name
    input$family
    },{
    # Toggle the button state when the button is clicked
    if ( button_state$state) {
      updated_species <- unique(
        main_data()[
          taxonRank %in% input$taxonRank
        ][
          kingdom %in% input$kingdom
        ][
          family %in% input$family
        ][combinedName %in% combinedNameChoices()
          ][, .(combinedName)])$combinedName

      updateSelectizeInput(inputId = "combinedName",
                           choices =  updated_species, selected ="" )
    } else {
      updateSelectizeInput(inputId = "combinedName", server = TRUE,
                           choices =  combinedNameChoices(), selected ="" )
    }
  })

  observeEvent(combinedNameChoices(), {
    updateSelectizeInput(inputId = "combinedName", server = TRUE,
                         choices =  combinedNameChoices(), selected ="" )
  })

  
  
  
  # it depends on country selected
  
  output$introduction <- renderUI({
    includeHTML("www/info.html")
  })
  
  # render the formatted text in the div element
  output$intro <- renderUI({
    includeHTML("www/intro.html")
  })
  
  data_map <- eventReactive({input$combinedName
    input$introDivClose
    input$countryChoice},{
      
    if (length(input$combinedName) == 0 || input$combinedName == "") {
      x <- main_data()
    } else {
    x <- main_data()[combinedName %in% input$combinedName]

    }
    return(x)

  })
  
  #data has wrong LAT LONG
  output$world_map <- renderLeaflet({
    req(input$introDivClose)
    
    leaflet() %>%
      addTiles()
  })
  
  
  # data for timeline. if species is "", then total distribution by year
  observeEvent({
    data_map()
  }, {
    req(input$introDivClose)
    lat <- mean(data_map()$longitudeDecimal)
    lng <- mean(data_map()$latitudeDecimal)
    proxy <- leafletProxy("world_map", data = data_map()) %>%
      setView(lat= lat,lng =lng, zoom = 6)
    
    proxy %>%
      clearGroup("the_only_way_is_to_remove_markers_on_the_map_lol")
    proxy %>%
      addMarkers(
      ~ latitudeDecimal,
      ~ longitudeDecimal,
      group = "the_only_way_is_to_remove_markers_on_the_map_lol",
      popup = paste0(
        "<b>", data_map()$vernacularName, " (", data_map()$scientificName, ")</b>",
        "<p> Date of finding: ", data_map()$eventDate, "</p>",
        '<button class="mapMarkerButton" onClick="clickIdFunction(\'', data_map()$id, '\')" id="',
        data_map()$id, '">click for more info</button>'
      ),
      clusterOptions = markerClusterOptions()
    )  %>%
      addProviderTiles(provider = providers$Jawg.Light)
    
    # Data for timeline chart
    if (length(input$combinedName) == 0 || input$combinedName == "") {
      df <- main_data()[, labels := year(eventDate)]
      #"setkey" function to create a new column called "year" that contains the year of the "date" column.
      setkey(df, labels)
      df <- df[order(labels)][, .(data = .N), by = labels]
    } else {
      df <-  data_map() %>%
        group_by(labels = year(eventDate), drop = FALSE) %>%
        summarise(data = n(), .groups = "drop") %>%
        ungroup()
    }

    session$sendCustomMessage(type = "timelineChart", message = jsonlite::toJSON(df))
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
  
  # define a reactive value to store the number of tabs
  numTabs <- reactiveValues(value = 3)
  
  # observe the tabsetPanel and update the reactive value whenever a tab is added or removed
  
  # create new tab with detailed info about species
  observeEvent(input$idFromMapMarker$doubleCountTab,{

      if (numTabs$value == 3 ) {
        id <- input$idFromMapMarker$id
        numTabs$value <- numTabs$value+1
        # Scrape the data from the website
        url <- paste0("https://waarneming.nl/observation/",gsub("[^0-9]", "", id))
        page <- read_html(url)
        
        # Extract the data from the table
        observation_details <- bind_rows(page %>%
          html_nodes(xpath='//table[@class="table table-condensed"]') %>%
          html_table())
        
        # insert the new tab
        insertTab(inputId = "tabsetPanel1",
                  tabPanel(div(id,actionButton(class ="closeButtons", onclick = "

  Shiny.setInputValue('tabPanelName', $(this).parent().parent()[0].getAttribute('data-value'));

                                               ",
                                               inputId = "closeSpeciesTab", icon("times", class = "fa-lg") ) ) ,
                           div(
                             h1( paste0(
                               unlist(main_data()[id == input$idFromMapMarker$id]$vernacularName),
                               " (", unlist(main_data()[id == input$idFromMapMarker$id]$scientificName), ")"
                             )  ),
                             DT::renderDataTable(observation_details,
                                                 options = list(lengthChange = FALSE,
                                                                lengthMenu = FALSE,
                                                                searching = FALSE,
                                                                info = FALSE,
                                                                paging=FALSE,
                                                                headerCallback = JS(
                                                                  "function(thead, data, start, end, display){",
                                                                  "  $(thead).remove();",
                                                                  "}")),
                                                 rownames= FALSE,),
                             a(href = url, "More details", target = "_blank")
                           )
                           
                           
                           ),
                  target = "Dashboard")
      } else {
        # show warning message
        showModal(modalDialog(
          title = "Warning",
          " Please close opened tab and try again."
        ))
      }
  })
  
  observeEvent(input$closeSpeciesTab, {
    removeTab(inputId = "tabsetPanel1", target = input$tabPanelName)
    numTabs$value <- numTabs$value - 1
  })
  
  # close open tab
  observeEvent(input$closeSpeciesTab, {
    session$sendCustomMessage(type = "closeThisTab", message = jsonlite::toJSON("closeThisTab"))
    })
  
}
