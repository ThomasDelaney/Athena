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

# create flask app
app = Flask(__name__)

# initalise firebase app using config, pyrebase library will be used
firebase = pyrebase.initialize_app(config)

# client for googles speech to text api
client = speech_v1.SpeechClient()

# recognizer for speech recognition
r = sr.Recognizer()

# dialogflow session client
session_client = dialogflow.SessionsClient()

# register user route
@app.route('/register', methods=['POST'])
def register_user():
    # retreive firebase authentication
    auth = firebase.auth()

    try:
        # use posted email and password to create user account
        user = auth.create_user_with_email_and_password(request.form['email'], request.form['password'])

        db = firebase.database()

        data = {
            "firstName": request.form['firstName'],
            "secondName": request.form['secondName']
        }

        # upload their first name and second name to the database
        db.child("users").child(user['localId']).child("userDetails").set(data, user['idToken'])

        #add initial colour settings
        fontData = {
            "font": 'Roboto',
            "fontColour": '4278190080',
            "fontSize": '1.0'
        }

        # set posted font under the design node
        db.child("users").child(user['localId']).child("design").child("font").set(fontData, user['idToken'])

        iconData = {
            "iconColour": '4278190080',
            "iconSize": '1.0'
        }

        # set posted font under the design node
        db.child("users").child(user['localId']).child("design").child("icon").set(iconData, user['idToken'])
        db.child("users").child(user['localId']).child("design").child("themeColour").set('4285641955', user['idToken'])
        db.child("users").child(user['localId']).child("design").child("cardColour").set('4294967295', user['idToken'])
        db.child("users").child(user['localId']).child("design").child("backgroundColour").set('4294967295', user['idToken'])
        db.child("users").child(user['localId']).child("design").child("dyslexiaFriendlyEnabled").set('false', user['idToken'])

        # return success message
        return jsonify(message="User Created Successfully")
    # catch exception and handle error
    except requests.exceptions.HTTPError as e:
        new = str(e).replace("\n", '')
        parsedError = json.loads(new[new.index("{"):])

        message = parsedError['error']['message']

        if message == "EMAIL_EXISTS":
            message = "A User with this Email already exists!"
        elif message == "WEAK_PASSWORD : Password should be at least 6 characters":
            message = "Password should be at least 6 characters"

        return jsonify(response=message)

# sign in user route


@app.route('/signin', methods=['POST'])
def sign_in_user():
    auth = firebase.auth()

    try:
        # sign user in with posted email and password
        user = auth.sign_in_with_email_and_password(request.form['email'], request.form['password'])

        db = firebase.database()

        # retrieve user details from database
        results = db.child("users").child(user['localId']).child("userDetails").get(user['idToken'])
        # return user data, id, token and refresh token
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

# route for uploading a photo


@app.route('/putFile', methods=['POST'])
def upload_file():
    auth = firebase.auth()

    try:
        # create an instance of firebase storage
        storage = firebase.storage()
        db = firebase.database()

        user = auth.refresh(request.form['refreshToken'])

        if (request.form['date'] != "null"):
            # get all image urls from database for the specific user
            results = storage.child("users").child(user['userId']).child(request.form['subjectID']).child(request.form['date']).child(request.files['file'].filename).put(request.files['file'], user['idToken'])
            # get url from posted image
            url = storage.child(results['name']).get_url(results['downloadTokens'])

            data = {
                "fileName": request.files['file'].filename,
                "url": str(url),
                "tag": "No Tag"
            }

            # add the url to the database under the images node for the user, give
            # random int as the node for now, will be changed later
            addUrl = db.child("users").child(user['userId']).child("subjects").child(request.form['subjectID']).child(request.form['date']).child("files").push(data, user['idToken'])
        else:
            # get all image urls from database for the specific user
            results = storage.child("users").child(user['userId']).child(request.form['subjectID']).child(request.files['file'].filename).put(request.files['file'], user['idToken'])
            # get url from posted image
            url = storage.child(results['name']).get_url(results['downloadTokens'])

            data = {
                "fileName": request.files['file'].filename,
                "url": str(url),
                "tag": "No Tag"
            }

            # add the url to the database under the images node for the user, give
            # random int as the node for now, will be changed later
            addUrl = db.child("users").child(user['userId']).child("subjects").child(request.form['subjectID']).child("files").push(data, user['idToken'])

        # return the refresh token and the image url
        return jsonify(refreshToken=user['refreshToken'], url=url, fileName=request.files['file'].filename, key=addUrl['name'])
    except requests.exceptions.HTTPError as e:
        new = str(e).replace("\n", '')
        parsedError = new[new.index("{"):]
        return jsonify(response=parsedError)

# route to delete file
@app.route('/deleteFile', methods=['DELETE'])
def delete_file():
    auth = firebase.auth()

    try:
        user = auth.refresh(request.values['refreshToken'])

        storage = firebase.storage()
        db = firebase.database()

        if (request.values['date'] != "null"):
            # delete file from storage
            storage.delete("users/"+user['userId']+"/"+request.values['subjectID']+"/"+request.values['date']+"/"+request.values['fileName'])
            
            result = db.child("users").child(user['userId']).child("subjects").child(request.values['subjectID']).child(request.values['date']).child("files").child(request.values['nodeID']).remove(user['idToken'])

        else: 
            # delete file from storage
            storage.delete("users/"+user['userId']+"/"+request.values['subjectID']+"/"+request.values['fileName'])
            
            result = db.child("users").child(user['userId']).child("subjects").child(request.values['subjectID']).child("files").child(request.values['nodeID']).remove(user['idToken'])

        # return refresh token if successfull
        return jsonify(refreshToken=user['refreshToken'])
    except requests.exceptions.HTTPError as e:
        new = str(e).replace("\n", '')
        parsedError = new[new.index("{"):]
        return jsonify(response=parsedError)        

# route to put tag on file
@app.route('/putTagOnFile', methods=['POST'])
def put_tag_on_file():
    auth = firebase.auth()

    try:
        user = auth.refresh(request.form['refreshToken'])

        db = firebase.database()

        if (request.form['date'] != "null"):
            result = db.child("users").child(user['userId']).child("subjects").child(request.form['subjectID']).child(request.form['date']).child("files").child(request.form['nodeID']).child("tag").set(request.form['tag'], user['idToken'])
        else:
            result = db.child("users").child(user['userId']).child("subjects").child(request.form['subjectID']).child("files").child(request.form['nodeID']).child("tag").set(request.form['tag'], user['idToken'])

        # return refresh token if successfull
        return jsonify(refreshToken=user['refreshToken'])
    except requests.exceptions.HTTPError as e:
        new = str(e).replace("\n", '')
        parsedError = new[new.index("{"):]
        return jsonify(response=parsedError)

# route to get all user photos
@app.route('/getFiles', methods=['GET'])
def get_files():
    auth = firebase.auth()

    try:
        db = firebase.database()

        user = auth.refresh(request.args['refreshToken'])

        if (request.args['date'] != "null"):
            # get all image urls from database for the specific user
            results = db.child("users").child(user['userId']).child("subjects").child(request.args['subjectID']).child(request.args['date']).child("files").get(user['idToken'])
        else:
            results = db.child("users").child(user['userId']).child("subjects").child(request.args['subjectID']).child("files").get(user['idToken'])

        # return the images as a list
        return jsonify(files=results.val(), refreshToken=user['refreshToken'])
    except requests.exceptions.HTTPError as e:
        new = str(e).replace("\n", '')
        parsedError = new[new.index("{"):]
        return jsonify(response=parsedError)

# route to deal with voice command, currently only works with timetable
@app.route('/command', methods=['POST'])
def get_command_keywords():
    auth = firebase.auth()

    try:
        user = auth.refresh(request.form['refreshToken'])

        # use audio segment to get the raw audio from the posted file (which is
        # in a .mp4 format)
        raw_audio = AudioSegment.from_file(request.files['file'])

        # use ffmpeg to convert the file to wav, which is a filetype accepted
        # by google speech to text
        wav_path = "./sample.wav"
        raw_audio.export(wav_path, format="wav")

        # use the audio recorder to convert the new wav file as raw audio
        with sr.AudioFile(wav_path) as source:
            audio = r.record(source)

        option = ""
        funct = ""

        try:
            # use google speech to text api to retrieve the text from the audio
            text = r.recognize_google_cloud(audio, credentials_json=GOOGLE_CLOUD_SPEECH_CREDENTIALS)

            # set up dialogflow session, and create a dialogflow query with the
            # text input
            session = session_client.session_path("qualified-cedar-235821", "1")
            text_input = dialogflow.types.TextInput(
                text=text, language_code="en-GB")
            query_input = dialogflow.types.QueryInput(text=text_input)

            # detect the intent via dialogflow by passing in the query from the
            # current session, and retreive the response
            response = session_client.detect_intent(
                session=session, query_input=query_input)
            # convert the reponse to a dictionary
            responseObject = MessageToDict(response)

            # get the payload from the response, which returns the intent
            payload = responseObject['queryResult']['fulfillmentMessages'][0]['payload']

            # get function from payload, e.g "timetable"
            funct = payload['function']

            if (payload['function'] == 'timetable'):

                days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]

                if (payload['option'] in days):
                    option = payload['option']
                else:
                    # get date from payload, and convert it to a datetime object
                    dayInfo = payload['option'].split('-')

                    date = datetime.date(int(dayInfo[0]), int(dayInfo[1]), int(dayInfo[2]))
                    # get the day of the week from the datetime object
                    option = date.strftime("%A")
            else:
                option = payload['option']

        except sr.UnknownValueError:
            print("Google Cloud Speech could not understand audio")
        except sr.RequestError as e:
            print("Could not request results from Google Cloud Speech service; {0}".format(e))
            # return the function and day
        return jsonify(function=funct, option=option, refreshToken=user['refreshToken'])
    except requests.exceptions.HTTPError as e:
        new = str(e).replace("\n", '')
        parsedError = new[new.index("{"):]
        return jsonify(response=parsedError)


# route to change font
@app.route('/putFontData', methods=['POST'])
def put_font():
    auth = firebase.auth()

    try:
        user = auth.refresh(request.form['refreshToken'])

        db = firebase.database()

        data = {
            "font": request.form['font'],
            "fontColour": request.form['fontColour'],
            "fontSize": request.form['fontSize']
        }

        # set posted font under the design node
        result = db.child("users").child(user['userId']).child("design").child("font").set(data, user['idToken'])
        # return refresh token if successfull
        return jsonify(refreshToken=user['refreshToken'])
    except requests.exceptions.HTTPError as e:
        new = str(e).replace("\n", '')
        parsedError = new[new.index("{"):]
        return jsonify(response=parsedError)

# route to change font
@app.route('/getFontData', methods=['GET'])
def get_font():
    auth = firebase.auth()

    try:
        user = auth.refresh(request.args['refreshToken'])

        db = firebase.database()

        result = db.child("users").child(user['userId']).child("design").child("font").get(user['idToken'])
        # return refresh token if successfull
        return jsonify(data=result.val(), refreshToken=user['refreshToken'])
    except requests.exceptions.HTTPError as e:
        new = str(e).replace("\n", '')
        parsedError = new[new.index("{"):]
        return jsonify(response=parsedError)

# route to change icon settings
@app.route('/putIconData', methods=['POST'])
def put_icon_data():
    auth = firebase.auth()

    try:
        user = auth.refresh(request.form['refreshToken'])

        db = firebase.database()

        data = {
            "iconColour": request.form['iconColour'],
            "iconSize": request.form['iconSize']
        }

        # set posted font under the design node
        result = db.child("users").child(user['userId']).child("design").child("icon").set(data, user['idToken'])
        # return refresh token if successfull
        return jsonify(refreshToken=user['refreshToken'])
    except requests.exceptions.HTTPError as e:
        new = str(e).replace("\n", '')
        parsedError = new[new.index("{"):]
        return jsonify(response=parsedError)

# route to get icon settings
@app.route('/getIconData', methods=['GET'])
def get_icon_data():
    auth = firebase.auth()

    try:
        user = auth.refresh(request.args['refreshToken'])

        db = firebase.database()

        result = db.child("users").child(user['userId']).child("design").child("icon").get(user['idToken'])
        # return refresh token if successfull
        return jsonify(data=result.val(), refreshToken=user['refreshToken'])
    except requests.exceptions.HTTPError as e:
        new = str(e).replace("\n", '')
        parsedError = new[new.index("{"):]
        return jsonify(response=parsedError)

# route to change card colour
@app.route('/putCardColour', methods=['POST'])
def put_card_colour():
    auth = firebase.auth()

    try:
        user = auth.refresh(request.form['refreshToken'])

        db = firebase.database()

        # set posted font under the design node
        result = db.child("users").child(user['userId']).child("design").child("cardColour").set(request.form['cardColour'], user['idToken'])
        # return refresh token if successfull
        return jsonify(refreshToken=user['refreshToken'])
    except requests.exceptions.HTTPError as e:
        new = str(e).replace("\n", '')
        parsedError = new[new.index("{"):]
        return jsonify(response=parsedError)

# route to get card colour
@app.route('/getIsDyslexiaModeEnabled', methods=['GET'])
def get_is_dyslexia_mode_enabled():
    auth = firebase.auth()

    try:
        user = auth.refresh(request.args['refreshToken'])

        db = firebase.database()

        result = db.child("users").child(user['userId']).child("design").child("dyslexiaFriendlyEnabled").get(user['idToken'])
        # return refresh token if successfull
        return jsonify(data=result.val(), refreshToken=user['refreshToken'])
    except requests.exceptions.HTTPError as e:
        new = str(e).replace("\n", '')
        parsedError = new[new.index("{"):]
        return jsonify(response=parsedError)

# route to get card colour
@app.route('/setIsDyslexiaModeEnabled', methods=['POST'])
def set_is_dyslexia_mode_enabled():
    auth = firebase.auth()

    try:
        user = auth.refresh(request.form['refreshToken'])

        db = firebase.database()

        result = db.child("users").child(user['userId']).child("design").child("dyslexiaFriendlyEnabled").set(request.form['dyslexiaFriendlyEnabled'], user['idToken'])
        # return refresh token if successfull
        return jsonify(refreshToken=user['refreshToken'])
    except requests.exceptions.HTTPError as e:
        new = str(e).replace("\n", '')
        parsedError = new[new.index("{"):]
        return jsonify(response=parsedError)

# route to get card colour
@app.route('/getCardColour', methods=['GET'])
def get_card_colour():
    auth = firebase.auth()

    try:
        user = auth.refresh(request.args['refreshToken'])

        db = firebase.database()

        result = db.child("users").child(user['userId']).child("design").child("cardColour").get(user['idToken'])
        # return refresh token if successfull
        return jsonify(data=result.val(), refreshToken=user['refreshToken'])
    except requests.exceptions.HTTPError as e:
        new = str(e).replace("\n", '')
        parsedError = new[new.index("{"):]
        return jsonify(response=parsedError)

# route to change background colour
@app.route('/putBackgroundColour', methods=['POST'])
def put_background_colour():
    auth = firebase.auth()

    try:
        user = auth.refresh(request.form['refreshToken'])

        db = firebase.database()

        # set posted font under the design node
        result = db.child("users").child(user['userId']).child("design").child("backgroundColour").set(request.form['backgroundColour'], user['idToken'])
        # return refresh token if successfull
        return jsonify(refreshToken=user['refreshToken'])
    except requests.exceptions.HTTPError as e:
        new = str(e).replace("\n", '')
        parsedError = new[new.index("{"):]
        return jsonify(response=parsedError)

# route to get background colour
@app.route('/getBackgroundColour', methods=['GET'])
def get_background_colour():
    auth = firebase.auth()

    try:
        user = auth.refresh(request.args['refreshToken'])

        db = firebase.database()

        result = db.child("users").child(user['userId']).child("design").child("backgroundColour").get(user['idToken'])
        # return refresh token if successfull
        return jsonify(data=result.val(), refreshToken=user['refreshToken'])
    except requests.exceptions.HTTPError as e:
        new = str(e).replace("\n", '')
        parsedError = new[new.index("{"):]
        return jsonify(response=parsedError)

# route to change theme colour
@app.route('/putThemeColour', methods=['POST'])
def put_theme_colour():
    auth = firebase.auth()

    try:
        user = auth.refresh(request.form['refreshToken'])

        db = firebase.database()

        # set posted font under the design node
        result = db.child("users").child(user['userId']).child("design").child("themeColour").set(request.form['themeColour'], user['idToken'])
        # return refresh token if successfull
        return jsonify(refreshToken=user['refreshToken'])
    except requests.exceptions.HTTPError as e:
        new = str(e).replace("\n", '')
        parsedError = new[new.index("{"):]
        return jsonify(response=parsedError)

# route to get theme colour
@app.route('/getThemeColour', methods=['GET'])
def get_theme_colour():
    auth = firebase.auth()

    try:
        user = auth.refresh(request.args['refreshToken'])

        db = firebase.database()

        result = db.child("users").child(user['userId']).child("design").child("themeColour").get(user['idToken'])
        # return refresh token if successfull
        return jsonify(data=result.val(), refreshToken=user['refreshToken'])
    except requests.exceptions.HTTPError as e:
        new = str(e).replace("\n", '')
        parsedError = new[new.index("{"):]
        return jsonify(response=parsedError)

# route to put text file
@app.route('/putNote', methods=['POST'])
def put_note():
    auth = firebase.auth()

    try:
        user = auth.refresh(request.form['refreshToken'])

        db = firebase.database()

        data = {
            "fileName": request.form['fileName'],
            "delta": request.form['delta'],
            "tag": request.form['tag']
        }

        if (request.form['nodeID'] == 'null'):
            if (request.form['date'] != "null"):
                result = db.child("users").child(user['userId']).child("subjects").child(request.form['subjectID']).child(request.form['date']).child("notes").push(data, user['idToken'])
            else:
                result = db.child("users").child(user['userId']).child("subjects").child(request.form['subjectID']).child("notes").push(data, user['idToken'])
        else:
            if (request.form['date'] != "null"):
                result = db.child("users").child(user['userId']).child("subjects").child(request.form['subjectID']).child(request.form['date']).child("notes").child(request.form['nodeID']).set(data, user['idToken'])
            else:
                result = db.child("users").child(user['userId']).child("subjects").child(request.form['subjectID']).child("notes").child(request.form['nodeID']).set(data, user['idToken'])

        # return refresh token if successfull
        return jsonify(refreshToken=user['refreshToken'])
    except requests.exceptions.HTTPError as e:
        new = str(e).replace("\n", '')
        parsedError = new[new.index("{"):]
        return jsonify(response=parsedError)

# route to put text file


@app.route('/putTagOnNote', methods=['POST'])
def put_tag_on_note():
    auth = firebase.auth()

    try:
        user = auth.refresh(request.form['refreshToken'])

        db = firebase.database()

        if (request.form['date'] != "null"):
            result = db.child("users").child(user['userId']).child("subjects").child(request.form['subjectID']).child(request.form['date']).child("notes").child(request.form['nodeID']).child("tag").set(request.form['tag'], user['idToken'])
        else:
            result = db.child("users").child(user['userId']).child("subjects").child(request.form['subjectID']).child("notes").child(request.form['nodeID']).child("tag").set(request.form['tag'], user['idToken'])

        # return refresh token if successfull
        return jsonify(refreshToken=user['refreshToken'])
    except requests.exceptions.HTTPError as e:
        new = str(e).replace("\n", '')
        parsedError = new[new.index("{"):]
        return jsonify(response=parsedError)

# route to delete text file
@app.route('/deleteNote', methods=['DELETE'])
def delete_note():
    auth = firebase.auth()

    try:
        user = auth.refresh(request.values['refreshToken'])

        db = firebase.database()

        if (request.values['date'] != "null"):
            result = db.child("users").child(user['userId']).child("subjects").child(request.values['subjectID']).child(request.values['date']).child("notes").child(request.values['nodeID']).remove(user['idToken'])
        else:
            result = db.child("users").child(user['userId']).child("subjects").child(request.values['subjectID']).child("notes").child(request.values['nodeID']).remove(user['idToken'])

        # return refresh token if successfull
        return jsonify(refreshToken=user['refreshToken'])
    except requests.exceptions.HTTPError as e:
        new = str(e).replace("\n", '')
        parsedError = new[new.index("{"):]
        return jsonify(response=parsedError)

# route to get all user notes
@app.route('/getNotes', methods=['GET'])
def get_notes():
    auth = firebase.auth()

    try:
        db = firebase.database()

        user = auth.refresh(request.args['refreshToken'])

        if (request.args['date'] != "null"):
            results = db.child("users").child(user['userId']).child("subjects").child(request.args['subjectID']).child(request.args['date']).child("notes").get(user['idToken'])
        else:
            # get all image urls from database for the specific user
            results = db.child("users").child(user['userId']).child("subjects").child(request.args['subjectID']).child("notes").get(user['idToken'])

        # return the images as a list
        return jsonify(notes=results.val(), refreshToken=user['refreshToken'])
    except requests.exceptions.HTTPError as e:
        new = str(e).replace("\n", '')
        parsedError = new[new.index("{"):]
        return jsonify(response=parsedError)

# route to put text file
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
             # update timeslot information
            timeslots = db.child("users").child(user['userId']).child("timeslots").get(user['idToken'])

            # for each timeslot
            for i, (key, value) in enumerate(timeslots.val().items()):
                forDay = db.child("users").child(user['userId']).child("timeslots").child(key).get(user['idToken'])

                # if the day has timeslots
                if (forDay.val() != None):
                    # for each timeslot for that day
                    for j, (slotKey, slotValue) in enumerate(forDay.val().items()):

                        if (slotValue['subjectTitle'] == request.form['oldTitle']):

                            newData = {
                                "subjectTitle": request.form['name'],
                                "colour": request.form['colour']
                            }

                            db.child("users").child(user['userId']).child("timeslots").child(key).child(slotKey).update(newData, user['idToken'])

            result = db.child("users").child(user['userId']).child("subjects").child(request.form['nodeID']).update(data, user['idToken'])
        # return refreshtoken if successfull
        return jsonify(refreshToken=user['refreshToken'])
    except requests.exceptions.HTTPError as e:
        new = str(e).replace("\n", '')
        parsedError = new[new.index("{"):]
        return jsonify(response=parsedError)

# route to delete subject
@app.route('/deleteSubject', methods=['DELETE'])
def delete_subject():
    auth = firebase.auth()

    try:
        user = auth.refresh(request.values['refreshToken'])

        db = firebase.database()

        timeslots = db.child("users").child(user['userId']).child("timeslots").get(user['idToken'])

        # for each timeslot
        for i, (key, value) in enumerate(timeslots.val().items()):
            forDay = db.child("users").child(user['userId']).child("timeslots").child(key).get(user['idToken'])

            # if the day has timeslots
            if (forDay.val() != None):
                # for each timeslot for that day
                for j, (slotKey, slotValue) in enumerate(forDay.val().items()):

                    if (slotValue['subjectTitle'] == request.values['title']):
                        db.child("users").child(user['userId']).child("timeslots").child(key).child(slotKey).remove(user['idToken'])

        result = db.child("users").child(user['userId']).child( "subjects").child(request.values['nodeID']).remove(user['idToken'])

        # return refresh token if successfull
        return jsonify(refreshToken=user['refreshToken'])
    except requests.exceptions.HTTPError as e:
        new = str(e).replace("\n", '')
        parsedError = new[new.index("{"):]
        return jsonify(response=parsedError)

# route to get all user notes
@app.route('/getSubjects', methods=['GET'])
def get_subjects():
    auth = firebase.auth()

    try:
        db = firebase.database()

        user = auth.refresh(request.args['refreshToken'])

        # get all image urls from database for the specific user
        results = db.child("users").child(user['userId']).child("subjects").get(user['idToken'])

        # return the images as a list
        return jsonify(subjects=results.val(), refreshToken=user['refreshToken'])
    except requests.exceptions.HTTPError as e:
        new = str(e).replace("\n", '')
        parsedError = new[new.index("{"):]
        return jsonify(response=parsedError)

# route to put text file
@app.route('/putTag', methods=['POST'])
def put_tag():
    auth = firebase.auth()

    try:
        user = auth.refresh(request.form['refreshToken'])

        db = firebase.database()

        if (request.form['nodeID'] == 'null'):
            result = db.child("users").child(user['userId']).child("tags").push(request.form['tag'], user['idToken'])
        else:
            # get all subjects
            subjects = db.child("users").child(user['userId']).child("subjects").get(user['idToken'])

            # for each subject
            for i, (key, value) in enumerate(subjects.val().items()): 
                if (key == "journal"):
                    if (value != None):
                        for j, (dateKey, dateValue) in enumerate(value.items()):
                            notes = db.child("users").child(user['userId']).child("subjects").child(key).child(dateKey).child("notes").get(user['idToken'])

                            if (notes.val() != None):
                                for j, (noteKey, noteValue) in enumerate(notes.val().items()):
                                    withTag = db.child("users").child(user['userId']).child("subjects").child(key).child(dateKey).child("notes").child(noteKey).get(user['idToken'])

                                    if (withTag.val()['tag'] == request.form['oldTag']):
                                        db.child("users").child(user['userId']).child("subjects").child(key).child(dateKey).child("notes").child(noteKey).child("tag").set(request.form['tag'], user['idToken'])

                            files = db.child("users").child(user['userId']).child("subjects").child(key).child(dateKey).child("files").get(user['idToken'])

                            # if the subject has files
                            if (files.val() != None):
                                for j, (fileKey, fileValue) in enumerate(files.val().items()):
                                    withTag = db.child("users").child(user['userId']).child("subjects").child(key).child(dateKey).child("files").child(fileKey).get(user['idToken'])

                                    if (withTag.val()['tag'] == request.form['oldTag']):
                                        db.child("users").child(user['userId']).child("subjects").child(key).child(dateKey).child("files").child(fileKey).child("tag").set(request.form['tag'], user['idToken'])
                else:
                    notes = db.child("users").child(user['userId']).child("subjects").child(key).child("notes").get(user['idToken'])

                    # if the subject has notes
                    if (notes.val() != None):
                            # for each note for that subject
                        for j, (noteKey, noteValue) in enumerate(notes.val().items()):
                            withTag = db.child("users").child(user['userId']).child("subjects").child(key).child("notes").child(noteKey).get(user['idToken'])

                            # if that note has the tag to be updated, replace the tag
                            # with new tag
                            if (withTag.val()['tag'] == request.form['oldTag']):
                                db.child("users").child(user['userId']).child("subjects").child(key).child("notes").child(noteKey).child("tag").set(request.form['tag'], user['idToken'])

                    files = db.child("users").child(user['userId']).child("subjects").child(key).child("files").get(user['idToken'])

                    # if the subject has files
                    if (files.val() != None):
                            # for each file for that subject
                        for j, (fileKey, fileValue) in enumerate(files.val().items()):
                            withTag = db.child("users").child(user['userId']).child("subjects").child(key).child("files").child(fileKey).get(user['idToken'])

                            # if that file has the tag to be deleted, replace the tag
                            # with No Tag
                            if (withTag.val()['tag'] == request.form['oldTag']):
                                db.child("users").child(user['userId']).child("subjects").child(key).child("files").child(fileKey).child("tag").set(request.form['tag'], user['idToken'])
                                
            result = db.child("users").child(user['userId']).child("tags").child(request.form['nodeID']).set(request.form['tag'], user['idToken'])

        # return refresh token if successfull
        return jsonify(refreshToken=user['refreshToken'])
    except requests.exceptions.HTTPError as e:
        new = str(e).replace("\n", '')
        parsedError = new[new.index("{"):]
        return jsonify(response=parsedError)

# route to delete subject
@app.route('/deleteTag', methods=['DELETE'])
def delete_tag():
    auth = firebase.auth()

    try:
        user = auth.refresh(request.values['refreshToken'])

        db = firebase.database()

        # get all subjects
        subjects = db.child("users").child(user['userId']).child("subjects").get(user['idToken'])

        # for each subject
        for i, (key, value) in enumerate(subjects.val().items()):
            if (key == "journal"):
                if (value != None):
                    for j, (dateKey, dateValue) in enumerate(value.items()):
                        notes = db.child("users").child(user['userId']).child("subjects").child(key).child(dateKey).child("notes").get(user['idToken'])

                        if (notes.val() != None):
                            for j, (noteKey, noteValue) in enumerate(notes.val().items()):
                                withTag = db.child("users").child(user['userId']).child("subjects").child(key).child(dateKey).child("notes").child(noteKey).get(user['idToken'])

                                if (withTag.val()['tag'] == request.values['tag']):
                                    db.child("users").child(user['userId']).child("subjects").child(key).child(dateKey).child("notes").child(noteKey).child("tag").set("No Tag", user['idToken'])

                        files = db.child("users").child(user['userId']).child("subjects").child(key).child(dateKey).child("files").get(user['idToken'])

                        # if the subject has files
                        if (files.val() != None):
                            for j, (fileKey, fileValue) in enumerate(files.val().items()):
                                withTag = db.child("users").child(user['userId']).child("subjects").child(key).child(dateKey).child("files").child(fileKey).get(user['idToken'])

                                if (withTag.val()['tag'] == request.values['tag']):
                                       db.child("users").child(user['userId']).child("subjects").child(key).child("files").child(fileKey).child("tag").set("No Tag", user['idToken'])   
            else:
                notes = db.child("users").child(user['userId']).child("subjects").child(key).child("notes").get(user['idToken'])

                # if the subject has notes
                if (notes.val() != None):
                        # for each note for that subject
                    for j, (noteKey, noteValue) in enumerate(notes.val().items()):
                        withTag = db.child("users").child(user['userId']).child("subjects").child(key).child("notes").child(noteKey).get(user['idToken'])

                        # if that note has the tag to be deleted, replace the tag
                        # with No Tag
                        if (withTag.val()['tag'] == request.values['tag']):
                            db.child("users").child(user['userId']).child("subjects").child(key).child("notes").child(noteKey).child("tag").set("No Tag", user['idToken'])

                files = db.child("users").child(user['userId']).child("subjects").child(key).child("files").get(user['idToken'])

                # if the subject has files
                if (files.val() != None):
                        # for each file for that subject
                    for j, (fileKey, fileValue) in enumerate(files.val().items()):
                        withTag = db.child("users").child(user['userId']).child("subjects").child(key).child("files").child(fileKey).get(user['idToken'])

                        # if that file has the tag to be deleted, replace the tag
                        # with No Tag
                        if (withTag.val()['tag'] == request.values['tag']):
                            db.child("users").child(user['userId']).child("subjects").child(key).child("files").child(fileKey).child("tag").set("No Tag", user['idToken'])

        # delete the tag
        result = db.child("users").child(user['userId']).child("tags").child(request.values['nodeID']).remove(user['idToken'])

        # return refresh token if successfull
        return jsonify(refreshToken=user['refreshToken'])
    except requests.exceptions.HTTPError as e:
        new = str(e).replace("\n", '')
        parsedError = new[new.index("{"):]
        return jsonify(response=parsedError)

# route to get all user notes
@app.route('/getTags', methods=['GET'])
def get_tags():
    auth = firebase.auth()

    try:
        db = firebase.database()

        user = auth.refresh(request.args['refreshToken'])

        # get all image urls from database for the specific user
        results = db.child("users").child(user['userId']).child("tags").get(user['idToken'])

        # return the images as a list
        return jsonify(tags=results.val(), refreshToken=user['refreshToken'])
    except requests.exceptions.HTTPError as e:
        new = str(e).replace("\n", '')
        parsedError = new[new.index("{"):]
        return jsonify(response=parsedError)

@app.route('/getNotesAndFilesWithTag', methods=['GET'])
def get_notes_and_files_with_tag():
    auth = firebase.auth()

    try:
        user = auth.refresh(request.args['refreshToken'])

        db = firebase.database()

        notesWithTag = []
        filesWithTag = []

        # get all subjects
        subjects = db.child("users").child(user['userId']).child("subjects").get(user['idToken'])

        # for each subject
        for i, (key, value) in enumerate(subjects.val().items()):
            if (key == "journal"):
                if (value != None):
                    for j, (dateKey, dateValue) in enumerate(value.items()):
                        notes = db.child("users").child(user['userId']).child("subjects").child(key).child(dateKey).child("notes").get(user['idToken'])

                        if (notes.val() != None):
                            for j, (noteKey, noteValue) in enumerate(notes.val().items()):
                                withTag = db.child("users").child(user['userId']).child("subjects").child(key).child(dateKey).child("notes").child(noteKey).get(user['idToken'])

                                if (withTag.val()['tag'].lower() == request.args['tag'].lower()):
                                    notesWithTag.append({"note": {"key": noteKey, "values": withTag.val()}, "subject": {"key": key, "value": value}});

                        files = db.child("users").child(user['userId']).child("subjects").child(key).child(dateKey).child("files").get(user['idToken'])

                        # if the subject has files
                        if (files.val() != None):
                            for j, (fileKey, fileValue) in enumerate(files.val().items()):
                                withTag = db.child("users").child(user['userId']).child("subjects").child(key).child("files").child(fileKey).get(user['idToken'])

                                if (withTag.val()['tag'].lower() == request.args['tag'].lower()):
                                    filesWithTag.append({"file": {"key": fileKey, "values": withTag.val()}, "subject": {"key": key, "value": value}});    
                else:
                    notes = db.child("users").child(user['userId']).child("subjects").child(key).child("notes").get(user['idToken'])

                # if the subject has notes
                if (notes.val() != None):
                # for each note for that subject
                    for j, (noteKey, noteValue) in enumerate(notes.val().items()):
                        withTag = db.child("users").child(user['userId']).child("subjects").child(key).child("notes").child(noteKey).get(user['idToken'])

                        if (withTag.val()['tag'].lower() == request.args['tag'].lower()):
                            notesWithTag.append({"note": {"key": noteKey, "values": withTag.val()}, "subject": {"key": key, "value": value}});

                files = db.child("users").child(user['userId']).child("subjects").child(key).child("files").get(user['idToken'])

                # if the subject has files
                if (files.val() != None):
                # for each file for that subject
                    for j, (fileKey, fileValue) in enumerate(files.val().items()):
                        withTag = db.child("users").child(user['userId']).child("subjects").child(key).child("files").child(fileKey).get(user['idToken'])

                        if (withTag.val()['tag'].lower() == request.args['tag'].lower()):
                            filesWithTag.append({"file": {"key": fileKey, "values": withTag.val()}, "subject": {"key": key, "value": value}});    

        # return refresh token if successfull
        return jsonify(refreshToken=user['refreshToken'], files=filesWithTag, notes=notesWithTag)
    except requests.exceptions.HTTPError as e:
        new = str(e).replace("\n", '')
        parsedError = new[new.index("{"):]
        return jsonify(response=parsedError)

#get timetslots
@app.route('/getTimeslots', methods=['GET'])
def get_timeslots():
    auth = firebase.auth()

    try:
        db = firebase.database()

        user = auth.refresh(request.args['refreshToken'])

        # get all image urls from database for the specific user
        results = db.child("users").child(user['userId']).child("timeslots").get(user['idToken'])

        # return the images as a list
        return jsonify(timeslots=results.val(), refreshToken=user['refreshToken'])
    except requests.exceptions.HTTPError as e:
        new = str(e).replace("\n", '')
        parsedError = new[new.index("{"):]
        return jsonify(response=parsedError)

# route to put timeslot
@app.route('/putTimeslot', methods=['POST'])
def put_timeslot():
    auth = firebase.auth()

    try:
        user = auth.refresh(request.form['refreshToken'])

        db = firebase.database()

        data = {
            "subjectTitle": request.form['subjectTitle'],
            "colour": request.form['colour'],
            "room": request.form['room'],
            "time": request.form['time'],
            "teacher": request.form['teacher']
        }

        if (request.form['nodeID'] == 'null'):
            result = db.child("users").child(user['userId']).child("timeslots").child(request.form['day']).push(data, user['idToken'])
        else:
            result = db.child("users").child(user['userId']).child("timeslots").child(request.form['day']).child(request.form['nodeID']).update(data, user['idToken'])

        # return refresh token if successfull
        return jsonify(refreshToken=user['refreshToken'])
    except requests.exceptions.HTTPError as e:
        new = str(e).replace("\n", '')
        parsedError = new[new.index("{"):]
        return jsonify(response=parsedError)

# route to delete subject
@app.route('/deleteTimeslot', methods=['DELETE'])
def delete_timeslot():
    auth = firebase.auth()

    try:
        user = auth.refresh(request.values['refreshToken'])

        db = firebase.database()

        result = db.child("users").child(user['userId']).child("timeslots").child(request.values['day']).child(request.values['nodeID']).remove(user['idToken'])

        # return refresh token if successfull
        return jsonify(refreshToken=user['refreshToken'])
    except requests.exceptions.HTTPError as e:
        new = str(e).replace("\n", '')
        parsedError = new[new.index("{"):]
        return jsonify(response=parsedError)


@app.route('/putTestResult', methods=['POST'])
def put_test_result():
    auth = firebase.auth()

    try:
        user = auth.refresh(request.form['refreshToken'])

        db = firebase.database()

        data = {
            "title": request.form['title'],
            "score": request.form['score'],
        }

        if (request.form['nodeID'] == 'null'):
            result = db.child("users").child(user['userId']).child("subjects").child(request.form['subjectID']).child("results").push(data, user['idToken'])
        else:
            result = db.child("users").child(user['userId']).child("subjects").child(request.form['subjectID']).child("results").child(request.form['nodeID']).set(data, user['idToken'])

        # return refresh token if successfull
        return jsonify(refreshToken=user['refreshToken'])
    except requests.exceptions.HTTPError as e:
        new = str(e).replace("\n", '')
        parsedError = new[new.index("{"):]
        return jsonify(response=parsedError)

@app.route('/getTestResults', methods=['GET'])
def get_test_results():
    auth = firebase.auth()

    try:
        db = firebase.database()

        user = auth.refresh(request.args['refreshToken'])

        # get all image urls from database for the specific user
        results = db.child("users").child(user['userId']).child("subjects").child(request.args['subjectID']).child("results").get(user['idToken'])

        # return the images as a list
        return jsonify(results=results.val(), refreshToken=user['refreshToken'])
    except requests.exceptions.HTTPError as e:
        new = str(e).replace("\n", '')
        parsedError = new[new.index("{"):]
        return jsonify(response=parsedError)

 # route to delete test result file
@app.route('/deleteTestResult', methods=['DELETE'])
def delete_test_result():
    auth = firebase.auth()

    try:
        user = auth.refresh(request.values['refreshToken'])

        db = firebase.database()

        result = db.child("users").child(user['userId']).child("subjects").child(request.values['subjectID']).child("results").child(request.values['nodeID']).remove(user['idToken'])

        # return refresh token if successfull
        return jsonify(refreshToken=user['refreshToken'])
    except requests.exceptions.HTTPError as e:
        new = str(e).replace("\n", '')
        parsedError = new[new.index("{"):]
        return jsonify(response=parsedError)

@app.route('/putNotification', methods=['POST'])
def put_notification():
    auth = firebase.auth()

    try:
        user = auth.refresh(request.form['refreshToken'])

        db = firebase.database()

        data = {
            "description": request.form['description'],
            "time": request.form['time'],
        }

        result = db.child("users").child(user['userId']).child("notifications").child(request.form['nodeID']).set(data, user['idToken'])

        # return refresh token if successfull
        return jsonify(refreshToken=user['refreshToken'])
    except requests.exceptions.HTTPError as e:
        new = str(e).replace("\n", '')
        parsedError = new[new.index("{"):]
        return jsonify(response=parsedError)

@app.route('/getNotifications', methods=['GET'])
def get_notifications():
    auth = firebase.auth()

    try:
        db = firebase.database()

        user = auth.refresh(request.args['refreshToken'])

        # get all image urls from database for the specific user
        results = db.child("users").child(user['userId']).child("notifications").get(user['idToken'])

        # return the images as a list
        return jsonify(notifications=results.val(), refreshToken=user['refreshToken'])
    except requests.exceptions.HTTPError as e:
        new = str(e).replace("\n", '')
        parsedError = new[new.index("{"):]
        return jsonify(response=parsedError)

 # route to delete test result file
@app.route('/deleteNotification', methods=['DELETE'])
def delete_notification():
    auth = firebase.auth()

    try:
        user = auth.refresh(request.values['refreshToken'])

        db = firebase.database()

        result = db.child("users").child(user['userId']).child("notifications").child(request.values['nodeID']).remove(user['idToken'])

        # return refresh token if successfull
        return jsonify(refreshToken=user['refreshToken'])
    except requests.exceptions.HTTPError as e:
        new = str(e).replace("\n", '')
        parsedError = new[new.index("{"):]
        return jsonify(response=parsedError)


@app.route('/putHomework', methods=['POST'])
def put_homework():
    auth = firebase.auth()

    try:
        user = auth.refresh(request.form['refreshToken'])

        db = firebase.database()

        data = {
            "description": request.form['description'],
            "isCompleted": request.form['isCompleted'],
        }

        if (request.form['nodeID'] == 'null'):
            result = db.child("users").child(user['userId']).child("subjects").child(request.form['subjectID']).child("homework").push(data, user['idToken'])
        else:
            result = db.child("users").child(user['userId']).child("subjects").child(request.form['subjectID']).child("homework").child(request.form['nodeID']).set(data, user['idToken'])

        # return refresh token if successfull
        return jsonify(refreshToken=user['refreshToken'])
    except requests.exceptions.HTTPError as e:
        new = str(e).replace("\n", '')
        parsedError = new[new.index("{"):]
        return jsonify(response=parsedError)

@app.route('/getHomework', methods=['GET'])
def get_homework():
    auth = firebase.auth()

    try:
        db = firebase.database()

        user = auth.refresh(request.args['refreshToken'])

        # get all image urls from database for the specific user
        results = db.child("users").child(user['userId']).child("subjects").child(request.args['subjectID']).child("homework").get(user['idToken'])

        # return the images as a list
        return jsonify(homework=results.val(), refreshToken=user['refreshToken'])
    except requests.exceptions.HTTPError as e:
        new = str(e).replace("\n", '')
        parsedError = new[new.index("{"):]
        return jsonify(response=parsedError)

 # route to delete test result file
@app.route('/deleteHomework', methods=['DELETE'])
def delete_homework():
    auth = firebase.auth()

    try:
        user = auth.refresh(request.values['refreshToken'])

        db = firebase.database()

        result = db.child("users").child(user['userId']).child("subjects").child(request.values['subjectID']).child("homework").child(request.values['nodeID']).remove(user['idToken'])

        # return refresh token if successfull
        return jsonify(refreshToken=user['refreshToken'])
    except requests.exceptions.HTTPError as e:
        new = str(e).replace("\n", '')
        parsedError = new[new.index("{"):]
        return jsonify(response=parsedError)


@app.route('/putMaterial', methods=['POST'])
def put_material():
    auth = firebase.auth()

    try:
        user = auth.refresh(request.form['refreshToken'])

        storage = firebase.storage()
        db = firebase.database()

        data = {}

        if (request.form.get('file') != 'null'):
            # store posted image under posted filename
            results = storage.child("users").child(user['userId']).child(request.form['subjectID']).child("materials").child(request.files['file'].filename).put(request.files['file'], user['idToken'])
            # get url from posted image
            url = storage.child(results['name']).get_url(results['downloadTokens'])

            data = {
                "fileName": request.files['file'].filename,
                "name": request.form['name'],
                "photoUrl": str(url),
            }
        else:
            data = {
                "name": request.form['name'],
            }

        if (request.form['nodeID'] == 'null'):
            addUrl = db.child("users").child(user['userId']).child("subjects").child(request.form['subjectID']).child("materials").push(data, user['idToken'])
        elif (request.form.get('file') == 'null'):
            addUrl = db.child("users").child(user['userId']).child("subjects").child(request.form['subjectID']).child("materials").child(request.form['nodeID']).set(data, user['idToken'])
        else:
            if (request.form['previousFile'] != 'null'):
                storage.delete("users/"+user['userId']+"/"+request.form['subjectID']+"/materials/"+request.form['previousFile'])

            addUrl = db.child("users").child(user['userId']).child("subjects").child(request.form['subjectID']).child("materials").child(request.form['nodeID']).set(data, user['idToken'])

        # return refresh token if successfull
        return jsonify(refreshToken=user['refreshToken'])
    except requests.exceptions.HTTPError as e:
        new = str(e).replace("\n", '')
        parsedError = new[new.index("{"):]
        return jsonify(response=parsedError)

@app.route('/getMaterials', methods=['GET'])
def get_materials():
    auth = firebase.auth()

    try:
        user = auth.refresh(request.args['refreshToken'])

        storage = firebase.storage()
        db = firebase.database()

        # get all image urls from database for the specific user
        results = db.child("users").child(user['userId']).child("subjects").child(request.args['subjectID']).child("materials").get(user['idToken'])

        # return the images as a list
        return jsonify(materials=results.val(), refreshToken=user['refreshToken'])
    except requests.exceptions.HTTPError as e:
        new = str(e).replace("\n", '')
        parsedError = new[new.index("{"):]
        return jsonify(response=parsedError)

# route to delete material file
@app.route('/deleteMaterial', methods=['DELETE'])
def delete_material():
    auth = firebase.auth()

    try:
        user = auth.refresh(request.values['refreshToken'])

        storage = firebase.storage()
        db = firebase.database()

        if(request.values['fileName'] != 'null'):
            storage.delete("users/"+user['userId']+"/"+request.values['subjectID']+"/materials/"+request.values['fileName'])

        result = db.child("users").child(user['userId']).child("subjects").child(request.values['subjectID']).child("materials").child(request.values['nodeID']).remove(user['idToken'])

        # return refresh token if successfull
        return jsonify(refreshToken=user['refreshToken'])
    except requests.exceptions.HTTPError as e:
        new = str(e).replace("\n", '')
        parsedError = new[new.index("{"):]
        return jsonify(response=parsedError)

# run app
if __name__ == '__main__':
    app.run(debug=True)
