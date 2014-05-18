## Getting and Cleaning Data Course Project

A script to clean data collected from the accelerometers from the Samsung Galaxy S smartphone.

* [run_analysis.R](run_analysis.R) - downloads the source archive, unpacks it and constructs the tidy data sets.
* [codebook.md](codebook.md) - list of variables in the tidy datasets.

In more detail the run_analysis.R downloads the data, if it is not already there, then

1. Merges the training and the test sets to create one data set.
2. Extracts only the measurements on the mean and standard deviation for each measurement. 
3. Uses descriptive activity names to name the activities in the data set
4. Appropriately labels the data set with descriptive activity names. 
5. Creates a second, independent tidy data set with the average of each variable for each activity and each subject. 


The data was collected from an experiment by Jorge L. Reyes-Ortiz, Davide Anguita, Alessandro Ghio, Luca Oneto. Their original 
[README](UCI_HAR_Dataset/README.txt)
and
[features_info.txt] (UCI_HAR_Dataset/features_info.txt)
are included for a full description of the data.


