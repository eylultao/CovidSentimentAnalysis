# CovidSentimentAnalysis
sentiment analysis for covid vaccination tweets, more specifically for Pfizer vaccine


# Data Source
https://www.kaggle.com/gpreda/pfizer-vaccine-tweets

# Steps Taken

### analysis01.py
Creating the Sentiment Score using VaderSentiment Library

### analysis02.R
Creating new columns, basic transformations on variables such as: retweets, date, compound sentiment score 

### analysis03.R
Basic visualizations for our variables, exploring spearman rank correlation between explanatory & response variables.


# TODOS
### analysis04.R
Creating the new response variable, "popularity score" (might move this to analysis02)
Popularity score is intended to be a mix using number of retweets as well as number of favorites

### analysis05.R
Classification models for predicting the popularity of a tweet 

### analysis06.py
This part can also be moved up to analysis01
Applying other NLP techniques to extract as much information we can from tweet text and hashtags used. 
Possible Techniques to use: n-grams, LSTM(if time permits)

### analysis07.R
Conclusion, final prediction results, final diagnostics 
