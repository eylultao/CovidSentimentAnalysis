library(forcats)
library(e1071)
library(caTools)
library(caret)

getwd()
setwd("/Users/eylulaygun/Desktop/Year\ 5/stat\ 447B/CovidSentimentAnalysis")

# read dataframe and perform basic transformations
df <- read.csv("02-updated_dataframe-apr06.csv")
training_set <- read.csv("training_set.csv")
testing_set <- read.csv("testing_set.csv")


# fix the order of factoring for popularity score 
# I am repeatedly doing this each time i read csv as it doesn't conserve factor as type, nor the ordering
training_set$popularity_score_ctg <- as.factor(training_set$popularity_score_ctg)
testing_set$popularity_score_ctg <- as.factor(testing_set$popularity_score_ctg)
training_set$popularity_score_ctg <- fct_infreq(training_set$popularity_score_ctg)
testing_set$popularity_score_ctg <- fct_infreq(testing_set$popularity_score_ctg)


# Naive Bayes Classification
set.seed(420)
# Model with just compound score
nb_classifier_0 <- naiveBayes(popularity_score_ctg ~ compound_score , data = training_set)
out_pred_0 <- predict(nb_classifier_0, newdata = testing_set)
cm_0 <- table(testing_set$popularity_score_ctg, out_pred_0) # Confusion Matrix
print(cm_0)
confusionMatrix(cm_0) # Model Evaluation, using built-in fn

# add extra explanatory variables: Hashtag Count, User Verified
nb_classifier_1 <- naiveBayes(popularity_score_ctg ~ compound_score + hashtags_count + user_verified, data = training_set)
out_pred_1 <- predict(nb_classifier_1, newdata = testing_set)
cm_1 <- table(testing_set$popularity_score_ctg, out_pred_1)
print(cm_1)
confusionMatrix(cm_1)

# add more explanatory variables: Tweet Age
nb_classifier_2 <- naiveBayes(popularity_score_ctg ~ compound_score + hashtags_count + user_verified +tweet_age, data = training_set)
out_pred_2 <- predict(nb_classifier_2, newdata = testing_set)
cm_2 <- table(testing_set$popularity_score_ctg, out_pred_2)
print(cm_2)
confusionMatrix(cm_2)

save(nb_classifier_2, file = "naivebayes-final-model.RData")
save(cm_2, file = "naivebayes-confusion-matrix.RData")

