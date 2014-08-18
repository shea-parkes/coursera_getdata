#' ## Course Project for Getting and Cleaning Data (Coursera)
#' 
#' ### Developer Notes:
#'   * Inputs, munges, and outputs Human Activity data from the UCI Machine Learning Library
#'   * See ReadMe.md for more information
#'   * Assumes the contents of the Human Activity Datamart are available in the user's working directory

##setwd('E:/getting_data/project')

#' Read in the feature names reference
ref.features <- read.table(
  'features.txt'
  ,col.names=c('id','feature')
  ,stringsAsFactors=FALSE
  )
str(ref.features)

#' Flag those of basic interest (Means and StdDevs)
ref.features$basic <- grepl('-(mean|std)\\(\\)-', ref.features$feature, perl=TRUE)
mean(ref.features$basic)
head(ref.features[ref.features$basic,])

#' Read in the activity reference
ref.activities <- read.table(
  'activity_labels.txt'
  ,col.names=c('id','activity')
  ,stringsAsFactors=FALSE
  )
str(ref.activities)

#' Import the feature and activity data
StackTrainTest <- function(file.prefix, ...) { #file.prefix <- 'X'
  file.names <- paste0(
    c('train/', 'test/')
    ,file.prefix
    ,c('_train.txt', '_test.txt')
    )
  return(do.call(rbind, lapply(file.names, read.table, ...)))
  }

df.features <- StackTrainTest('X', col.names=ref.features$feature)
str(df.features[,1:10])

df.activities <- StackTrainTest('Y', col.names='id')
df.activities$activity <- factor(
  df.activities$id
  ,levels=ref.activities$id
  ,labels=ref.activities$activity
  )
str(df.activities)

df.subject <- StackTrainTest('subject', col.names='id')
df.subject$subject <- factor(df.subject$id)
str(df.subject)

#' Put the data briefly together in a wide format to explore
df.wide <- data.frame(
  subject=df.subject[,'subject',drop=FALSE]
  ,activity=df.activities[,'activity',drop=FALSE]
  ,df.features[,ref.features$basic]
  )
str(df.wide[,1:10])

#' Put together the interesting data in a more usable long format
#'   * Heavily utilizes vector recycling
df.long <- data.frame(
  subject=df.subject$subject
  ,activity=df.activities$activity
  ,feature=rep(ref.features$feature[ref.features$basic], each=nrow(df.features))
  ,value=unlist(df.features[,ref.features$basic], use.names=FALSE)
  )
str(df.long)

#' Collapse the measures by averaging
arr.means <- tapply(df.long$value,subset(df.long,,-value),mean)
str(arr.means)

df.collapse <- data.frame(
  do.call(expand.grid,dimnames(arr.means))
  ,average=as.vector(arr.means)
  )
str(df.collapse)

#' Write out the results
write.table(df.collapse, 'tidy.txt', row.names=FALSE)


#' Double check the answers using Hadley's convenience packages
require(reshape2)
require(plyr)
df.melt <- melt(
  df.wide
  ,c('subject','activity')
  ,variable.name='feature'
  )
levels(df.melt$feature) <- ref.features$feature[ref.features$basic]
str(df.melt)
df.agg <- ddply(
  df.melt
  ,c('subject','activity','feature')
  ,summarize
  ,average=mean(value)
  )
str(df.agg)
df.check <- merge(df.collapse,df.agg,by=c('subject','activity','feature'))
head(df.check)
df.check$check <- df.check$average.x - df.check$average.y
sum(df.check$check)
