# PracticalMachineLearning
==============================================

# Background
> Using devices such as Jawbone Up, Nike FuelBand, and Fitbit it is now possible to collect a large amount of data about personal activity relatively inexpensively. These type of devices are part of the quantified self movement – a group of enthusiasts who take measurements about themselves regularly to improve their health, to find patterns in their behavior, or because they are tech geeks. One thing that people regularly do is quantify how much of a particular activity they do, but they rarely quantify how well they do it. In this project, your goal will be to use data from accelerometers on the belt, forearm, arm, and dumbell of 6 participants. They were asked to perform barbell lifts correctly and incorrectly in 5 different ways. More information is available from the website here: http://groupware.les.inf.puc-rio.br/har (see the section on the Weight Lifting Exercise Dataset). 

# Prediction Writeup

## General setup
First we'll make sure we set the random seed and some libraries we used so people can reproduce our results:
```r
library(caret)
set.seed(12345)
```

## Setting up and cleaning data.
I started out by loading the entire data set and inspecting it. We notice that the first 7 columns are data that isn't useful to us from a learning prespective (e.g. names, dates, timestamps) so we'll remove those from the dataset:

```r
#Load training Data.
data <- read.csv("pml-training.csv")

## Cleaning the data
# 1. Remove unwanted columns (e.g. columns containing names, or irrelevant informaton)
data <- subset(data, select=-c(1:7))
```

Next I removed Near-Zero-Variance columns, since those mostly don't help with prediction

```r
# 2. Remove nearZeroValues 
nzv <- nearZeroVar(data)
data <- data[,-nzv]
```

Lastly I removed columns which were all NA's and converted the remaining columns to be numeric:

```r
# 3. Remove incomplete columns - find columns which are all NA's - They are useless to us.
completeColumns <- (colSums(is.na(data)) == 0)
data <- subset(data, select=completeColumns)
classeColumn <- dim(data)[2] # Classe column is the last column
data[, -classeColumn] <- apply(data[, -classeColumn], 2, function(x) as.numeric(as.character(x)))
```

## Spliting training and cross validation data sets
I used the standrd 0.7/0.3 ratio split for training data and cross validation set respectfully.

```r
inTrain <- createDataPartition(y = data$classe, p=0.7, list=FALSE)
training <- data[inTrain,]
testing <- data[-inTrain,]
```

## Training
Before training I Pre-Processed the datasets to center and scale the values.
For training I used RandomForest method which gave excellent results for this complex classification.

```r
trControl <- trainControl(method = "cv", number = 4, allowParallel = TRUE)
modelFit <- train(training$classe ~. , data=training, method="rf", trControl = trControl, preProcess = c("center","scale"))
```

## Out of sample error
We can see the error we have on the training data is pretty small:

```r
modelFit$finalModel
```

But this is always the case regarding the data we trained on (could just be over-fitting)
We can inspect the cross validation set we put a side to get a more realistic estimate on how well our algorithm is doing..
We can look at the confusion matrix:

```r
predictions <- predict(modelFit, testing)
confusionMatrix(predictions, testing$classe)
```

Or calculate the accuracy manually:

```r
sum(predictions == testing$classe) / nrow(testing)
```

Overall we estimate our **Out-Of-Sample Error be to be less than 1%**

## Prediction
To predict the **classe** of a set of observations (such as the supplied `pml-testing.csv`) we simply need to call `predict` on our data:

```r
predictionData <- read.csv("pml-testing.csv")
predictResults <- predict(modelFit, newdata=predictionData)
predictResults
```

To write out the result files (for submittion purpose) I used the suggested `pml_write_files` method:

```r
pml_write_files = function(x){
  n = length(x)
  for(i in 1:n){
    filename = paste0("problem_id_",i,".txt")
    write.table(x[i],file=filename,quote=FALSE,row.names=FALSE,col.names=FALSE)
  }
}
```
and called it on the results `predictResults`:

```r
pml_write_files(predictResults)
```
