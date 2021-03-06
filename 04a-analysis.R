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

# fix the order of factoring for popularity score 
# I am repeatedly doing this each time i read csv as it doesn't conserve factor as type, nor the ordering
training_set$popularity_score_ctg <- as.factor(training_set$popularity_score_ctg)
testing_set$popularity_score_ctg <- as.factor(testing_set$popularity_score_ctg)
training_set$popularity_score_ctg <- fct_infreq(training_set$popularity_score_ctg)
testing_set$popularity_score_ctg <- fct_infreq(testing_set$popularity_score_ctg)

#' Using the function provided in class, did not change the name as a result
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

#' Using the function provided in class, did not change the name as a result
#'  @description Coverage rate of prediction intervals for a categorical response
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

###############

# Finalized model for multinomial logit, tweet_age ended up being unuseful.
multilogit = vglm(popularity_score_ctg~ compound_score + hashtags_count + user_verified, multinomial(refLevel = 1), data = training_set)
print("Model Summary: ")
print(summary(multilogit))

multilogit_out_pred = predict(multilogit, type="response", newdata= testing_set)
multilogit_pred_interval = category_pred_interval(multilogit_out_pred,labels=c("LOW", "AVG", "HIGH"))

multilogit_table50 <- table(testing_set$popularity_score_ctg,multilogit_pred_interval$pred50)

multilogit_cov <- coverage(multilogit_table50)
print("Coverage and Accuracy Results : ")
print(multilogit_cov)
print("Confusion Matrix at 50% Interval: ")
print(multilogit_table50)
print("Final Coverage Rate")
multilogit_final_coverage <- sum(multilogit_cov$coverRate * c(403/847, 338/847, 106/847))
print(multilogit_final_coverage)


save(multilogit, file = "multilogit-model.RData")
save(multilogit_table50, file = "multilogit-confusion-matrix.RData")

