getwd()
setwd("/Users/eylulaygun/Desktop/Year\ 5/stat\ 447B/CovidSentimentAnalysis")

library(ggplot2)
library(ggpubr)
library(forcats)

df <- read.csv("02-updated_dataframe-apr06.csv")
training_set <- read.csv("training_set.csv")

# fix the order of factoring for popularity score 
training_set$popularity_score_ctg <- as.factor(training_set$popularity_score_ctg)
training_set$popularity_score_ctg <- fct_infreq(training_set$popularity_score_ctg) #fixes order of factors
training_set$user_verified <- as.numeric(as.logical(training_set$user_verified))
df$popularity_score_ctg <- as.factor(df$popularity_score_ctg)
df$popularity_score_ctg <- fct_infreq(df$popularity_score_ctg)


# Data visualizations

# Plots for visualizing retweet and favorites calculation.
par(mfrow=c(2,1))
df$retweets_ctg <- cut(df$retweets, breaks = c(-0.01, 0.5, 1, 5, 700), labels =  c("NO", "AVG", "YES", "VYES"))
df$favorites_ctg <- cut(df$favorites, breaks = c(-0.01, 0.5, 1, 5, 2500), labels =  c("NO", "AVG", "YES", "VYES"))
plot(df$retweets_ctg, main = "Distribution of Retweets", ylab = "Frequency")
plot(df$favorites_ctg, main = "Distribution of Favorites", ylab = "Frequency")


# Plot for visualizing popularity and compound scores for entire dataset
par(mfrow=c(3,1))
plot(df$popularity_score_ctg, main = "Pop. Score Distribution After Undersampling")
hist(df$compound_score,  c(-1, -0.9, -0.8,-0.7, -0.6, -0.5,-0.4,-0.3, -0.2,-0.1, 0,0.1, 0.2,0.3, 0.4, 0.5, 0.6, 0.7, 0.8,0.9, 1), xlab = "Compound Score" , main = "Distribution of Compound Score")  # distribution, skewed towards positive
df$compound_score_ctg <- cut(df$compound_score, breaks = c(-1.1, -0.05, 0.05, 1.1), labels =  c("NEG", "NEU", "POS"))
plot(df$compound_score_ctg, ylab = "Frequency", main=" Distribution of Compound Score")

# Boxplot to distinguish useful explanatory variables
box_cs <- ggboxplot(data = training_set, x="popularity_score_ctg", y= "compound_score", xlab = "", ylab= "Compound Score") 
box_hc <- ggboxplot(data = training_set, x="popularity_score_ctg", y= "hashtags_count", xlab = "", ylab= "Hashtags Count") 
box_ta <- ggboxplot(data = training_set, x="popularity_score_ctg", y= "tweet_age",      xlab = "", ylab= "Tweet Age (days)") 
box_uv <- ggboxplot(data = training_set, x="popularity_score_ctg", y= "user_verified",  xlab = "", ylab= "User Verified") 
ggarrange(box_cs, box_hc, box_ta, box_uv)


# Correlation Tests, using Spearman Rank Correlation due to heavily skewed data
cor.test(df$retweets, df$favorites,  method = "spearman")     

cor.test(training_set$popularity_score, training_set$tweet_age, method = "spearman")
cor.test(training_set$popularity_score, training_set$compound_score, method = "spearman")
cor.test(training_set$popularity_score, training_set$hashtags_count, method = "spearman")
cor.test(training_set$popularity_score, training_set$user_verified, method = "spearman")
cor.test(training_set$compound_score,   training_set$tweet_age, method = "spearman")
cor.test(training_set$compound_score,   training_set$hashtags_count, method = "spearman")
cor.test(training_set$compound_score,   training_set$user_verified, method = "spearman")


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

# 
# par(mfrow=c(2,3))
# # How does number of hashtags change in terms of tweet sentiment
# for (i in 1:5){
#   sentiment_i_hashtag_count = df$hashtags_count[which(df$overall_sentiment == labels[i])]
#   sentiment_i_scores = df$compound_score[which(df$overall_sentiment == labels[i])]
#   print(head(sentiment_i_hashtag_count))
#   print(labels[i])
#   #boxplot(sentiment_i_scores, xlab = labels[i], ylab= "scores")
#   plot(sentiment_i_hashtag_count, xlab = labels[i], ylab= "hashtag count")
# }
# 
# 
# labels =  c("NO", "AVG", "YES", "VYES")
# par(mfrow=c(2,2))
# for (i in 1:4){
#   sentiment_i_hashtags = training_set$hashtags_count[which(training_set$retweets_ctg == labels[i])]
#   sentiment_i_scores = training_set$compound_score[which(training_set$retweets_ctg == labels[i])]
#   print(head(sentiment_i_scores))
#   print(labels[i])
#   #boxplot(sentiment_i_hashtags, xlab = labels[i], ylab= "# of hashtags")
#   plot(sentiment_i_hashtags, xlab = labels[i], ylab= "# of hashtags")
# }
# 
# 
# labels =  c("VNEG", "NEG", "NEU", "POS", "VPOS")
# par(mfrow=c(2,3))
# for (i in 1:5){
#   sentiment_i_retweets = df$retweets2[which(df$overall_sentiment == labels[i])]
#   sentiment_i_scores = df$compound_score[which(df$overall_sentiment == labels[i])]
#   print(head(sentiment_i_scores))
#   print(labels[i])
#   #boxplot(sentiment_i_scores, xlab = labels[i], ylab= "scores")
#   boxplot(sentiment_i_retweets, xlab = labels[i], ylab= "retweets^(1/4)")
# }
# 
