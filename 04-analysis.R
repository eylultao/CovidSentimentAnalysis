library(mlbench)
library(VGAM)
library(rpart) 
library(rpart.plot) 
library(randomForest)

library(VGAM)

getwd()
setwd("/Users/eylulaygun/Desktop/Year\ 5/stat\ 447B/CovidSentimentAnalysis")

# read dataframe and perform basic transformations
df <- read.csv("updated_dataframe-apr06-2.csv", stringsAsFactors = T)
training_set <- read.csv("training_set.csv", stringsAsFactors = T)
testing_set <- read.csv("testing_set.csv", stringsAsFactors = T)




### try to predict popularity score as cetagorical

logit1= glm(popularity_score_ctg ~ hashtags_count + compound_score + overall_sentiment,family=binomial(link="logit"),data=training_set)
summary(logit1)

library(rpart) 
library(rpart.plot) 
model2 <- rpart(popularity_score_ctg ~ hashtags_count + compound_score , data=training_set)   
par(mfrow=c(1,1))
rpart.plot(model2, box.palette = "blue") 
tree_out_pred =predict(model2,newdata=testing_set)


boxplot(training_set$hashtags_count, training_set$retweets_ctg)




