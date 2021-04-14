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
# knn needs factors to be numeric
training_set$popularity_score_ctg <- as.numeric(training_set$popularity_score_ctg)
testing_set$popularity_score_ctg <- as.numeric(testing_set$popularity_score_ctg)
#
training_set$date <- as.Date(training_set$date,tz=Sys.timezone(), format ="%Y-%m-%d") # remove H-M-Sec from date for simplicity
training_set$date2 <- as.numeric(training_set$date - as.Date(as.character("2020-12-12", format = "%Y-%m-%d")))
training_set$user_verified2 <- as.numeric(as.logical(training_set$user_verified))
#
testing_set$date <- as.Date(testing_set$date,tz=Sys.timezone(), format ="%Y-%m-%d") # remove H-M-Sec from date for simplicity
testing_set$date2 <- as.numeric(testing_set$date - as.Date(as.character("2020-12-12", format = "%Y-%m-%d")))
testing_set$user_verified2 <- as.numeric(as.logical(testing_set$user_verified))


# reduce dataframe to variables we are interested in only TODO: include user_verified
training_subset <- training_set[c('popularity_score_ctg', 'compound_score', 'hashtags_count' , 'user_verified2')]
testing_subset <- testing_set[c('popularity_score_ctg', 'compound_score', 'hashtags_count', 'user_verified2')]
training_subset_n <- as.data.frame(training_subset[,2:4])
testing_subset_n <- as.data.frame(testing_subset[,2:4])
training_subset_labels <- training_subset[,1:1]
testing_subset_labels <- testing_subset[,1:1]

table(training_set$hashtags_count)
plot(training_set$popularity_score)
hist(training_set$compound_score)
hist(training_set$hashtags_count) 

# KNN 
# https://towardsdatascience.com/k-nearest-neighbors-algorithm-with-examples-in-r-simply-explained-knn-1f2c88da405c
# https://www.edureka.co/blog/knn-algorithm-in-r/#:~:text=KNN%20which%20stand%20for%20K,algorithm%20with%20a%20simple%20example.
library(class)

set.seed(420)
k_val <- sqrt(nrow(training_set))
k_val_lwr <- floor(k_val)
k_val_uppr <- ceiling(k_val)

knn_lwr <- knn(train = training_subset_n, test= testing_subset_n, cl=training_subset_labels, k = k_val_lwr, prob = TRUE)
knn_uppr <- knn(train = training_subset_n, test= testing_subset_n, cl=training_subset_labels, k = k_val_uppr, prob = TRUE)

# get accuracy
ACC.lwr <- 100 * sum(testing_subset_labels == knn_lwr)/NROW(testing_subset_labels) # 48.406
ACC.uppr <- 100 * sum(testing_subset_labels == knn_uppr)/NROW(testing_subset_labels) # 48.642
ACC.lwr
# get tables
table(testing_subset_labels, knn_lwr)
table(knn_uppr, testing_subset_labels)

sum(testing_subset_labels== knn_lwr)/847


entry1 <- head(training_set[training_set$popularity_score_ctg==3,],1)
entry1$text
entry1 <- training_set[training_set$popularity_score > 866,]
entry1$text

max(training_set$popularity_score)

