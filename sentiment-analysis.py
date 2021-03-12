import pandas
import matplotlib.pyplot as plt
import nltk
# from nltk.corpus import stopwords

df = pandas.read_csv('vaccination_tweets.csv')
# print(df.head(1))
# print(df.columns)
# print(df.dtypes)
# print(df['text'])
# print(df['hashtags'])
# print(df.hashtags)

def fix_to_list(df_in):
    list_out = list()
    for i, val in enumerate(df_in):
        if (isinstance(val, float)):
            # print("this tweet has no hashtags")
            pass
        else:
            for j, h in enumerate(val):
                # print(i," , " ,j, " : ", h)
                list_out.append(h)
    return list_out

def create_frequency_dict(data):
    # create dictionary to keep track of hashtags
    freq = {}
    for h in data:
        freq[h] = data.count(h)
    return freq


df_out = df.assign(hashtags=df.hashtags.str.strip('[]').str.split(', '))
hashtags_list = fix_to_list(df_out.hashtags)
hashtags_dic = create_frequency_dict(hashtags_list)

# for key, value in hashtags_dic.items():
#     if value > 20:
#         print (key, value)

# visualize most use hashtags in the dataset
# TODO: count similar hashtags together (eg. CovidVaccine and CovidVaxx can be joined )
# d = dict((k, v) for k, v in hashtags_dic.items() if v > 50)
# plt.pie(d.values(), labels = d.keys())
# # plt.show()
# plt.savefig("common_hashtags_pieplt.png")

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

print(df.columns)
print(df.describe())


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
# and furthermore, whether bigger engagement implies more sentiment

# USING VADER SENTIMENT ANALYSIS
# https://github.com/cjhutto/vaderSentiment#code-examples

import vaderSentiment
from vaderSentiment.vaderSentiment import SentimentIntensityAnalyzer

df_high_engagement = df#[df.retweets > 10]
# sentences = df_high_engagement.text
# analyzer = SentimentIntensityAnalyzer()


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


df_high_engagement = df_high_engagement.assign(compound_score= get_polarity_score(df_high_engagement.text, "compound"))
#df_high_engagement = df_high_engagement.assign(pos_score= get_polarity_score(df_high_engagement.text, "compound"))
df_no_zero_score = df_high_engagement[df_high_engagement.favorites > 3]
# df_no_zero_score = df_no_zero_score[df_no_zero_score.retweets > 3]

# print(df_high_engagement.compound_score)

# pandas.set_option('display.max_colwidth', None)
# print(df_high_engagement[df_high_engagement.compound_score > 0.6].text)
# print(df_high_engagement[df_high_engagement.compound_score < -0.5].text)

# plt.scatter(df_no_zero_score.retweets, df_no_zero_score.compound_score)
plt.scatter(df_no_zero_score.favorites, df_no_zero_score.compound_score)
plt.show()


df_high_engagement.to_csv("updated_dataframe.csv")
