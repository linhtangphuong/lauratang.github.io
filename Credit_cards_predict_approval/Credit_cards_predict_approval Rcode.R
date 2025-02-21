library(readxl)
library(dplyr)
library(tidyverse)
credit <- read_excel('default of credit card clients.xlsx')
credit 
#Cleaning Data and Imputing Data
#Missing values
sum(is.na(credit))
#Check duplicate
sum(duplicated(credit))
#Check if there is any wrong value in potential columns
unique(credit$LIMIT_BAL)
unique(credit$SEX)
unique(credit$EDUCATION) #There are unknown values such as 0,5,6
unique(credit$MARRIAGE) #There are unknown value such as 0
unique(credit$AGE)
unique(credit$PAY_0)#There are unknown value such as 0,-2
unique(credit$PAY_2)#There are unknown value such as 0,-2
unique(credit$PAY_3)#There are unknown value such as 0,-2
unique(credit$PAY_4)#There are unknown value such as 0,-2
unique(credit$PAY_5)#There are unknown value such as 0,-2
unique(credit$PAY_6)#There are unknown value such as 0,-2
unique(credit$`default payment next month`)
#Replace values of 0,5,6 into 4 as "other"
credit$EDUCATION[credit$EDUCATION == 0] <- 4
credit$EDUCATION[credit$EDUCATION == 5] <- 4
credit$EDUCATION[credit$EDUCATION == 6] <- 4
unique(credit$EDUCATION) #Check values
#Replace values of 0 into 3 as "other"
credit$MARRIAGE[credit$MARRIAGE == 0] <- 3
unique(credit$MARRIAGE) #check values
#Replace values of 0 to 1 and -2 to -1:
credit$PAY_0[credit$PAY_0 == 0] <- 1
credit$PAY_0[credit$PAY_0 == -2] <- -1
credit$PAY_2[credit$PAY_2 == 0] <- 1
credit$PAY_2[credit$PAY_2 == -2] <- -1
credit$PAY_3[credit$PAY_3 == 0] <- 1
credit$PAY_3[credit$PAY_3 == -2] <- -1
credit$PAY_4[credit$PAY_4 == 0] <- 1
credit$PAY_4[credit$PAY_4 == -2] <- -1
credit$PAY_5[credit$PAY_5 == 0] <- 1
credit$PAY_5[credit$PAY_5 == -2] <- -1
credit$PAY_6[credit$PAY_6 == 0] <- 1
credit$PAY_6[credit$PAY_6 == -2] <- -1
#Check values
unique(credit$PAY_0)
unique(credit$PAY_2)
unique(credit$PAY_3)
unique(credit$PAY_4)
unique(credit$PAY_5)
unique(credit$PAY_6)
str(credit)
#Replace data types to factors
credit$SEX <- as.factor(credit$SEX)
credit$EDUCATION <- as.factor(credit$EDUCATION)
credit$MARRIAGE <- as.factor(credit$MARRIAGE)
credit$PAY_0 <- as.factor(credit$PAY_0)
credit$PAY_2 <- as.factor(credit$PAY_2)
credit$PAY_3 <- as.factor(credit$PAY_3)
credit$PAY_4 <- as.factor(credit$PAY_4)
credit$PAY_5 <- as.factor(credit$PAY_5)
credit$PAY_6 <- as.factor(credit$PAY_6)
credit$`default.payment.next.month` <- as.factor(credit$`default.payment.next.month`)
str(credit)
summary(credit)

#Explore data
summary(credit)
library(ggplot2)
#Chart 1: Histogram Cahrt of Borrower's Age
plot_5 <- ggplot(credit, aes(x = AGE)) +
  geom_histogram(bins = 30, fill = "pink", color = "black")
plot_5


#Chart 2: Default payment status in different genders
plot_9 <-ggplot(credit, mapping = aes(x = SEX, fill = `default.payment.next.month`)) +
  geom_bar() +
  ggtitle("SEX") +
  stat_count(aes(label = ..count..), geom = "label")
plot_9


##Figure 17: Chi-squared test of independence between 'SEX' and 'default payment next month'
contingency_table <- table(credit$SEX, credit$default.payment.next.month)
chi_squared_test <- chisq.test(contingency_table)
print(chi_squared_test)


#Chart 3: Default payment in different educational levels
plot_11 <-ggplot(credit, mapping = aes(x = EDUCATION, fill = `default.payment.next.month`)) +
  geom_bar() +
  ggtitle("EDUCATION") +
  stat_count(aes(label = ..count..), geom = "label")
plot_11


## Figure 18: Chi-squared test of independence between 'EDUCATION' and 'default.payment.next.month'
contingency_table_1 <- table(credit$EDUCATION, credit$default.payment.next.month)
chi_squared_test <- chisq.test(contingency_table_1)
print(chi_squared_test)


# Chart 5: Box plot of bill amount in July 2005 and default payment status
plot_10 <- ggplot(credit, aes(y = `default.payment.next.month`, x = BILL_AMT3)) +geom_boxplot()
plot_10



# Predictive modelling

### Decision tree

#Decision Trees
library(caret)
library(rpart)
library(rpart.plot)
set.seed(123)
#Create a stratified split
trainIndex <- createDataPartition(credit$default.payment.next.month, p = 0.7, list = FALSE)
train_data <- credit[trainIndex, ]
test_data <- credit[-trainIndex, ]
#Verify the split
table(train_data$default.payment.next.month) / nrow(train_data)
table(test_data$default.payment.next.month) / nrow(test_data)
#set up cross-validation
fitControl <- trainControl(method = "cv", number = 10, savePredictions = "final", classProbs = TRUE)
#Adjust factor levels to valid R variable names
credit$default.payment.next.month <- as.factor(credit$default.payment.next.month)
levels(credit$default.payment.next.month) <- make.names(levels(credit$default.payment.next.month))
train_data$default.payment.next.month <- as.factor(train_data$default.payment.next.month)
levels(train_data$default.payment.next.month) <- make.names(levels(train_data$default.payment.next.month))
test_data$default.payment.next.month <- as.factor(test_data$default.payment.next.month)
levels(test_data$default.payment.next.month) <- make.names(levels(test_data$default.payment.next.month))
#Check new levels
levels(train_data$default.payment.next.month)
levels(test_data$default.payment.next.month)
#Decicion Tree Model
decision_tree_model <- train(default.payment.next.month ~ ., data = train_data,
                             method = "rpart", trControl = fitControl)
#Model Summary
print(decision_tree_model)
#Make predictions on the test set
predictions <- predict(decision_tree_model, test_data)
#View prediction
print(predictions)
#Generate a confusion Matrix
conf_mat <- confusionMatrix(predictions, test_data$default.payment.next.month)
#print the confusion matrix and other evaluation metrics
print(conf_mat)
accuracy <- confusion_mat$overall['Accuracy']
precision <- confusion_mat$byClass['Pos Pred Value']
recall <- confusion_mat$byClass['Sensitivity']
print(paste("Precision:", precision))
print(paste("Recall:", recall))
print(paste("Accuracy:", accuracy))
#Plot the decision tree
rpart.plot(decision_tree_model$finalModel)

#Random Forests
#Install Packages and Load Library
install.packages("randomForest")
install.packages("caret")
library(randomForest)
library(caret)
#Setting Seed
set.seed(123)
#Split data into training and testing (70% train, 30% test)
#Create a stratified split
trainIndex <- createDataPartition(credit$default.payment.next.month, p = 0.7, list = FALSE,times = 1)
train_data <- credit[trainIndex, ]
test_data <- credit[-trainIndex, ]
#Check if the split is stratified correctly
table(train_data$default.payment.next.month) / nrow(train_data)
table(test_data$default.payment.next.month) / nrow(test_data)
#Random Forest Model
random_forest_model <- randomForest(default.payment.next.month ~ ., data = train_data, ntree = 100, mtry = 3, importance = TRUE)
#Model summary
print(random_forest_model)
varImpPlot(random_forest_model)
importance(random_forest_model)
# Predicting on the test data
rf_prediction <- predict(random_forest_model, test_data)
#View the predictions
print(rf_prediction)
#Confusion Matrix and calculation of accuracy, precision, recall
confusion_mat <- confusionMatrix(rf_predictions, test_data$default.payment.next.month)
print(confusion_mat)
accuracy <- confusion_mat$overall['Accuracy']
precision <- confusion_mat$byClass['Pos Pred Value']
recall <- confusion_mat$byClass['Sensitivity']
F1 <- 2 * (precision * recall / (precision + recall))
print(paste("Precision:", precision))
print(paste("Recall:", recall))
print(paste("Accuracy:", accuracy))
print(paste("F1 Score:", F1))
print(confusion_mat$byClass)
```

### Support Vector Machine (SVM)
```{r}
#Support Vector Machine (SVM)
#Packages for SVM
install.packages("e1071")
library(e1071)
data(credit)
attach(credit)
## Normalization
nor <-function(x) { (x -min(x))/(max(x)-min(x)) }
credit_norm <- as.data.frame(lapply(credit, nor))
summary(credit_norm)
##Split train and test data
install.packages("caret")
library(caret)
# Using data partitioning
indexes <- createDataPartition(credit$default.payment.next.month,times = 1,p = 0.7,list = FALSE)
credit.train <- credit[indexes,]
credit.test <- credit[-indexes,]
# Check for proportion of labels in both training and test split
prop.table(table(credit$default.payment.next.month))
prop.table(table(credit.train$default.payment.next.month))
prop.table(table(credit.test$default.payment.next.month))
# Fit decision model to training set
model <- svm(default.payment.next.month ~ ., data = credit.train)
print(model)
summary(model)
# Predict on the test set
pred.test <- predict(model, credit.test)
predictions<-ifelse(pred.test>0.5, 1, 0)
# Check accuracy on the test set
table(predictions, credit.test$default.payment.next.month)
## Evaluation
# Evaluation for performance using precision, Recall and Accuracy
conf_matrix <- confusionMatrix(factor(predictions), factor(credit.test$default.payment.next.month))
precision <- conf_matrix$byClass["Precision"]
recall <- conf_matrix$byClass["Recall"]
accuracy <- conf_matrix$overall["Accuracy"]
print(paste("Precision:", precision))
print(paste("Recall:", recall))
print(paste("Accuracy:", accuracy))

#K-nearest Neighbour (KNN)
head(credits)## see the structured
##the normalization function is created
nor <-function(x) { (x -min(x))/(max(x)-min(x)) }
credit_norm <- as.data.frame(lapply(credit, nor))
summary(credit_norm)
##load the package class
library(class)
library(tidyverse)
##run knn function
library(caret)
# Using data partitioning
indexes <- createDataPartition(credit$default.payment.next.month,times = 1,p = 0.7,list = FALSE)
credit.train <- credit[indexes,]
credit.test <- credit[-indexes,]
# Check for proportion of labels in both training and test split
prop.table(table(credit$default.payment.next.month))
prop.table(table(credit.train$default.payment.next.month))
prop.table(table(credit.test$default.payment.next.month))
library(class) # Importing class library for knn
library(tidyverse)
model <- knn(credit.train, credit.test, cl = credit.train$default.payment.next.month, k=13) # Assuming k=5, you can adjust it accordingly
#####
test_labels <- credit.test$default.payment.next.month
# A (same as B)
tab <- table(model,credit.test$default.payment.next.month)
print(tab)
#####
# Check accuracy on the test set
conf_matrix <- confusionMatrix(factor(model), factor(credit.test$default.payment.next.month))
precision <- conf_matrix$byClass["Pos Pred Value"]
recall <- conf_matrix$byClass["Sensitivity"]
accuracy <- conf_matrix$overall["Accuracy"]
# Print evaluation metrics
print(paste("Precision:", precision))
print(paste("Recall:", recall))
print(paste("Accuracy:", accuracy))
```

### Artificial Neural Network (ANN)
```{r}
#Artificial Neural Network (ANN)
library(neuralnet)
library(mlbench)
head(credit)## see the structured
##Generate a random number that is 70% of the total number of rows in dataset.
ran <- sample(1:nrow(credit), 0.7 * nrow(credit))
##the normalization function is created
nor <-function(x) { (x -min(x))/(max(x)-min(x)) }
##Run nomalization
creditCards_norm <- as.data.frame(lapply(credit, nor))
summary(creditCards_norm)
##Split train and test data
install.packages("caret")
library(caret)
# Using data partitioning
indexes <- createDataPartition(credit$default.payment.next.month,times = 1,p = 0.7,list = FALSE)
credit.train <- credit[indexes,]
credit.test <- credit[-indexes,]
# Check for proportion of labels in both training and test split
prop.table(table(credit$default.payment.next.month))
prop.table(table(credit.train$default.payment.next.month))
prop.table(table(credit.test$default.payment.next.month))
# fit neural network
nn=neuralnet(default.payment.next.month~ .,data=credit.train,
             hidden = 2,act.fct = "logistic", linear.output = FALSE)
plot(nn)
# Predict on the test set
pred.test <- predict(model, credit.test)
predictions<-ifelse(pred.test>0.5,1,0)
# Check accuracy on the test set
table(predictions, credit.test$default.payment.next.month)
# Evaluation
library(caret)
conf_matrix <- confusionMatrix(factor(predictions), factor(credit.test$default.payment.next.month))
precision <- conf_matrix$byClass["Precision"]
recall <- conf_matrix$byClass["Recall"]
accuracy <- conf_matrix$overall["Accuracy"]
print(paste("Precision:", precision))
print(paste("Recall:", recall))
print(paste("Accuracy:", accuracy))