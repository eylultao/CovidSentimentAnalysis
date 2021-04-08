getwd()
setwd("/Users/eylulaygun/Desktop/Year\ 5/stat\ 447B/CovidSentimentAnalysis")
data <- read.csv("updated_dataframe.csv")
data4 <- read.csv("updated_dataframe4.csv")
data_new <- read.csv("vaccination_tweets-mar30.csv")
summary(data_new)

data_new$retweets2 <- (data_new$retweets)^(1/3)
data_new$retweets2
write.csv(data_new, "vaccination_tweets_transformed.csv")
data <- read.csv("updated_dataframe-mar30.csv")
data$compound_score2 <- as.factor(data$compound_score)
plot(data$compound_score2, data$retweets2)
data$compound_score2

data_ordered <- data[order(data$user_name),]
data_ordered$date <- as.POSIXct(data_ordered$date,tz=Sys.timezone())
data_training <- data_ordered[1:4500, ]
data_testing <- data_ordered[4501:7417,]

data_ts <- ts(data_testing$compound_score, start=c(2020,12,12), end=c(2021,03,31))
plot(data_ts)

summary(data_training)
summary(data_testing)
(table(data$user_name) >3)

data[data$user_name == "CNBC-TV18",]$compound_score

########## OLD WORK
#Data analysis
data_high_engagement = data[which(data$favorites > 5 | data$retweets > 5),]
summary(data_high_engagement)
plot(data_high_engagement$favorites, data_high_engagement$compound_score)
plot(data_high_engagement$hashtags_count, data_high_engagement$compound_score)

print(data[which(data$hashtags_count > 8),]$text)

# first linear model:
# response variable: Compound_score
# explanatory variables: retweets, favorites, hashtags_count
model1 <- lm(compound_score~ retweets + favorites + hashtags_count , data = data)
summary(model1)

plot(data$compound_score, model1$fitted.values)
plot(data$compound_score, model1$residuals)

plot(data$compound_score, data$hashtags_count)

# Second linear model:
# response variable: Compound_score
# explanatory variables: retweets, favorites, hashtags_count (as factor)
data$hashtags_count_factor = as.factor(data$hashtags_count)
model2 <- lm(compound_score~ retweets + favorites + hashtags_count_factor , data = data)
summary(model2)

plot(data$compound_score, model2$fitted.values)
plot(data$compound_score, model2$residuals)
 
# Third linear model:
# response variable: e^(Compound_score)
# explanatory variables: retweets, favorites, hashtags_count 
model3 <- lm(exp(compound_score)~ retweets + favorites + hashtags_count , data = data)
summary(model3)

plot(exp(data$compound_score), model3$fitted.values)
plot(exp(data$compound_score), model3$residuals)

summary(data)



# 4th linear model:
# response variable: Compound_score
# explanatory variables: retweets, favorites, hashtags_count, user_verified
model4 <- lm(compound_score~ retweets + favorites + hashtags_count + user_verified, data = data)
summary(model4)

plot(data$compound_score, model4$fitted.values)
plot(data$compound_score, model4$residuals)



# overall, in all the mdoels, we can see model is not a good fit yet
# residuals have very obvious linear pattern
# I am currently trying to clean out the data more to see 
# if polarity scores can be improved and whether that would result in better models.
# This is no tthe scope of first presentation obviously, but if you want we can show them as our 
# initial trivial models


