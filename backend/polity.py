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
from flask.globals import request
app = Flask(__name__)
api = Api(app)


def remove_noise(tweet_tokens, stop_words=()):
    nltk.download('omw-1.4')
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
    f = open('my_classifier.pickle', 'rb')
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


api.add_resource(Users, '/users')
api.add_resource(Prediction, '/prediction')

if __name__ == '__main__':
    app.run(debug=True)
