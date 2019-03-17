# NOTE: Download the dataset if it does not already exist in the working directory
if(!file.exists("./data")) {
  dir.create("./data")
}

fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
if(!file.exists("./data/Dataset.zip")) {
  download.file(fileUrl, destfile = "./data/Dataset.zip", method = "curl")
}

# NOTE: Unzip the file
zipPath <- "./data/Dataset.zip"
exportPath <- "./data"
if(!file.exists("./data/UCI HAR Dataset")) {
  unzip(zipPath, exdir = exportPath)
}

# NOTE: Load the activity and feature info
activityLabels <- read.table("./data/UCI HAR Dataset/activity_labels.txt")
activityLabels[, 2] <- as.character(activityLabels[, 2])
features <- read.table("./data/UCI HAR Dataset/features.txt")
features[, 2] <- as.character(features[, 2])

# NOTE: Loads both the training and test datasets, keeping only those columns which reflect a mean or standard deviation
featuresWanted <- grep(".*mean.*|.*std.*", features[,2])
featuresWanted.name <- features[featuresWanted, 2]
featuresWanted.name <- gsub("-mean", "Mean", featuresWanted.name)
featuresWanted.name <- gsub("-std", "Std", featuresWanted.name)
featuresWanted.name <- gsub("[-()]", "", featuresWanted.name)


# NOTE: Loads both the training and test datasets
train <- read.table("./data/UCI HAR Dataset/train/X_train.txt")[featuresWanted]
trainActivities <- read.table("./data/UCI HAR Dataset/train/Y_train.txt")
trainActivities <- read.table("./data/UCI HAR Dataset/train/y_train.txt")
trainSubjects <- read.table("./data/UCI HAR Dataset/train/subject_train.txt")
train <- cbind(trainSubjects, trainActivities, train)

test <- read.table("./data/UCI HAR Dataset/test/X_test.txt")[featuresWanted]
testActivities <- read.table("./data/UCI HAR Dataset/test/Y_test.txt")
testActivities <- read.table("./data/UCI HAR Dataset/test/y_test.txt")
testSubjects <- read.table("./data/UCI HAR Dataset/test/subject_test.txt")
test <- cbind(testSubjects, testActivities, test)

# NOTE: Merges the two datasets
allData <- rbind(train, test)
colnames(allData) <- c("subject", "activity", featuresWanted.name)

# NOTE: Converts the activity and subject columns into factors
allData$activity <- factor(allData$activity, levels = activityLabels[, 1], labels = activityLabels[, 2])
allData$subject <- as.factor(allData$subject)
allData.melted <- melt(allData, id = c("subject", "activity"))

# NOTE: Creates a tidy dataset that consists of the average (mean) value of each variable for each subject and activity pair
library(reshape2)
allData.melted <- melt(allData, id = c("subject", "activity"))
allData.mean <- dcast(allData.melted, subject + activity ~ variable, mean)
write.table(allData.mean, "./Output/tidy.txt", row.names = FALSE, quote = FALSE)
