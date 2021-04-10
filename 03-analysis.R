getwd()
setwd("/Users/eylulaygun/Desktop/Year\ 5/stat\ 447B/CovidSentimentAnalysis")

df <- read.csv("02-updated_dataframe-apr06.csv")
training_set <- read.csv("training_set.csv")
testing_set <- read.csv("testing_set.csv")

# Data visualizations
summary(df)

plot(table(df$overall_sentiment))
hist(df$compound_score, c(-1, -0.5, -0.1, 0.1, 0.5, 1))  # distribution, skewed towards positive
hist(df$compound_score, c(-1, -0.8, -0.6, -0.4, -0.2, 0, 0.2, 0.4, 0.6, 0.8, 1))  # distribution, skewed towards positive
hist(df$compound_score,  c(-1, -0.9, -0.8,-0.7, -0.6, -0.5,-0.4,-0.3, -0.2,-0.1, 0,0.1, 0.2,0.3, 0.4, 0.5, 0.6, 0.7, 0.8,0.9, 1))  # distribution, skewed towards positive
sum(df$compound_score> 0.05)
sum(df$compound_score< -0.05)

df$retweets_ctg <- cut(df$retweets, breaks = c(-0.01, 0.5, 1, 5, 1000), labels =  c("NO", "AVG", "YES", "VYES"))
df$favorites_ctg <- cut(df$favorites, breaks = c(-0.01, 0.5, 1, 5, 1000), labels =  c("NO", "AVG", "YES", "VYES"))
print(table(df$retweets_ctg))
print(table(df$favorites_ctg))

print(df$retweets>2 )
summary(df$retweets)
summary(df$favorites)

cor.test(df$retweets, df$favorites,  method = "spearman") # reject null hypothesis
cor.test(df$retweets, df$compound_score, method = "spearman") # can't reject
cor.test(df$favorites, df$compound_score, method = "spearman") # reject null hypothesis


labels =  c("VNEG", "NEG", "NEU", "POS", "VPOS")
par(mfrow=c(2,3))
for (i in 1:5){
  sentiment_i_retweets = df$retweets2[which(df$overall_sentiment == labels[i])]
  sentiment_i_scores = df$compound_score[which(df$overall_sentiment == labels[i])]
  print(head(sentiment_i_scores))
  print(labels[i])
  #boxplot(sentiment_i_scores, xlab = labels[i], ylab= "scores")
  boxplot(sentiment_i_retweets, xlab = labels[i], ylab= "retweets^(1/4)")
}

table(training_set$user_location)
table(training_set$user_verified)
table(testing_set$user_verified)
par(mfrow=c(2,2))
# see how average compound score has changed over time for tweets
mean_score_by_day = aggregate(training_set$compound_score, by = list(training_set$date), FUN = mean )
plot( x = as.factor(mean_score_by_day$Group.1), y= mean_score_by_day$x, ylab = "Mean Score") 
max_score_by_date =  aggregate(training_set$compound_score, by = list(training_set$date), FUN = max )
plot( x = as.factor(max_score_by_date$Group.1), y= max_score_by_date$x, ylab = "Max Score") 
min_score_by_date = aggregate(training_set$compound_score, by= list(training_set$date), FUN = min)
plot( x = as.factor(min_score_by_date$Group.1), y= min_score_by_date$x, ylab = "Min Score") # increasing trend
median_score_by_date = aggregate(training_set$compound_score, by= list(training_set$date), FUN = median)
plot( x = as.factor(median_score_by_date$Group.1), y= median_score_by_date$x, ylab = "Median Score") # slightly? increase, most values are zero.

difference_min_max = max_score_by_date$x - min_score_by_date$x # over time, tweets get "milder"

par(mfrow=c(2,3))
# How does number of hashtags change in terms of tweet sentiment
for (i in 1:5){
  sentiment_i_hashtag_count = df$hashtags_count[which(df$overall_sentiment == labels[i])]
  sentiment_i_scores = df$compound_score[which(df$overall_sentiment == labels[i])]
  print(head(sentiment_i_hashtag_count))
  print(labels[i])
  #boxplot(sentiment_i_scores, xlab = labels[i], ylab= "scores")
  boxplot(sentiment_i_hashtag_count, xlab = labels[i], ylab= "hashtag count")
}





labels =  c("NO", "AVG", "YES", "VYES")
par(mfrow=c(2,2))
for (i in 1:4){
  sentiment_i_hashtags = training_set$hashtags_count[which(training_set$retweets_ctg == labels[i])]
  sentiment_i_scores = training_set$compound_score[which(training_set$retweets_ctg == labels[i])]
  print(head(sentiment_i_scores))
  print(labels[i])
  boxplot(sentiment_i_hashtags, xlab = labels[i], ylab= "# of hashtags")
}


