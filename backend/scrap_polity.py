import snscrape.modules.twitter as sntwitter
import pandas as pd
from tabulate import tabulate

query = "ucp party alberta since:2020-01-01 until:2022-12-31"
tweets = []
limit = 100


for tweet in sntwitter.TwitterSearchScraper(query).get_items():
    if len(tweets) == limit:
        break

    elif tweet.coordinates is not None:
        tweets.append([tweet.date, tweet.username,
                      tweet.content, tweet.coordinates])

df = pd.DataFrame(tweets, columns=['Date', 'User', 'Content', 'Coordinates'])
df.to_csv('ucp_filtered.csv', index=False)
