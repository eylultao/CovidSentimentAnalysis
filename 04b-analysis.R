getwd()
setwd("/Users/eylulaygun/Desktop/Year\ 5/stat\ 447B/CovidSentimentAnalysis")

# read dataframe and perform basic transformations
df <- read.csv("02-updated_dataframe-apr06.csv")
training_set <- read.csv("training_set.csv")
testing_set <- read.csv("testing_set.csv")


# fix the order of factoring for popularity score 
library(forcats)
training_set$popularity_score_ctg <- as.factor(training_set$popularity_score_ctg)
testing_set$popularity_score_ctg <- as.factor(testing_set$popularity_score_ctg)
training_set$popularity_score_ctg <- fct_infreq(training_set$popularity_score_ctg)
testing_set$popularity_score_ctg <- fct_infreq(testing_set$popularity_score_ctg)


# Naive Bayes Classification
library(e1071)
library(caTools)
library(caret)

set.seed(420)
nb_classifier_0 <- naiveBayes(popularity_score_ctg ~ compound_score , data = training_set)
out_pred_0 <- predict(nb_classifier_0, newdata = testing_set)
cm_0 <- table(testing_set$popularity_score_ctg, out_pred_0) # Confusion Matrix
print(cm_0)
# Model Evauation, using built-in fn
confusionMatrix(cm_0)

# add extra explanatory variables
nb_classifier_1 <- naiveBayes(popularity_score_ctg ~ compound_score + hashtags_count + user_verified, data = training_set)
out_pred_1 <- predict(nb_classifier_1, newdata = testing_set)
cm_1 <- table(testing_set$popularity_score_ctg, out_pred_1)
print(cm_1)
confusionMatrix(cm_1)

# accuracy doesn't increase even on the training_set  predictions
in_pred_1 <- predict(nb_classifier_1, newdata = training_set)
cm_1 <- table(training_set$popularity_score_ctg, in_pred_1)
print(cm_1)
confusionMatrix(cm_1)



