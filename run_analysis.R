library(dplyr)

## Download and unzip the datasets
data <- "C:/Users/rgelber/Desktop/Data Science Files/wearable.zip"
file <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(file, data)
unzip(data)

## Read in the activity and feature names
activity_labels <- read.table("UCI HAR Dataset/activity_labels.txt")
activity_labels[,2] <- as.character(activity_labels[,2])
features <- read.table("UCI HAR Dataset/features.txt")
features[,2] <- as.character(features[,2])

## Filter to only mean and standard deviation measures and clean up column names
featMS <- grep(".*mean.*|.*std.*", features[,2])
featMS.ColNames <- features[featMS, 2]
featMS.ColNames <- gsub("[()]", "", featMS.ColNames)
featMS.ColNames <- gsub("-mean", "Mean", featMS.ColNames)
featMS.ColNames <- gsub("-std", "StDev", featMS.ColNames)
featMS.ColNames <- gsub("^(t)", "Time", featMS.ColNames)
featMS.ColNames <- gsub("^(f)", "Frequency", featMS.ColNames)

## Read in the training and test data
train <- read.table("UCI HAR Dataset/train/X_train.txt")[featMS]
train_act <- read.table("UCI HAR Dataset/train/y_train.txt")
train_subj <- read.table("UCI HAR Dataset/train/subject_train.txt")
test <- read.table("UCI HAR Dataset/test/X_test.txt")[featMS]
test_act <- read.table("UCI HAR Dataset/test/y_test.txt")
test_subj <- read.table("UCI HAR Dataset/test/subject_test.txt")

## Combine the training and test data into one table
train_all <- cbind(train_subj, train_act, train)
test_all <- cbind(test_subj, test_act, test)
train_test <- rbind(test_all, train_all)
colnames(train_test) <- c("subject", "activity", featMS.ColNames)

## Turn the activities from columns into rows 
train_test$activity <- factor(train_test$activity, levels = activity_labels[,1], labels = activity_labels[,2])
train_test$activity <- as.factor(train_test$activity)

## Aggregate the data based by aubject and activity and take the means of the data values. Write the tidy dataset to a text file
tidy_tt <- aggregate(. ~ subject + activity, train_test, FUN = "mean")
write.table(tidy_tt, "tidy_tt.txt", row.names = FALSE)
