import snscrape.modules.twitter as sntwitter
from snscrape.modules.reddit import RedditSearchScraper
from snscrape.modules.telegram import TelegramChannelScraper
import pandas as pd
from tabulate import tabulate
import json

query = "ndp alberta"
tweets = []
limit = 100


scraper = RedditSearchScraper(query)
for i, item in enumerate(scraper.get_items()):
    if i > limit:
        break

    try:
        print(item.json())
        print('-----------------')
    except:
        pass
