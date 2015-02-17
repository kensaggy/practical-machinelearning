library(caret)
setwd("~/lab/courses/practial-machinelearning/writeup/")
set.seed(12345)


#Load training Data.
data <- read.csv("pml-training.csv")

## Cleaning the data
# 1. Remove unwanted columns (e.g. columns containing names, or irrelevant informaton)
data <- subset(data, select=-c(1:7))

# 2. Remove nearZeroValues 
nzv <- nearZeroVar(data)
data <- data[,-nzv]

# 3. Remove incomplete columns - find columns which are all NA's - They are useless to us.
completeColumns <- (colSums(is.na(data)) == 0)
data <- subset(data, select=completeColumns)
classeColumn <- dim(data)[2] #Classe column is the last column
data[, -classeColumn] <- apply(data[, -classeColumn], 2, function(x) as.numeric(as.character(x)))

## Split the data into training and testing
# Create training and testing sets
inTrain <- createDataPartition(y = data$classe, p=0.7, list=FALSE)
training <- data[inTrain,]
testing <- data[-inTrain,]

# Fit the model
trControl <- trainControl(method = "cv", number = 4, allowParallel = TRUE)
modelFit <- train(training$classe ~. , data=training, method="rf", trControl = trControl, preProcess=c("center","scale"))


predictionData <- read.csv("pml-testing.csv")
predictResults <- predict(modelFit, newdata=predictionData)