# Author: Aaron Yerke (aaronyerke@gmail.com)
# Script for making dataset for testing my random foret script
# Need at least one numeric column and one categorical column

rm(list = ls()) #clear workspace
chooseCRANmirror(graphics=FALSE, ind=66)

pwd <- getwd()
print(paste("Working in", pwd))

#### Loading dependencies ####
if (!requireNamespace("BiocManager", quietly = TRUE)) install.packages("BiocManager")
if (!requireNamespace("datasets", quietly = TRUE)) BiocManager::install("datasets")
library("datasets")
if (!requireNamespace("randomForest", quietly = TRUE)) BiocManager::install("randomForest")
library("randomForest")

print("Loaded packages")

#### Establish directory layout and other constants ####
output_dir <- file.path("data", "unit_test")
dir.create(output_dir)

#### Loading in data ####
mtc_df <- datasets::mtcars
print("Downloaded mtcars")

mpg_df <- mtc_df[1]
mpg_df$good_mileage <- mpg_df$mpg > 20
sum(mpg_df$good_mileage)

mtc_df <- subset(mtc_df, select = -c(1))

cor_pvs <- apply(mtc_df, MARGIN = 2, function(x){cor(x, mpg_df[,1])^2})

mtc_df$`car_name` <- row.names(mtc_df)
mpg_df$`car_name` <- row.names(mpg_df)


write.csv(mtc_df, file.path(output_dir, "mtc_predictor.csv"), row.names = FALSE)
write.csv(mpg_df, file.path(output_dir, "mtc_response.csv"), row.names = FALSE)

print("End R script.")

