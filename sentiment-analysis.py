import pandas
import matplotlib.pyplot as plt
import re

"""
Takes in a column, iterates over all the rows inside that column,
and appends them into a 1D list, which is returned in the end

Useful for: creating frequency dictionaries for our dataframe 

:param col_in: a column of dataframe we want to be transformed
:type col_in: Pandas Series

:returns: a list of all the content in col_in
:rtype: List
"""
def fix_to_list(col_in):
    list_out = list()
    # iterate over every single row
    for i, val in enumerate(col_in):
        if (isinstance(val, float)):
            # print("this tweet has no hashtags")
            pass
        else:
            # for each row, iterate inside the array of values
            for j, h in enumerate(val):
                list_out.append(h)
    return list_out

"""
:param data_in: the list we want to make a frequency dictionary out of
:type data: List 

:returns: a frequency dictionary where (key, val) = (content, count)
:rtype: Dictionary 
"""
def create_frequency_dict(data_in):
    # create dictionary to keep track of hashtags
    freq_out = {}
    for h in data_in:
        freq_out[h] = data_in.count(h)
    return freq_out


def print_popular_tweets(data_dic, treshold):
    for key, value in data_dic.items():
        if value > treshold:
            print (key, value)

"""
Creates a pie plot for all the values with key > treshold 

:param frequency_dict: dictionary we want to visualize
:type frequency_dict: Dictionary

:param treshold: treshold for count we want to filter with
:type treshold: int

:param plot_name: name we want to save our plot figure with, needs to end with .png
:type plot_name: String

:returns: None
"""
def create_frequency_plots(frequency_dict, treshold, plot_name):
    filtered_dict = dict((k, v) for k, v in frequency_dict.items() if v > treshold)
    plt.pie(filtered_dict.values(), labels = filtered_dict.keys())
    # plt.show()
    plt.savefig(plot_name)


def get_row_length(col_in):
    list_out = list()
    # iterate over every single row
    for i, val in enumerate(col_in):
        if (isinstance(val, float)):
            list_out.append(0)
            # print("this tweet has no hashtags")
            pass
        else:
            list_out.append(len(val))
    return list_out


# STEP 0: cleanup

# read the raw dataset from Kaggle
#df = pandas.read_csv('vaccination_tweets.csv')

df = pandas.read_csv('vaccination_tweets_transformed.csv')

# preprocessing
df.text = df.text.apply(lambda x:re.sub(r'\B#\S+','',x)) # remove hashtags from tweet text
df.text = df.text.apply(lambda x:re.sub(r"http\S+", "", x)) # remove URL links from tweet text

# changes the type of hashtags column from one huge string to a list
df_out = df.assign(hashtags2=df.hashtags.str.strip('[]').str.split(', '))
df_out = df.assign(hashtags_count=get_row_length(df_out.hashtags2))


# STEP 1: and explore possible relationships between columns


# hashtags_list = fix_to_list(df_out.hashtags)  # makes a list out of all the hashtags in dataframe
# hashtags_dict = create_frequency_dict(hashtags_list) # a frequency dictionary for all the hashtags and their counts
# # visualize most used hashtags in the dataset
# create_frequency_plots(hashtags_dict, 50, "common_hashtags50_pieplt.png")

# # TODO: count similar hashtags together (eg. CovidVaccine and covidvaccine can be joined )
# hashtags_list_all_lower = list(map(str.lower, hashtags_list))
# hashtags_dict_all_lower = create_frequency_dict(hashtags_list_all_lower) # a frequency dictionary for all the hashtags and their counts
# create_frequency_plots(hashtags_dict_all_lower, 50, "all_lower_hashtags50_pieplt.png")
# # print(hashtags_dict_all_lower)


# STEP 2: Create polarity scores for tweets

# USING VADER SENTIMENT ANALYSIS
# https://github.com/cjhutto/vaderSentiment#code-examples
import vaderSentiment
from vaderSentiment.vaderSentiment import SentimentIntensityAnalyzer

def get_polarity_score(sentences, key):
    analyzer = SentimentIntensityAnalyzer()
    # scores is a list of dictionary: (in dictionary: keys= neg,neu,pos,compound and val= attributed polarity score for each tweet)
    scores = []
    for sentence in sentences:
        scores.append(analyzer.polarity_scores(sentence))
        #print("{:-<65} {}".format(sentence, str(vs)))
    scores_key = []
    for tweet in scores:
        scores_key.append(tweet.get(key))
    return scores_key


df_out = df_out.assign(compound_score= get_polarity_score(df_out.text, "compound"))

#df_high_engagement = df_high_engagement.assign(pos_score= get_polarity_score(df_high_engagement.text, "compound"))
# df_no_zero_score = df_high_engagement[df_high_engagement.favorites > 3]
# df_no_zero_score = df_no_zero_score[df_no_zero_score.retweets > 3]

# print(df_high_engagement.compound_score)

# pandas.set_option('display.max_colwidth', None)
# print(df_high_engagement[df_high_engagement.compound_score > 0.6].text)
# print(df_high_engagement[df_high_engagement.compound_score < -0.5].text)

# plt.scatter(df_no_zero_score.retweets, df_no_zero_score.compound_score)
# plt.scatter(df_no_zero_score.favorites, df_no_zero_score.compound_score)
# plt.show()

#
df_out.to_csv("updated_dataframe-mar30.csv")



########
# TOKENIZING TWEETS
# print(df.text[0])

# clean_tokens = df.text[:]
# tokens = df.text[:]
# sr = ['i', 'me', 'my', 'myself', 'we', 'our', 'ours', 'ourselves', 'you', "you're", "you've", "you'll", "you'd", 'your', 'yours', 'yourself', 'yourselves', 'he', 'him', 'his', 'himself', 'she', "she's", 'her', 'hers', 'herself', 'it', "it's", 'its', 'itself', 'they', 'them', 'their', 'theirs', 'themselves', 'what', 'which', 'who', 'whom', 'this', 'that', "that'll", 'these', 'those', 'am', 'is', 'are', 'was', 'were', 'be', 'been', 'being', 'have', 'has', 'had', 'having', 'do', 'does', 'did', 'doing', 'a', 'an', 'the', 'and', 'but', 'if', 'or', 'because', 'as', 'until', 'while', 'of', 'at', 'by', 'for', 'with', 'about', 'against', 'between', 'into', 'through', 'during', 'before', 'after', 'above', 'below', 'to', 'from', 'up', 'down', 'in', 'out', 'on', 'off', 'over', 'under', 'again', 'further', 'then', 'once', 'here', 'there', 'when', 'where', 'why', 'how', 'all', 'any', 'both', 'each', 'few', 'more', 'most', 'other', 'some', 'such', 'no', 'nor', 'not', 'only', 'own', 'same', 'so', 'than', 'too', 'very', 's', 't', 'can', 'will', 'just', 'don', "don't", 'should', "should've", 'now', 'd', 'll', 'm', 'o', 're', 've', 'y', 'ain', 'aren', "aren't", 'couldn', "couldn't", 'didn', "didn't", 'doesn', "doesn't", 'hadn', "hadn't", 'hasn', "hasn't", 'haven', "haven't", 'isn', "isn't", 'ma', 'mightn', "mightn't", 'mustn', "mustn't", 'needn', "needn't", 'shan', "shan't", 'shouldn', "shouldn't", 'wasn', "wasn't", 'weren', "weren't", 'won', "won't", 'wouldn', "wouldn't"]
# for token in tokens:
#     if token in sr:
#         clean_tokens.remove(token)
#
# # print(clean_tokens[1])
# print(clean_tokens.shape)
#
# freq = nltk.FreqDist(clean_tokens)
# for key,val in freq.items():
#     print(str(key) + ':' + str(val))
# freq.plot(20, cumulative=False)
######

# understanding what kind of tweets got biggest engagement
#
# print(df.columns)
# print(df.describe())


# print(df[df.retweets > 10])
# df_high_engagement = df[df.retweets > 20]
# print(df_high_engagement.describe())
# print(df_high_engagement.size)
#
# plt.scatter(df_high_engagement.retweets, df_high_engagement.user_followers)
# plt.show()
# pandas.set_option('display.max_colwidth', None)
# print(df_high_engagement[df_high_engagement.favorites > 1500].text)
####
