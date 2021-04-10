# CovidSentimentAnalysis
sentiment analysis for covid vaccination tweets, more specifically for Pfizer vaccine


# Data Source
https://www.kaggle.com/gpreda/pfizer-vaccine-tweets

# Steps Taken

### 01a-analysis.py
Preprocess tweet text
Obtains Compound (Sentiment) Score using VaderSentiment Library
Creates new column: hashtag_count
TODO(if time permits): Applying other NLP techniques to extract as much information we can from tweet text and hashtags used. Possible Techniques to use: n-grams, LSTM

### 01b-analysis.R
Creates response variable: Popularity Score
Reformats date
Transforms compound score to categorical

### 02-analysis.R
Undersample data with LOW popularity score
Creates training & testing gets
Ensures no duplicate users in both sets

### 03-analysis.R
Basic visualizations for our variables, exploring spearman rank correlation between explanatory & response variables.

### 04-analysis.R
Initial models for classification, comparisons between predictive powers

# TODOS
### 05-analysis.R
Conclusion, final model, prediction results, diagnostics 
