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
df = pandas.read_csv('vaccination_tweets-apr06.csv')

# preprocessing tweet texts
df.text = df.text.apply(lambda x:re.sub('@[^\s]+','',x))    # remove handles
df.text = df.text.apply(lambda x:re.sub(r'\B#\S+','',x))    # remove hashtags from tweet text
df.text = df.text.apply(lambda x:re.sub(r"http\S+", "", x)) # remove URL links from tweet text
df.text = df.text.apply(lambda x:re.sub(r'\s+', ' ', x, flags=re.I)) # remove white space
# changes the type of hashtags column from one huge string to a list
df = df.assign(hashtags2=df.hashtags.str.strip('[]').str.split(', '))
df = df.assign(hashtags_count=get_row_length(df.hashtags2))


# STEP 1: Create polarity scores for tweets
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


df = df.assign(compound_score= get_polarity_score(df.text, "compound"))
df = df.assign(positive_score= get_polarity_score(df.text, "pos"))
df = df.assign(negative_score= get_polarity_score(df.text, "neg"))
df = df.assign(neutral_score= get_polarity_score(df.text, "neu"))

df.to_csv("updated_dataframe-apr06.csv")


