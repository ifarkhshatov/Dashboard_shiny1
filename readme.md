# Species Search Shiny App

This Shiny app allows users to search for species using various criteria, including common and scientific names, taxonomic rank, and kingdom and family. The app also displays a map visualization of the locations where the selected species have been observed.

## Requirements

To use this app, you will need to have the following software installed:

- R
- Shiny

You will also need to install the following R packages:

- tidyverse
- leaflet
- sf
- data.table
- lubridate
- rvest
- DT

## Running the app

To run the app, open the `server.R` file in R and click the "Run App" button in the RStudio IDE. Alternatively, you can run the app from the command line by calling `shiny::runApp()` and specifying the directory where the app is located.

## Data

The app includes a `data` directory containing data for various countries in the form of `.RData` files. These files contain data on species observations in the corresponding countries, including common and scientific names, taxonomic rank, kingdom, family, and location coordinates.

The app also includes a `data_countries.csv` file, which contains information on the countries for which data is available.

## Modules

The app is divided into several modules:

- **Country selection module**: Allows users to select the country for which they want to search for species.
- **Search by name module**: Allows users to search for species by common or scientific name.
- **Advanced search module**: Allows users to search for species using additional criteria such as taxonomic rank, kingdom, and family.
- **Map visualization module**: Displays a map of the locations where the selected species have been observed.


# Species Data Preprocessing Script

This script is used to preprocess a large CSV file containing species occurrence data and split it into smaller, more manageable data tables for each country. The script loads the data in chunks and filters it by country, saving the resulting data tables to RData files in a `data` directory.

## Requirements

To use this script, you will need to have the following software installed:

- R

You will also need to install the following R package:

- data.table

## Usage

To use the script, simply open it in R and run it. The script will automatically process the data and create the data tables in the `data` directory.

## Data

The script expects a CSV file named `occurence.csv` to be present in the same directory as the script. This file should contain species occurrence data, including columns for `id`, `scientificName`, `taxonRank`, `kingdom`, `family`, `vernacularName`, `latitudeDecimal`, `longitudeDecimal`, `countryCode`, and `eventDate`.

The script will create data tables for each unique value in the `countryCode` column, saving them to RData files in the `data` directory with the country code as the file name.

## Configuration

The script can be configured by modifying the following variables:

- `csv_path`: The path to the input CSV file.
- `chunk_size`: The size of each data chunk to read from the CSV file.
- `output_file`: The path to the output RData file.
- `selected_columns`: The names of the columns to keep in the output data tables.
- `selected_colums_by_id`: The IDs of the columns to keep in the output data tables.

## Issues

If you encounter any issues with the script, please open an issue on the GitHub repository or contact the script maintainer for assistance.
