from flask import Flask, jsonify
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

import datetime
import snscrape.modules.twitter as sntwitter


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
    f = open(
        'C://Users//siddharth//projects//polity//backend//my_classifier.pickle', 'rb')
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
        parser = reqparse.RequestParser()
        parser.add_argument('query', required=True)

        args = parser.parse_args()

        tweets = []
        limit = args['limit'] if 'limit' in args else 10
        for tweet in sntwitter.TwitterSearchScraper(args['query']).get_items():
            if len(tweets) == limit:
                break
            else:
                data = {'tweet': tweet.content,
                        'date': datetime.datetime.strftime(
                            tweet.date, '%Y-%m-%d %H:%M:%S'), 'uid': tweet.user.username, 'sentiment': predict(tweet.content)}
                tweets.append(data)

        return {'tweets': tweets}


api.add_resource(Users, '/users')
api.add_resource(Prediction, '/prediction')
api.add_resource(Twitter, '/twitter')

if __name__ == '__main__':
    app.run(debug=False)
