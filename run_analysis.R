## run_analysis.R
library(reshape2)

setwd("./UCI HAR Dataset")
xtrain <-  read.table("train/X_train.txt", sep="")
xtest <-  read.table("test/X_test.txt", sep="")
ytrain <-  read.table("train/y_train.txt", sep="")
ytest <-  read.table("test/y_test.txt", sep="")

# merge the training and test sets
xfull <- rbind(xtrain, xtest)
yfull <- rbind(ytrain, ytest)

# rm(c(xtrain, ytrain, xtest, ytest))

# set data column names using features.txt and activitiy_labels.txt

features <- read.table("features.txt", sep="")[,2]
activities <- read.table("activity_labels.txt", sep="") 
features <- gsub("-", "", features)
features <- gsub("mean\\(\\)", "Mean", features)
features <- gsub("std\\(\\)", "Std", features)

names(xfull) <- features 


activity <- vector(mode="character", length = length(yfull[,1]))

# Read in and label row names appropriately.
for (i in 1:length(unique(yfull[,1]))) activity[which(yfull == i)] <- as.character(activities[,2][i])


subjects <- rbind(read.table("train/subject_train.txt", sep=""), read.table("test/subject_test.txt", sep=""))
subjects[,1] <- paste("Subject#", as.character(subjects[,1]))
names(subjects) <- "SubjectID"

xfull <- cbind(subjects, data.frame((activity)), xfull)


meanscols <- grep("Mean|Std", names(xfull)) # pull index of columns that are mean values of raw data

# cull means data alone and write it out.
reduceddataset <- cbind(xfull[,1:2], xfull[, c(meanscols)])
colnames(reduceddataset)[2] <- "Activity"

setwd("..")
write.table(reduceddataset, "ReducedDataSet.txt")

outds <- melt(reduceddataset, id = c("Activity", "SubjectID"))

summ <- dcast(outds, Activity + SubjectID ~ variable, mean)

write.table(summ, "summarydata.txt")

