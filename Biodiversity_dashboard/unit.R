# Load the required libraries
library(testthat)
# Load the ui and server scripts
source("ui.R")
source("server.R")

# Load the required libraries
library(testthat)

# Define a test function for the sidebarPanel element
test_that("sidebarPanel returns correct output", {
  # Create a mock Shiny input object
  input <- shiny::reactiveValues(countryChoice = "Poland")
  
  # Call the sidebarPanel function with the mock input
  output <- reactive({
    sidebarPanel(
      selectInput(
        "countryChoice",
        label = "Choose country",
        choices = list_of_countries$Name,
        selected = input$countryChoice
      )
    )
  })
  
  # Test that the output is correct
  reactive({
    expect_equal(output(), "sidebarPanel(selectInput(\"countryChoice\", label = \"Choose country\", choices = list_of_countries$Name, selected = input$countryChoice))")
  })
})
# Define a test function for the mainPanel element
test_that("mainPanel returns correct output", {
  # Create a mock Shiny input object
  input <- shiny::reactiveValues(countryChoice = "Poland")
  
  # Call the mainPanel function with the mock input
  output <- reactive({
    mainPanel(
      DT::dataTableOutput("dataTable")
    )
  })
  
  # Test that the output is correct
  reactive({
    expect_equal(output(), "mainPanel(DT::dataTableOutput(\"dataTable\"))")
  })
})

# Define a test function for the tabPanel element
test_that("tabPanel returns correct output", {
  # Create a mock Shiny input object
  input <- shiny::reactiveValues(countryChoice = "Poland")
  
  # Call the tabPanel function with the mock input
  output <- reactive({
    tabPanel(
      "Map",
      leafletOutput("map")
    )
  })
  
  # Test that the output is correct
  reactive({
    expect_equal(output(), "tabPanel(\"Map\", leafletOutput(\"map\"))")
  })
})


#SERVER.R

# Define a test function for the main_data reactive
test_that("main_data returns correct output", {
  # Create a mock Shiny input object
  input <- shiny::reactiveValues(countryChoice = "Poland")
  
  # Call the main_data reactive with the mock input
  output <- reactive({
    main_data(input)
  })
  
  # Test that the output is correct
  reactive({
    expect_equal(output(), "main_data(input)")
  })
})

# Define a test function for the combinedNameChoices reactive
test_that("combinedNameChoices returns correct output", {
  # Create a mock Shiny input object
  input <- shiny::reactiveValues(countryChoice = "Poland")
  
  # Call the combinedNameChoices reactive with the mock input
  output <- reactive({
    combinedNameChoices(input)
  })
  
  # Test that the output is correct
  reactive({
    expect_equal(output(), "combinedNameChoices(input)")
  })
})

# Define a test function for the taxonRank UI element
test_that("taxonRank returns correct output", {
  # Create a mock Shiny input object
  input <- shiny::reactiveValues(countryChoice = "Poland")
  
  # Call the taxonRank UI element with the mock input
  output <- reactive({
    taxonRank(input)
  })
  
  # Test that the output is correct
  reactive({
    expect_equal(output(), "taxonRank(input)")
  })
})

# Define a test function for the kingdom UI element
test_that("kingdom returns correct output", {
  # Create a mock Shiny input object
  input <- shiny::reactiveValues(countryChoice = "Poland")
  
  # Call the kingdom UI element with the mock input
  output <- reactive({
    kingdom(input)
  })
  reactive({
    expect_equal(output(),"kingdom(input)")
  })
})

# Define a test function for the family UI element
test_that("family returns correct output", {
  # Create a mock Shiny input object
  input <- shiny::reactiveValues(countryChoice = "Poland")
  
  # Call the family UI element with the mock input
  output <- reactive({
    family(input)
  })
  
  # Test that the output is correct
  reactive({
    expect_equal(output(), "family(input)")
  })
})

# Define a test function for the genera UI element
test_that("genera returns correct output", {
  # Create a mock Shiny input object
  input <- shiny::reactiveValues(countryChoice = "Poland")
  
  # Call the genera UI element with the mock input
  output <- reactive({
    genera(input)
  })
  
  # Test that the output is correct
  reactive({
    expect_equal(output(), "genera(input)")
  })
})

# Define a test function for the species UI element
test_that("species returns correct output", {
  # Create a mock Shiny input object
  input <- shiny::reactiveValues(countryChoice = "Poland")
  
  # Call the species UI element with the mock input
  output <- reactive({
    species(input)
  })
  
  # Test that the output is correct
  reactive({
    expect_equal(output(), "species(input)")
  })
})
