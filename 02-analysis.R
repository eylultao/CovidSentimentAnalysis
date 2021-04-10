getwd()
setwd("/Users/eylulaygun/Desktop/Year\ 5/stat\ 447B/CovidSentimentAnalysis")


df <- read.csv("01b-updated_dataframe-apr06.csv")

# undersampling LOW popularity as they make majority of data
plot(df$popularity_score_ctg)
low_popularity_indices <- which(df$popularity_score_ctg == "LOW")
low_popularity_sample <- sample(low_popularity_indices, size = 2500)
df <- df[-low_popularity_sample,] # dropping half of low popularity data
plot(df$popularity_score_ctg) # checking new distribution

# Split data into training and testing sets
n <- dim(df)[1]
training_set_size = 2500 # initial size, will increase later due to moving duplicate users
testing_set_size = n - training_set_size
set.seed(420)
indices <- sample(0:n, size = training_set_size, replace = FALSE)
training_set <- df[indices, ]
testing_set <- df[-indices,]

# ensure no user has tweets in both training set and testing set 
duplicate_user_indices = which(testing_set$user_name %in% training_set$user_name)
tweets_to_move = testing_set[duplicate_user_indices,]
testing_set = testing_set[-duplicate_user_indices,]
training_set = rbind(training_set, tweets_to_move)
# ensure no more duplicates
which(testing_set$user_name %in% training_set$user_name) # should output 0 


# save new csv 
write.csv(df, "02-updated_dataframe-apr06.csv")
write.csv(testing_set, "testing_set.csv")
write.csv(training_set, "training_set.csv")

