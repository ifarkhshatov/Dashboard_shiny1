# Load the data.table package
library(data.table)

# Set the path to the CSV file
csv_path <- "occurence.csv"

# Set the chunk size
chunk_size <- 1000000
# y <- fread("occurence.csv", nrows = 1000)
# Set the output file path
output_file <- "PL.csv"

# Initialize a counter to track the starting row of each chunk
i <- 1
#length(readLines("occurence.csv")) 39969765 length of data
# keep columns
selected_columns <- c("id",  "scientificName", "taxonRank", "kingdom", "family", "vernacularName","latitudeDecimal","longitudeDecimal","countryCode","eventDate")
selected_colums_by_id <- c(1,6,7,8,9,11,16,17,23,29)
# Initialize a list to store the data frames
data_tables <- list()

  # Loop until the end of the file is reached
  while(TRUE) {
    #39969765
    skip <- if (i == 1 ) { 1} else {(i - 1) * chunk_size}
    # quick workaround since data is only 39969765 rows
    if (skip == 40000000) {
      break
    }
    # Read the next chunk of data
    chunk <- fread(csv_path, nrows = chunk_size, skip = skip, select = selected_colums_by_id, header = FALSE)
    # If the chunk is empty, break the loop
    if (nrow(chunk) == 0) break
    
    for (country in unique(chunk$V23)[-1] ) {
      # Filter the data for rows where the "countryCode" column is "PL"
      data  <- chunk[V23 == country,]
      setnames(data, names(data), selected_columns)
      # If a data table for the current country doesn't exist, create it
      if (!country %in% names(data_tables)) {
        data_tables[[country]] <- data.table()
      }
      
      # Append the data to the data table for the current country
      data_tables[[country]] <- rbind(data_tables[[country]], data)
    }
    
    # Increment the counter
    i <- i + 1
    print(paste0("Progress: ", format(((i - 1) * chunk_size) / 39969765 * 100, digits = 2),"%" ))
  }

# Loop over the data tables and save them to RData files
for (country in names(data_tables)) {
  data_to_save <- data_tables[[country]]
  save(data_to_save, file = paste0("Biodiversity_dashboard/data/",country, ".RData"))
}
save(data_tables, file = paste0("big_data.RData"))

file.exists("Biodiversity_dashboard/data/AAS.RData")
load(file = "Biodiversity_dashboard/data/BG.RData")
