import numpy as np
import pandas
import matplotlib.pyplot as plt

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
        # if (i > 5): break # TEMP CODE: dont want to iterate over 5k rows rn
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
d = dict((k, v) for k, v in hashtags_dic.items() if v > 50)
plt.pie(d.values(), labels = d.keys())
# plt.show()
plt.savefig("common_hashtags_pieplt.png")
