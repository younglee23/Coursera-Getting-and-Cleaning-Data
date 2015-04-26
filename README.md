# Coursera-Getting-and-Cleaning-Data
              April 2015
              Course Project
              Young Lee


The purpose of this project is to demonstrate your ability to collect, work with, and clean a data set. The goal is to prepare tidy data that can be used for later analysis. You will be graded by your peers on a series of yes/no questions related to the project. You will be required to submit: 1) a tidy data set as described below, 2) a link to a Github repository with your script for performing the analysis, and 3) a code book that describes the variables, the data, and any transformations or work that you performed to clean up the data called CodeBook.md. You should also include a README.md in the repo with your scripts. This repo explains how all of the scripts work and how they are connected.  

One of the most exciting areas in all of data science right now is wearable computing - see for example this article . Companies like Fitbit, Nike, and Jawbone Up are racing to develop the most advanced algorithms to attract new users. The data linked to from the course website represent data collected from the accelerometers from the Samsung Galaxy S smartphone. A full description is available at the site where the data was obtained: 

http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones 

Here are the data for the project: 

https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip 

You should create one R script called run_analysis.R that does the following. 

		1. Merges the training and the test sets to create one data set.
		2. Extracts only the measurements on the mean and standard deviation for each measurement. 
		3. Uses descriptive activity names to name the activities in the data set
		4. Appropriately labels the data set with descriptive variable names. 
		5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

Good luck!

----------------------------------

# Step #1 - Merge training and test sets into a single data set
 
    Ideally, we would merge steps #1 and #2 so that we only read into memory the columns that are
    required (in order to reduce the memory requirements).  For this exercise we will take it step-wise.
    To accomplish this step we will:

         a) read in each of the following meta data files:
              - features.txt           names of the columns in the measures tables (files starting with X_)
              - activity_labels.txt    human readable name of the activities identified in the labels file
                                       (files starting with y_)
         b) read in each (train and test) data set (which comes in 3 parts each):
              - <test|train>/subject_<test|train>.txt      ties the row to a specific subject
              - <test|train>/X_<test|train>.txt            the row of measurements
              - <test|train>/y_<test|train>.txt            the labeled activity per row
         c) attach column names to the data sets
         d) merge the separate data set columns together to form a single test table and train table
         e) merge the rows of the test and train tables to form a single data set

----------------------------------
         
# Step #2 - Extracts only the measurements on the mean and standard deviation for each measurement

    We will use grep and regex patterns to find column names that we wish to keep then overwrite
    the complete data table with the just the data columns we wish to keep.

    The regex pattern we use will look for anything column name that contains any of the following
    text patterns: "subject", "activity", "mean()", or "std()".  In order to find the parenthesis in R, 
    we must escape (precede) the special characters (e.g. "\\(\\)" in regex will find the "()" pattern in text).
    
    For the purposes of this exercise, we assume we are only extracting values that are the mean of measures. Hence,
    we exclude values that are calculated based on the mean measurements (like angles based on mean, etc).  In
    order to include these values, we could drop the parenthesis from the regex text patterns that we search.
    
----------------------------------
         
# Step #3 - Uses descriptive activity names to name the activities in the data set

    First, we add activity name to complete_data using the merge command to join the table 
    activity_labels on the common key/column called activity_code.

    In order to keep the data tidy, we eliminate the duplicative column activity code from complete_data
    using the dplyr package function "select".
    
----------------------------------
         
# Step #4 - Appropriately labels the data set with descriptive variable names.

    Using the sub command, we replace abbreviated values in the column names with readable names
    
----------------------------------
         
# Step #5 - From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

    Using the ddply function from the plyr package, we group on the subject and activity_name columns
    and average each of the remaining columns.  Then we write the resulting table to a text file for
    submission.
    
