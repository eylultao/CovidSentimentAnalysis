getwd()
setwd("/Users/eylulaygun/Desktop/Year\ 5/stat\ 447B/CovidSentimentAnalysis")

df <- read.csv("01b-updated_dataframe-apr06.csv")

#' Removes entries we want to undersample
#'
#'@param data entire dataset
#'@param column dataset column we want to undersample by
#'@param undersample_filter value we want to undersample, type must match column type
#'@param n number of entries we want to remove, (must be less than dataset row size)
#'
#'@returns entire dataset with entries removed
#'
#'@example  To remove 10 rows from dataset that have value "FOO" in their column named "BOO"
#'         we would use PerformUndersample(data, data$BOO, "FOO", 10)
PerformUndersample <-function(data, column, undersample_filter, n){
  all_undersample_indices <- which(column == undersample_filter)
  sample_to_drop <- sample(all_undersample_indices, size = n)
  return (data[-sample_to_drop,])
}

#' Creates 2 subsets using dataset and specified size
#' 
#' @param data entire dataset
#' @param subset1_size int, size for the first subset
#' 
#' @returns list with 2 subsets, named subset1 and subset2 
#' 
CreateSubsets <-function(data, subset1_size){
  n <- dim(data)[1] #number of rows
  subset2_size = n - subset1_size
  subset1_indices <- sample(0:n, size = subset1_size, replace = FALSE)
  subset1 <- data[subset1_indices,]
  subset2 <- data[-subset1_indices,]
  return (list(subset1 = subset1, subset2 = subset2))
}

#' Moves entries from same users from subset2 to subset1 
#' 
#' @param subsets List with 2 subsets, named subset1 and subset2 
#' 
#' @returns List with 2 subsets, named subset1 and subset2
#' 
#' @example If data has 3 entries by user John Doe, and they are not already all in the same subset
#'          this function will move all entries by John Doe into subset1.
#'          If all of John Doe's entries are entirely in subset1 or subset2, it will remain the same
MoveDuplicateUsers <- function(subsets){
  duplicate_user_indices <- which(subsets$subset2$user_name %in% subsets$subset1$user_name)
  entries_to_move <- subsets$subset2[duplicate_user_indices,]
  subset2 <- subsets$subset2[-duplicate_user_indices,]
  print(subset2)
  print(dim(duplicate_user_indices))
  subset1 <- rbind(subsets$subset1, entries_to_move)
  return (list(subset1 = subset1, subset2 = subset2))
}


set.seed(420)
df <- PerformUndersample(df, df$popularity_score_ctg, "LOW", n=4000) # remove 2500 of entries with low popularity score for improving sample distribution
df <- PerformUndersample(df, df$popularity_score_ctg, "AVG", n=1000) # remove 1000 of entries with avg popularity score for improving sample distribution
table(df$popularity_score_ctg) # check new distribution
subsets <- CreateSubsets(df, subset1_size = 1500) 
subsets_final <- MoveDuplicateUsers(subsets)

which(subsets_final$subset1$user_name %in% subsets_final$subset2$user_name) # should output 0 if there are no duplicate users 

# save new csv 
write.csv(df, "02-updated_dataframe-apr06.csv")
write.csv(subsets_final$subset2, "testing_set.csv")
write.csv(subsets_final$subset1, "training_set.csv")

