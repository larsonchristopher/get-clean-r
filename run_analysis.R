# This script does the following on the UCI HAR Dataset downloaded from:
# https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip 

# 1. Merges the training and the test sets to create one data set.
# 2. Extracts only the measurements on the mean and standard deviation for each measurement. 
# 3. Uses descriptive activity names to name the activities in the data set
# 4. Appropriately labels the data set with descriptive variable names. 
# 5. From the data set in step 4, creates a second, independent tidy data set with the average of each 
#    variable for each activity and each subject.

# If data directory exists, change to that directory.
# Else, create data directory, download and unzip raw data files.

if (!file.exists("data")) {
        dir.create("data")
}

setwd("./data")

# Check to see data is already downloaded

if (!file.exists("./UCI HAR Dataset")) {
        # Download data if needed
        fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
        download.file(fileUrl, destfile = "Dataset.zip", method = "curl")
        unzip("Dataset.zip")
        }

# Load required libraries
library(data.table)
library(reshape2)

# Read activity labels
activity_labels <- read.table("./UCI HAR Dataset/activity_labels.txt",header=FALSE)[,2]

# Read data column names
features <- read.table("./UCI HAR Dataset/features.txt",header=FALSE)[,2]

# Extract only mean and standard deviation data
extract_features <- grepl("mean|std", features)

# Read training data
subject_train <- read.table("./UCI HAR Dataset/train/subject_train.txt",header=FALSE)
x_train <- read.table("./UCI HAR Dataset/train/x_train.txt",header=FALSE)
y_train <- read.table("./UCI HAR Dataset/train/y_train.txt",header=FALSE)

names(x_train) = features

# Extract only the measurements on the mean and standard deviation data
x_train = x_train[,extract_features]

# Read activity data
y_train[,2] = activity_labels[y_train[,1]]
names(y_train) = c("Activity_ID", "Activity_Label")
names(subject_train) = "subject"

# Merge training data 
trainingData <- cbind(as.data.table(subject_train),y_train,x_train)

# Read test data
subject_test <- read.table('./UCI HAR Dataset/test/subject_test.txt',header=FALSE)
x_test <- read.table('./UCI HAR Dataset/test/x_test.txt',header=FALSE)
y_test <- read.table('./UCI HAR Dataset/test/y_test.txt',header=FALSE)

names(x_test) = features

# Merge test data
testData <- cbind(y_test,subject_test,x_test)

# Extract only the measurements on the mean and standard deviation 
x_test = x_test[,extract_features]

# Read activity labels
y_test[,2] = activity_labels[y_test[,1]]
names(y_test) = c("Activity_ID", "Activity_Label")
names(subject_test) = "subject"

# Merge test data 
testData <- cbind(as.data.table(subject_test), y_test, x_test)

# Merge the training and the test sets to create one merged dataset
mergedData <- rbind(trainingData,testData)

id_labels = c("subject", "Activity_ID", "Activity_Label")
data_labels = setdiff(colnames(mergedData), id_labels)
melt_data = melt(mergedData, id = id_labels, measure.vars = data_labels)

# Apply mean function to dataset using dcast function
tidy_mergedData = dcast(melt_data, subject + Activity_Label ~ variable, mean)

# Create tidy text file
write.table(tidy_mergedData, file = "./tidy_merged_data.txt", row.name=FALSE)
