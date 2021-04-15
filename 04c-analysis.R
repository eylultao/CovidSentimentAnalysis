getwd()
setwd("/Users/eylulaygun/Desktop/Year\ 5/stat\ 447B/CovidSentimentAnalysis")

library(forcats)
library(class)

# read dataframe 
df <- read.csv("02-updated_dataframe-apr06.csv")
training_set <- read.csv("training_set.csv")
testing_set <- read.csv("testing_set.csv")

PrepareDataForKNN<-function(data){
  # fix the order of factoring for popularity score 
  data$popularity_score_ctg <- as.factor(data$popularity_score_ctg)
  data$popularity_score_ctg <- fct_infreq(data$popularity_score_ctg)
  # knn needs all factors to be numeric
  data$popularity_score_ctg <- as.numeric(data$popularity_score_ctg)
  data$user_verified <- as.numeric(as.logical(data$user_verified))
  # reduce dataframe to variables we are interested in only 
  data <- data[c('popularity_score_ctg', 'compound_score', 'hashtags_count' , 'user_verified', "tweet_age")]
  return(data)
}

training_subset <- PrepareDataForKNN(training_set)
testing_subset <- PrepareDataForKNN(testing_set)

training_subset_n <- as.data.frame(training_subset[,2:5])
testing_subset_n <- as.data.frame(testing_subset[,2:5])
training_subset_labels <- training_subset[,1:1]
testing_subset_labels <- testing_subset[,1:1]


# KNN 
# https://towardsdatascience.com/k-nearest-neighbors-algorithm-with-examples-in-r-simply-explained-knn-1f2c88da405c
# https://www.edureka.co/blog/knn-algorithm-in-r/#:~:text=KNN%20which%20stand%20for%20K,algorithm%20with%20a%20simple%20example.
set.seed(420)

k_val <- sqrt(nrow(training_set))
k_val_lwr <- floor(k_val)
k_val_uppr <- ceiling(k_val)

knn_lwr <- knn(train = training_subset_n, test= testing_subset_n, cl=training_subset_labels, k = k_val_lwr, prob = TRUE)
knn_uppr <- knn(train = training_subset_n, test= testing_subset_n, cl=training_subset_labels, k = k_val_uppr, prob = TRUE)

# get coverage rates
coverage.lwr <- 100 * sum(testing_subset_labels == knn_lwr)/NROW(testing_subset_labels) # 48.406
coverage.uppr <- 100 * sum(testing_subset_labels == knn_uppr)/NROW(testing_subset_labels) # 48.642
# we have better accuracy with the lwr k value = 42

# get tables
table(testing_subset_labels, knn_lwr)
table(testing_subset_labels, knn_uppr)
# We can see that no predictions were made for HIGH popularity.


