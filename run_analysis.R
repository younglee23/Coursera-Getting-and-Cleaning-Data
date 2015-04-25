#########################################
# Coursera -   Getting and Cleaning Data
#              April 2015
#              Course Project
#              Young Lee
#########################################

# Requires:
#         Libraries
#              - dplyr
#              - plyr
#              - data.table(?)

require(dplyr)
require(plyr)
require(data.table)


# Prepare Data
#         If the data directory does not exist, Download and prep data.  This step is unnecessary as
#         the instructions say to assume the data exists in your working directory
#
     fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
     destfile <- "./Dataset.zip"
     dataDir <- "./UCI HAR Dataset"
     tidyFile <- "tidyData.txt"

     if (!file.exists(dataDir)) {
          download.file(fileUrl, destfile, method="curl")
          unzip(destfile)
     }
     
     setwd(dataDir)

#
# Step #1 - Merge training and test sets into a single data set
# 
#    Ideally, we would merge steps #1 and #2 so that we only read into memory the columns that are
#    required (in order to reduce the memory requirements).  For this exercise we will take it step-wise.
#    To accomplish this step we will:
#
#         a) read in each of the following meta data files:
#              - features.txt           names of the columns in the measures tables (files starting with X_)
#              - activity_labels.txt    human readable name of the activities identified in the labels file
#                                       (files starting with y_)
#         b) read in each (train and test) data set (which comes in 3 parts each):
#              - <test|train>/subject_<test|train>.txt      ties the row to a specific subject
#              - <test|train>/X_<test|train>.txt            the row of measurements
#              - <test|train>/y_<test|train>.txt            the labeled activity per row
#         c) attach column names to the data sets
#         d) merge the separate data set columns together to form a single test table and train table
#         e) merge the rows of the test and train tables to form a single data set
#

#    Step 1a)
     features <- read.table("./features.txt", sep="")
     activity_labels <- read.table("./activity_labels.txt", sep="")

#    Step 1b)
     test_data_subjects  <- read.table("./test/subject_test.txt")
     test_data_measures  <- read.table("./test/X_test.txt")
     test_data_labels    <- read.table("./test/y_test.txt")
     train_data_subjects <- read.table("./train/subject_train.txt")
     train_data_measures <- read.table("./train/X_train.txt")
     train_data_labels   <- read.table("./train/y_train.txt")

#    Step 1c)
     names(test_data_subjects)  <- c("subject")
     names(train_data_subjects) <- c("subject")
     names(test_data_labels)    <- c("activity_code")
     names(train_data_labels)   <- c("activity_code")
     names(activity_labels)     <- c("activity_code", "activity_name")
     names(test_data_measures)  <- features$V2
     names(train_data_measures) <- features$V2

#    Step 1d)
     test_data   <- cbind(test_data_subjects, test_data_labels, test_data_measures)
     train_data  <- cbind(train_data_subjects, train_data_labels, train_data_measures)

#    Step 1e)
     complete_data <- rbind(test_data, train_data)

#
# Step #2 - Extracts only the measurements on the mean and standard deviation for each measurement
#
#    We will use grep and regex patterns to find column names that we wish to keep then overwrite
#    the complete data table with the just the data columns we wish to keep.
#
#    The regex pattern we use will look for anything column name that contains any of the following
#    text patterns: "subject", "activity", "mean()", or "std()".  In order to find the parenthesis in R, 
#    we must escape (precede) the special characters.
#    
     columns_to_keep <- grep("subject|activity|mean\\(\\)|std\\(\\)",names(complete_data))
     complete_data <- complete_data[columns_to_keep]


#
# Step #3 - Uses descriptive activity names to name the activities in the data set
#
#    First, we add activity name to complete_data using the merge command to join the table 
#    activity_labels on the common key/column called activity_code.
#
#    In order to keep the data tidy, we eliminate the duplicative column activity code from complete_data
#    using the dplyr package function "select".
#    
     complete_data <- merge(complete_data, activity_labels, by="activity_code")
     complete_data <- select(complete_data, -activity_code)


#
# Step #4 - Appropriately labels the data set with descriptive variable names. 
#
#    
#
     names(complete_data) <- sub("^t","time_", names(complete_data))
     names(complete_data) <- sub("^f","frequency_", names(complete_data))
     names(complete_data) <- sub("Acc","_Accelerometer", names(complete_data))
     names(complete_data) <- sub("Gyro","_Gyroscope", names(complete_data))
     names(complete_data) <- sub("Jerk","_Jerk", names(complete_data))
     names(complete_data) <- sub("Mag","_Magnitude", names(complete_data))
     names(complete_data) <- sub("\\(\\)","", names(complete_data))


#
# Step #5 - From the data set in step 4, creates a second, independent tidy data set 
#           with the average of each variable for each activity and each subject.
#
#    Using the ddply function from the plyr package, we group on the subject and activity_name columns
#    and average each of the remaining columns.  Then we write the resulting table to a text file for
#    submission.
#
     averages_data <- ddply(complete_data, .(subject, activity_name), colwise(mean))
     write.table(averages_data, tidyFile, sep="\t", row.names=FALSE)