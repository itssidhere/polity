from flask import Flask, jsonify, request
from flask_restful import Resource, Api, reqparse
import pandas as pd
import numpy as np
import ast
import pickle
import re
import string
import nltk
from nltk.tag import pos_tag
from nltk.stem.wordnet import WordNetLemmatizer
from nltk.tokenize import word_tokenize
import os

import datetime
import snscrape.modules.twitter as sntwitter
from snscrape.modules.reddit import RedditSearchScraper


app = Flask(__name__)
api = Api(app)


def remove_noise(tweet_tokens, stop_words=()):
    cleaned_tokens = []

    for token, tag in pos_tag(tweet_tokens):
        token = re.sub('http[s]?://(?:[a-zA-Z]|[0-9]|[$-_@.&+#]|[!*\(\),]|'
                       '(?:%[0-9a-fA-F][0-9a-fA-F]))+', '', token)
        token = re.sub("(@[A-Za-z0-9_]+)", "", token)

        if tag.startswith("NN"):
            pos = 'n'
        elif tag.startswith('VB'):
            pos = 'v'
        else:
            pos = 'a'

        lemmatizer = WordNetLemmatizer()
        token = lemmatizer.lemmatize(token, pos)

        if len(token) > 0 and token not in string.punctuation and token.lower() not in stop_words:
            cleaned_tokens.append(token.lower())
    return cleaned_tokens


def predict(tweet):
    dir = os.path.dirname(__file__)
    filename = os.path.join(dir, 'my_classifier.pickle')
    f = open(
        filename, 'rb')
    classifier = pickle.load(f)
    custom_tokens = remove_noise(word_tokenize(tweet))
    result = classifier.prob_classify(
        dict([token, True] for token in custom_tokens))
    return {'positive': result.prob('Positive'), 'negative': result.prob('Negative')}


class Users(Resource):
    def get(self):
        df = pd.read_csv('users.csv')
        df = df.to_dict()
        return df


class Prediction(Resource):
    def get(self):
        return {'message': 'Hello, Welcome to the prediction page'}

    def post(self):
        parser = reqparse.RequestParser()
        parser.add_argument('query', required=True)

        args = parser.parse_args()
        return {'prediction': predict(args['query'])}


class Twitter(Resource):
    def post(self):
        return {'message': 'Hello, Welcome to the twitter page'}

    def get(self):
        query = request.args.get('query', type=str)
        limit = request.args.get('limit', type=int)
        # parser = reqparse.RequestParser()
        # parser.add_argument('query', required=True)
        # parser.add_argument('limit', required=False, type=int)

        # args = parser.parse_args()

        tweets = []
        limit = limit if limit else 10

        for tweet in sntwitter.TwitterSearchScraper(query).get_items():
            if len(tweets) == limit:
                break
            else:
                data = {'tweet': tweet.content,
                        'date': datetime.datetime.strftime(
                            tweet.date, '%Y-%m-%d %H:%M:%S'), 'uid': tweet.user.username, 'sentiment': predict(tweet.content)}
                tweets.append(data)

        return {'tweets': tweets}


class Reddit(Resource):
    def post(self):
        return {'message': 'Hello, Welcome to the reddit page'}

    def get(self):
        query = request.args.get('query', type=str)
        limit = request.args.get('limit', type=int)
        # parser = reqparse.RequestParser()
        # parser.add_argument('query', required=True)
        # parser.add_argument('limit', required=False, type=int)

        # args = parser.parse_args()

        reddits = []
        limit = limit if limit else 10

        scrapper = RedditSearchScraper(query)

        for i, item in enumerate(scrapper.get_items()):
            if i > limit:
                break

            try:
                data = {'body': item.body,
                        'url': item.url,
                        'date': datetime.datetime.strftime(
                            item.date, '%Y-%m-%d %H:%M:%S'), 'uid': item.author, 'sentiment': predict(item.body)}
                reddits.append(data)
            except:
                pass

        return {'reddits': reddits}


api.add_resource(Users, '/users')
api.add_resource(Prediction, '/prediction')
api.add_resource(Twitter, '/twitter')
api.add_resource(Reddit, '/reddit')

if __name__ == '__main__':
    app.run(debug=False)
