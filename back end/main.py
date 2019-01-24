from flask import Flask, jsonify, request, abort
import pyrebase
import requests
import logging
import json
from google.oauth2 import id_token
from google.auth.transport import requests as google_requests
import random
from google.cloud import speech_v1
from pydub import AudioSegment
import speech_recognition as sr
import dialogflow_v2 as dialogflow
from google.protobuf.json_format import MessageToDict
import datetime
import binascii

#create flask app
app = Flask(__name__)


#initalise firebase app using config, pyrebase library will be used
firebase = pyrebase.initialize_app(config)

#client for googles speech to text api
client = speech_v1.SpeechClient()

#recognizer for speech recognition
r = sr.Recognizer()

#dialogflow session client
session_client = dialogflow.SessionsClient()

#register user route
@app.route('/register', methods=['POST'])
def register_user():
	#retreive firebase authentication
	auth = firebase.auth()

	try:
		#use posted email and password to create user account
		user = auth.create_user_with_email_and_password(request.form['email'], request.form['password'])

		db = firebase.database()

		data = {
		    "firstName": request.form['firstName'],
		    "secondName": request.form['secondName']
		}

		#upload their first name and second name to the database
		results = db.child("users").child(user['localId']).child("userDetails").set(data, user['idToken'])
		#return success message
		return jsonify(message="User Created Successfully")
	#catch exception and handle error
	except requests.exceptions.HTTPError as e:
		new = str(e).replace("\n", '')
		parsedError = json.loads(new[new.index("{"):])

		message = parsedError['error']['message']

		if message == "EMAIL_EXISTS":
			message = "A User with this Email already exists!"
		elif message == "WEAK_PASSWORD : Password should be at least 6 characters":
			message = "Password should be at least 6 characters"

		return jsonify(response=message)

#sign in user route
@app.route('/signin', methods=['POST'])
def sign_in_user():
	auth = firebase.auth()

	try:
		#sign user in with posted email and password
		user = auth.sign_in_with_email_and_password(request.form['email'], request.form['password'])

		db = firebase.database()

		#retrieve user details from database
		results = db.child("users").child(user['localId']).child("userDetails").get(user['idToken'])
		#return user data, id, token and refresh token
		return jsonify(message=results.val(), id=user['localId'], token=user['idToken'], refreshToken=user['refreshToken'])
	except requests.exceptions.HTTPError as e:
		new = str(e).replace("\n", '')

		parsedError = json.loads(new[new.index("{"):])

		message = parsedError['error']['message']

		if message == "INVALID_EMAIL":
			message = "This Email is Not Recognized!"
		elif message == "INVALID_PASSWORD":
			message = "Incorrect Password"

		return jsonify(response=message)

#route for uploading a photo
@app.route('/putFile', methods=['POST'])
def upload_file():
	auth = firebase.auth()

	try:
		#create an instance of firebase storage
		storage = firebase.storage()
		db = firebase.database()

		user = auth.refresh(request.form['refreshToken'])

		#stiore posted image under posted filename
		results = storage.child("users").child(user['userId']).child(request.form['subjectID']).child(request.files['file'].filename).put(request.files['file'], user['idToken'])
		#get url from posted image
		url = storage.child(results['name']).get_url(results['downloadTokens'])

		data = {
			"fileName": request.files['file'].filename,
		    "url": str(url)
		}

		#add the url to the database under the images node for the user, give random int as the node for now, will be changed later
		addUrl = db.child("users").child(user['userId']).child("subjects").child(request.form['subjectID']).child("files").push(data, user['idToken'])

		#return the refresh token and the image url
		return jsonify(refreshToken=user['refreshToken'], url=url, fileName=request.files['file'].filename)
	except requests.exceptions.HTTPError as e:
		new = str(e).replace("\n", '')
		parsedError = new[new.index("{"):]
		return jsonify(response=parsedError)

#route to get all user photos
@app.route('/getFiles', methods=['GET'])
def get_files():
	auth = firebase.auth()

	try:
		db = firebase.database()

		user = auth.refresh(request.args['refreshToken'])

		#get all image urls from database for the specific user
		results = db.child("users").child(user['userId']).child("subjects").child(request.args['subjectID']).child("files").get(user['idToken'])

		#return the images as a list
		return jsonify(files=results.val(), refreshToken=user['refreshToken'])
	except requests.exceptions.HTTPError as e:
		new = str(e).replace("\n", '')
		parsedError = new[new.index("{"):]
		return jsonify(response=parsedError)

#route to deal with voice command, currently only works with timetable
@app.route('/command', methods=['POST'])
def get_command_keywords():
	auth = firebase.auth()

	try:
		user = auth.refresh(request.form['refreshToken'])

		#use audio segment to get the raw audio from the posted file (which is in a .mp4 format)
		raw_audio = AudioSegment.from_file(request.files['file'])

		#use ffmpeg to convert the file to wav, which is a filetype accepted by google speech to text
		wav_path = "./sample.wav"
		raw_audio.export(wav_path, format="wav")

		#use the audio recorder to convert the new wav file as raw audio
		with sr.AudioFile(wav_path) as source:
			audio = r.record(source)


		day = ""
		funct = ""

		try:
			#use google speech to text api to retrieve the text from the audio
		    text = r.recognize_google_cloud(audio, credentials_json=GOOGLE_CLOUD_SPEECH_CREDENTIALS)

		    #set up dialogflow session, and create a dialogflow query with the text input
		    session = session_client.session_path("glassy-acolyte-228916", "1")
		    text_input = dialogflow.types.TextInput(text=text, language_code="en-US")
		    query_input = dialogflow.types.QueryInput(text=text_input)

		    #detect the intent via dialogflow by passing in the query from the current session, and retreive the response
		    response = session_client.detect_intent(session=session, query_input=query_input)
		    #convert the reponse to a dictionary
		    responseObject = MessageToDict(response)

		    #get the payload from the response, which returns the intent
		    payload = responseObject['queryResult']['fulfillmentMessages'][1]['payload']

		    #get function from payload, e.g "timetables"
		    funct = payload['function']

		    #get date from payload, and convert it to a datetime object
		    dayInfo = payload['date'].split('-')
		    date = datetime.date(int(dayInfo[0]), int(dayInfo[1]), int(dayInfo[2]))

		    #get the day of the week from the datetime object
		    day = date.strftime("%A")
		except sr.UnknownValueError:
		    print("Google Cloud Speech could not understand audio")
		except sr.RequestError as e:
		    print("Could not request results from Google Cloud Speech service; {0}".format(e))

		    #return the function and day
		return jsonify(function=funct, day=day, refreshToken=user['refreshToken'])
	except requests.exceptions.HTTPError as e:
		new = str(e).replace("\n", '')
		parsedError = new[new.index("{"):]
		return jsonify(response=parsedError)


#route to change font
@app.route('/font', methods=['POST'])
def put_font():
	auth = firebase.auth()

	try:
		user = auth.refresh(request.form['refreshToken'])

		db = firebase.database()

		#set posted font under the design node
		result = db.child("users").child(user['userId']).child("design").child("font").set(request.form['font'], user['idToken'])
		#return refresh token if successfull
		return jsonify(refreshToken=user['refreshToken'])
	except requests.exceptions.HTTPError as e:
		new = str(e).replace("\n", '')
		parsedError = new[new.index("{"):]
		return jsonify(response=parsedError)

#route to put text file
@app.route('/putNote', methods=['POST'])
def put_note():
	auth = firebase.auth()

	try:
		user = auth.refresh(request.form['refreshToken'])

		db = firebase.database()

		data = {
			"fileName": request.form['fileName'],
			"delta": request.form['delta']
		}

		if (request.form['nodeID'] == 'null'):
			result = db.child("users").child(user['userId']).child("subjects").child(request.form['subjectID']).child("notes").push(data, user['idToken'])
		else:
			result = db.child("users").child(user['userId']).child("subjects").child(request.form['subjectID']).child("notes").child(request.form['nodeID']).set(data, user['idToken'])

		#return refresh token if successfull
		return jsonify(refreshToken=user['refreshToken'])
	except requests.exceptions.HTTPError as e:
		new = str(e).replace("\n", '')
		parsedError = new[new.index("{"):]
		return jsonify(response=parsedError)

#route to put text file
@app.route('/deleteNote', methods=['POST'])
def delete_note():
	auth = firebase.auth()

	try:
		user = auth.refresh(request.form['refreshToken'])

		db = firebase.database()

		result = db.child("users").child(user['userId']).child("subjects").child(request.form['subjectID']).child("notes").child(request.form['nodeID']).remove(user['idToken'])

		#return refresh token if successfull
		return jsonify(refreshToken=user['refreshToken'])
	except requests.exceptions.HTTPError as e:
		new = str(e).replace("\n", '')
		parsedError = new[new.index("{"):]
		return jsonify(response=parsedError)

#route to get all user notes
@app.route('/getNotes', methods=['GET'])
def get_notes():
	auth = firebase.auth()

	try:
		db = firebase.database()

		user = auth.refresh(request.args['refreshToken'])

		#get all image urls from database for the specific user
		results = db.child("users").child(user['userId']).child("subjects").child(request.args['subjectID']).child("notes").get(user['idToken'])

		#return the images as a list
		return jsonify(notes=results.val(), refreshToken=user['refreshToken'])
	except requests.exceptions.HTTPError as e:
		new = str(e).replace("\n", '')
		parsedError = new[new.index("{"):]
		return jsonify(response=parsedError)

#route to put text file
@app.route('/putSubject', methods=['POST'])
def put_subject():
	auth = firebase.auth()

	try:
		user = auth.refresh(request.form['refreshToken'])

		db = firebase.database()

		data = {
			"name": request.form['name'],
			"colour": request.form['colour']
		}

		if (request.form['nodeID'] == 'null'):
			result = db.child("users").child(user['userId']).child("subjects").push(data, user['idToken'])
		else:
			result = db.child("users").child(user['userId']).child("subjects").child(request.form['nodeID']).set(data, user['idToken'])

		#return refresh token if successfull
		return jsonify(refreshToken=user['refreshToken'])
	except requests.exceptions.HTTPError as e:
		new = str(e).replace("\n", '')
		parsedError = new[new.index("{"):]
		return jsonify(response=parsedError)

#route to get all user notes
@app.route('/getSubjects', methods=['GET'])
def get_subjects():
	auth = firebase.auth()

	try:
		db = firebase.database()

		user = auth.refresh(request.args['refreshToken'])

		#get all image urls from database for the specific user
		results = db.child("users").child(user['userId']).child("subjects").get(user['idToken'])

		#return the images as a list
		return jsonify(subjects=results.val(), refreshToken=user['refreshToken'])
	except requests.exceptions.HTTPError as e:
		new = str(e).replace("\n", '')
		parsedError = new[new.index("{"):]
		return jsonify(response=parsedError)
#run app
if __name__ == '__main__':
	app.run(debug=True)
