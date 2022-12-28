
# Read data from sample

if (file.exists("multimedia.csv") && file.exists("occurence.csv")) {
  multimedia <- read.csv("multimedia.csv", nrows = 10000)
  occurence <-  read.csv("occurence.csv", nrows = 10000)
} else {
  print("No samples found in directory")
  print(paste0("Current directory: ", getwd()))
}

length(names(occurence))
x <- rep("NULL", length(names(occurence)))

x[23] <- "countryCode"

z <- read.csv("occurence.csv", header = TRUE, colClasses = c(x))
