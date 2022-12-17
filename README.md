# Backend can be found in the [backend]/polity.py directory.

# The backend is a python script that uses the [flask] framework to serve the [frontend] to the user. The backend also handles the [database] and the [API] calls.

# The frontend is a [flutter] app that is served by the backend. The frontend is a web app that is served to the user.

# Steps to run the backend:
> cd backend
> python3 -m venv venv
> source venv/bin/activate
> pip install -r requirements.txt
> python polity.py

# Steps to run the frontend:
> cd to the root directory of the project
> flutter run

# Steps to request data from the API:
> Right now the API is not hosted anywhere, so you will have to run the backend locally and then make the API calls to localhost:5000</br>
> To get the list of tweets for a given query along with the sentiment analysis, make a GET request to localhost:5000/twitter?query=<query> where <query> is the query you want to search for. </br>
> The response you will be getting will be in the form of list of JSON objects. </br>
> Each JSON object will have the following fields:
    > tweet: The tweet text
    > sentiment: The sentiment of the tweet
    > uid: The unique id of the twitter user
    > date: The date of the tweet


