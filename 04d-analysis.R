library(mlbench)
library(VGAM)
library(rpart) 
library(rpart.plot) 
library(randomForest)
library(mlbench)
library(VGAM)
library(MASS)
library(forcats)

getwd()
setwd("/Users/eylulaygun/Desktop/Year\ 5/stat\ 447B/CovidSentimentAnalysis")

# read dataframe and perform basic transformations
df <- read.csv("02-updated_dataframe-apr06.csv")
training_set <- read.csv("training_set.csv")
testing_set <- read.csv("testing_set.csv")

#cor.test(df$favorites, df$retweets, method = "spearman")

# fix the order of factoring for popularity score 
training_set$popularity_score_ctg <- as.factor(training_set$popularity_score_ctg)
testing_set$popularity_score_ctg <- as.factor(testing_set$popularity_score_ctg)
training_set$popularity_score_ctg <- fct_infreq(training_set$popularity_score_ctg)
testing_set$popularity_score_ctg <- fct_infreq(testing_set$popularity_score_ctg)

# Calculate a more strict misclassification rate given data and predictions
# uses "point prediction" 
get_misclass_rate_strict <- function(true_data, pred_data){
  return (round(((1 - sum(true_data == pred_data)/length(true_data))*100), 3))
}

get_misclass_rate_flex <- function(true_data, pred_data){
  n <- length(true_data)
  count = 0 
  for (i in 1:n){
    if (grepl(true_data[i], pred_data[i], fixed = TRUE )){
      count = count + 1
    }
  }
  return ((1 - count/n)*100)
}

category_pred_interval = function(ProbMatrix,labels)
{ ncases=nrow(ProbMatrix)
pred50=rep(NA,ncases); pred80=rep(NA,ncases)
for(i in 1:ncases)
{ p=ProbMatrix[i,]
ip=order(p)
pOrdered=p[ip] # increasing order
labelsOrdered=labels[rev(ip)] # decreasing order
G=rev(cumsum(c(0,pOrdered))) # cumulative sum from smallest
k1=min(which(G<=0.5))-1  # 1-level1= 1-0.5=0.5
k2=min(which(G<=0.2))-1  # 1-level2= 1-0.8=0.2
pred1=labelsOrdered[1:k1]; pred2=labelsOrdered[1:k2]
pred50[i]=paste(pred1,collapse="")
pred80[i]=paste(pred2,collapse="")
}
list(pred50=pred50, pred80=pred80)
}

#' @description Coverage rate of prediction intervals for a categorical response
#' @param Table table with class labels as row names, subsets as column names
#' @return list with average length, #misses, miss rate, coverage rate by class
coverage=function(Table)
{ nclass=nrow(Table); nsubset=ncol(Table); rowFreq=rowSums(Table)
labels=rownames(Table); subsetLabels=colnames(Table)
cover=rep(0,nclass); avgLen=rep(0,nclass)
for(irow in 1:nclass)
{ for(icol in 1:nsubset)
{ intervalSize = nchar(subsetLabels[icol])
isCovered = grepl(labels[irow], subsetLabels[icol])
frequency = Table[irow,icol]
cover[irow] = cover[irow] + frequency*isCovered
avgLen[irow] = avgLen[irow] + frequency*intervalSize
}
}
miss = rowFreq-cover; avgLen = avgLen/rowFreq
out=list(avgLen=avgLen,miss=miss,missRate=miss/rowFreq,coverRate=cover/rowFreq)
return(out)
}


#### TREE
library(rpart) 
library(rpart.plot) 
ctree <- rpart(popularity_score_ctg ~ compound_score + user_verified + hashtags_count , data=training_set)   

#ctree <- rpart(popularity_score_ctg ~ user_followers+ user_friends  + compound_score + hashtags_count, data=training_set)   
par(mfrow=c(1,1))
rpart.plot(ctree, box.palette = "blue") 
rpart.plot(ctree) 
tree_out_pred =predict(ctree,newdata=testing_set)
tree_max_prob = apply(tree_out_pred,1,max)
tree_pred_interval=category_pred_interval(tree_out_pred,labels=c("LOW", "AVG", "HIGH"))
table(training_set$popularity_score_ctg)

print("Predictions for 50% : ")
print(table(testing_set$popularity_score_ctg,tree_pred_interval$pred50))
print("Predictions for 80% : ")
print(table(testing_set$popularity_score_ctg,tree_pred_interval$pred80))
print("Misclass rate for 50% : " )
print(get_misclass_rate_flex(testing_set$popularity_score_ctg, tree_pred_interval$pred50))
print("Misclass rate for 80% : " )
print(get_misclass_rate_flex(testing_set$popularity_score_ctg, tree_pred_interval$pred80))
######

### RF
rf = randomForest(popularity_score_ctg ~ compound_score + user_verified + hashtags_count ,data=training_set, importance=TRUE, proximity=TRUE)
rf_out_pred=predict(rf,type="prob",newdata=testing_set)
rf_max_prob=apply(rf_out_pred,1,max)
rf_pred_interval=category_pred_interval(rf_out_pred,labels=c("LOW", "AVG", "HIGH"))

print("Importance: ")
print(rf$importance)

print("Predictions for 50% : ")
print(table(testing_set$popularity_score_ctg,rf_pred_interval$pred50))
print("Predictions for 80% : ")
print(table(holdout_set$lettr,rf_pred_interval$pred80))
print("Misclass rate for 50% : " )
print(get_misclass_rate_flex(testing_set$popularity_score_ctg, rf_pred_interval$pred50))
print("Misclass rate for 80% : " )
print(get_misclass_rate_strict(holdout_set$lettr, rf_pred_interval$pred80))
