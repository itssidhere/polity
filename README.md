# Backend can be found in the [backend]/polity.py directory.

# The backend is a python script that uses the [flask] framework to serve the [frontend] to the user. The backend also handles the [database] and the [API] calls.

# The frontend is a [flutter] app that is served by the backend. The frontend is a web app that is served to the user.

# Steps to run the backend:
> cd backend </br>
> python3 -m venv venv </br>
> source venv/bin/activate </br>
> pip install -r requirements.txt </br>
> python polity.py </br>

# Steps to run the frontend:
> cd to the root directory of the project </br>
> flutter run

# Steps to request data from the API:
> 1) Right now the API is not hosted anywhere, so you will have to run the backend locally and then make the API calls to localhost:5000</br>
> 2) To get the list of tweets for a given query along with the sentiment analysis, make a GET request to localhost:5000/twitter?query=<query>&limit=n where <query> is the query you want to search for and n is the number of tweets you want to get (default is 10). </br>
> 3) The response you will be getting will be in the form of list of JSON objects. </br>
> 4) Each JSON object will have the following fields: </br>
     tweet: The tweet text </br>
     sentiment: The sentiment of the tweet </br>
     uid: The unique id of the twitter user </br>
     date: The date of the tweet </br>


