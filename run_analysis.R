#
# run_analysis.R - Script for the Getting and Cleaning Data Course Project
#
# This script will download the source zip archive and unpack it it is not
# already present in the current directory.
#
# A function is used to load the train and test sub data sets. These sets
# have the same basic format. The features data is used to name the columns
# and the activity_id is merged to the activity name factors.
#
# The data frames are simply appended. Since the subjects are either test
# or train, there is no need to actually merge the data.
#
# A subset frame of every variable which is a "mean" or "std" is created
#
# An aggregated frame of the averages of every variable (even the "std" ones)
# is created. The frame is aggregated on the 3 variables 
# subject,activity,setname. This seems like a good idea anyway, avoids
# needing to merge back the setname and produces the same result as merging
# on subject and activity alone (since subjects are assigned to either set).

# Constants
url <- 'https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip'
destfile <- 'Dataset.zip'
dataset <- 'UCI HAR Dataset'

# Any sample file: existence tells us if the data is unpacked
flagfile <- paste( dataset,"/","test/Inertial Signals/body_acc_x_test.txt", sep="" )

# Check if one of the data files is present. If not then get the data
if( ! file.exists( flagfile ) ) {

    # Download the data archive if it is not already there
    if( ! file.exists(destfile)) {
	download.file(url,destfile=destfile,method='curl')
    }

    unzip(destfile)
}

activity_labels <- read.table(paste(dataset,"/","activity_labels.txt",sep=""),
				header=FALSE,
				col.names=c("activity_id","activity" )
				)

features <- read.table(paste(dataset,"/","features.txt",sep=""),
				header=FALSE,
				col.names=c("id","feature_label" )
				)
# Make clean printable labels by removing characters which look like syntax
# First remove '()' altogether
# Second replace remaining parenthesis and '-' signs by underscores
# Third, remove leading spaces
features$feature = 
	sub( '^  *', '',
	    gsub( '[-(),]', '_',
	    	sub( '()', '', features$feature_label,fixed=TRUE ))
	   )

# Save the feature names as a template for codebook.md
# write.table(features[c(3,2)], file="codebook.txt", quote=FALSE,row.names=FALSE )


# Function to load the data for each set.
loaddata <- function( setname ) {
	# Read the subjects into a data frame
	subjfile <- paste0(dataset,"/",setname,"/","subject_",setname,".txt")
	subjects <- read.table( subjfile, col.names="subject", header=FALSE )

	# Read the subjects into a data frame
	actfile <- paste0(dataset,"/",setname,"/","y_",setname,".txt")
	activities <- read.table( actfile, col.names="activity_id", header=FALSE )

	# 3. Uses descriptive activity names to name the activities in the data set
	# 4. Appropriately labels the data set with descriptive activity names.
	activities <- merge( activities, activity_labels, by.x="activity_id",
				by.y="activity_id", sort=FALSE )

	# Read the actual data values
	setfile <- paste0(dataset,"/",setname,"/","X_",setname,".txt")
	set <- read.table( setfile, col.names=features[,"feature"], header=FALSE )

	# Column bind into a single data frame. Include the setname.
	df <- cbind ( subjects, activities, setname, set )
	df
}

# 1. Merge the test and trainig databases
# Well, just append since they are in the same format and the subjects
# are independent
dataFull <- rbind( loaddata("train"), loaddata("test") )

# 2. Extracts only the measurements on the mean and standard deviation
# for each measurement. 
meanAndStd <- features$feature[ grep("mean|std",
					features$feature,
					ignore.case=TRUE) ]

dataMeanAndStd <- dataFull[,c("subject","activity_id", "activity","setname",
			meanAndStd )]


# 5. Creates a second, independent tidy data set with the average of each
# variable for each activity and each subject. 

#first <- function(x) {x[1] }
#aggregate(x = dataMeanAndStd[,1:4],
#	  by = list( dataMeanAndStd$subject,dataMeanAndStd$activity_id),
#	  FUN = first
#	  )
dataAverages <-
    aggregate(x = dataMeanAndStd[,5:(ncol(dataMeanAndStd)-4)],
	  by = list( dataMeanAndStd$subject,
	  		dataMeanAndStd$activity_id,
			dataMeanAndStd$setname),
	  FUN = mean
	  )
# Fix the first 3 column names
names(dataAverages)[1:3] = c("subject","activity_id","setname")
# Replace the activity description
dataAverages <- merge(dataAverages, activity_labels,
		by.x="activity_id", by.y="activity_id", sort=FALSE )
# and because I like the original column order
n <- ncol(dataAverages)
dataAverages <- dataAverages[, c(2,1, n, 3:(n-1))  ]


# Save the output - it can be recovered by read.table(filename)
write.table( dataFull, file="dataFull.txt" )
write.table( dataMeanAndStd, file="dataMeanAndStd.txt" )
write.table( dataAverages, file="dataAverages.txt" )
