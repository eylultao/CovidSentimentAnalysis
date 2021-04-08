getwd()
setwd("/Users/eylulaygun/Desktop/Year\ 5/stat\ 447B/CovidSentimentAnalysis")


# read dataframe and perform basic transformations
df <- read.csv("updated_dataframe-apr06.csv")

df$retweets2 <- (0.5+ df$retweets)^(1/4)
df$compound_score2 <- as.factor(df$compound_score)
df$date <- as.POSIXct(df$date,tz=Sys.timezone(), format ="%Y-%m-%d") # remove H-M-OS part from date
# new column, turn compound score to ordinal categorical 
df$overall_sentiment <- cut(df$compound_score, breaks = c(-1, -0.5, -0.2, 0.2, 0.5, 1), labels =  c("VNEG", "NEG", "NEU", "POS", "VPOS"))

# Split data into training and testing sets
n <- dim(df)[1]
training_set_size = 3000 # initial size, will increase later due to moving duplicate users
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
write.csv(df, "updated_dataframe-apr06-2.csv")
write.csv(testing_set, "testing_set.csv")
write.csv(training_set, "training_set.csv")
