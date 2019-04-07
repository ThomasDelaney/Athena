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

        #initialize initial colour settings
        fontData = {
            "font": 'Roboto',
            "fontColour": '4278190080',
            "fontSize": '1.0'
        }

        iconData = {
            "iconColour": '4278190080',
            "iconSize": '1.0'
        }

        #set default colour settings
        db.child("users").child(user['localId']).child("design").child("font").set(fontData, user['idToken'])
        db.child("users").child(user['localId']).child("design").child("icon").set(iconData, user['idToken'])
        db.child("users").child(user['localId']).child("design").child("themeColour").set('4285641955', user['idToken'])
        db.child("users").child(user['localId']).child("design").child("cardColour").set('4294967295', user['idToken'])
        db.child("users").child(user['localId']).child("design").child("backgroundColour").set('4294967295', user['idToken'])
        db.child("users").child(user['localId']).child("design").child("dyslexiaFriendlyEnabled").set('false', user['idToken'])

        # return success message
        return jsonify(message="User Created successfuly")
    # catch exception and handle error
    except requests.exceptions.HTTPError as e:
        new = str(e).replace("\n", '')
        parsedError = json.loads(new[new.index("{"):])

        #parse and send error message
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

        #parse and return error
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

        #if form data is not null (aka it is a journal upload)
        if (request.form['date'] != "null"):
            # get all media urls from database for the specific user
            results = storage.child("users").child(user['userId']).child(request.form['subjectID']).child(request.form['date']).child(request.files['file'].filename).put(request.files['file'], user['idToken'])
            # get url from posted media
            url = storage.child(results['name']).get_url(results['downloadTokens'])

            data = {
                "fileName": request.files['file'].filename,
                "url": str(url),
                "tag": "No Tag"
            }

            # add the url to the database under the files node for the user
            addUrl = db.child("users").child(user['userId']).child("subjects").child(request.form['subjectID']).child(request.form['date']).child("files").push(data, user['idToken'])
        #else if virtual hardback upload
        else:
            # get all file urls from database for the specific user
            results = storage.child("users").child(user['userId']).child(request.form['subjectID']).child(request.files['file'].filename).put(request.files['file'], user['idToken'])
            # get url from posted file
            url = storage.child(results['name']).get_url(results['downloadTokens'])

            data = {
                "fileName": request.files['file'].filename,
                "url": str(url),
                "tag": "No Tag"
            }

            # add the url to the database under the files node for the user
            addUrl = db.child("users").child(user['userId']).child("subjects").child(request.form['subjectID']).child("files").push(data, user['idToken'])

        # return the refresh token and the file url
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

        #if date value is not equal to null (aka its journal file)
        if (request.values['date'] != "null"):
            # delete file from storage
            storage.delete("users/"+user['userId']+"/"+request.values['subjectID']+"/"+request.values['date']+"/"+request.values['fileName'])
            
            #remove node from database
            result = db.child("users").child(user['userId']).child("subjects").child(request.values['subjectID']).child(request.values['date']).child("files").child(request.values['nodeID']).remove(user['idToken'])
        #else if virtual hardback file
        else: 
            # delete file from storage
            storage.delete("users/"+user['userId']+"/"+request.values['subjectID']+"/"+request.values['fileName'])
            
            #remove node from database
            result = db.child("users").child(user['userId']).child("subjects").child(request.values['subjectID']).child("files").child(request.values['nodeID']).remove(user['idToken'])

        # return refresh token if successful
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

        #if date is not null (aka its journal file)
        if (request.form['date'] != "null"):
            #put new tag as tag for file
            result = db.child("users").child(user['userId']).child("subjects").child(request.form['subjectID']).child(request.form['date']).child("files").child(request.form['nodeID']).child("tag").set(request.form['tag'], user['idToken'])
        else:
            result = db.child("users").child(user['userId']).child("subjects").child(request.form['subjectID']).child("files").child(request.form['nodeID']).child("tag").set(request.form['tag'], user['idToken'])

        # return refresh token if successful
        return jsonify(refreshToken=user['refreshToken'])
    except requests.exceptions.HTTPError as e:
        new = str(e).replace("\n", '')
        parsedError = new[new.index("{"):]
        return jsonify(response=parsedError)

# route to get all user files
@app.route('/getFiles', methods=['GET'])
def get_files():
    auth = firebase.auth()

    try:
        db = firebase.database()

        user = auth.refresh(request.args['refreshToken'])

        #if date is not null (aka its journal file)
        if (request.args['date'] != "null"):
            # get all file urls from database for the specific user
            results = db.child("users").child(user['userId']).child("subjects").child(request.args['subjectID']).child(request.args['date']).child("files").get(user['idToken'])
        else:
            results = db.child("users").child(user['userId']).child("subjects").child(request.args['subjectID']).child("files").get(user['idToken'])

        # return the files as a list
        return jsonify(files=results.val(), refreshToken=user['refreshToken'])
    except requests.exceptions.HTTPError as e:
        new = str(e).replace("\n", '')
        parsedError = new[new.index("{"):]
        return jsonify(response=parsedError)

# route to deal with voice command
@app.route('/command', methods=['POST'])
def get_command_keywords():
    auth = firebase.auth()

    try:
        user = auth.refresh(request.form['refreshToken'])

        print(request.form)
        print(request.files)

        # use audio segment to get the raw audio from the posted file (which is
        # in a .mp4 format)
        raw_audio = AudioSegment.from_file(request.files['file'], format="m4a")

        # use ffmpeg to convert the file to wav, which is a filetype accepted
        # by google speech to text
        wav_path = "./sample.flac"
        raw_audio.export(wav_path, format="flac")

        # use the audio recorder to convert the new wav file as raw audio
        with sr.AudioFile(wav_path) as source:
            audio = r.record(source)

        #output variables
        option = ""
        funct = ""

        try:
            # use google speech to text api to retrieve the text from the audio
            text = r.recognize_google_cloud(audio, credentials_json=GOOGLE_CLOUD_SPEECH_CREDENTIALS)

            # set up dialogflow session, and create a dialogflow query with the text input
            session = session_client.session_path("qualified-cedar-235821", "1")
            text_input = dialogflow.types.TextInput(text=text, language_code="en-GB")
            query_input = dialogflow.types.QueryInput(text=text_input)

            # detect the intent via dialogflow by passing in the query from the
            # current session, and retreive the response
            response = session_client.detect_intent(session=session, query_input=query_input)

            # convert the reponse to a dictionary
            responseObject = MessageToDict(response)

            print(responseObject['queryResult']['fulfillmentMessages'])

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
            # return the function and option
        return jsonify(function=funct, option=option, refreshToken=user['refreshToken'])
    except requests.exceptions.HTTPError as e:
        new = str(e).replace("\n", '')
        parsedError = new[new.index("{"):]
        return jsonify(response=parsedError)


# route to add or update font
@app.route('/putFontData', methods=['POST'])
def put_font():
    auth = firebase.auth()

    try:
        user = auth.refresh(request.form['refreshToken'])

        db = firebase.database()

        #create dictionary from font form data
        data = {
            "font": request.form['font'],
            "fontColour": request.form['fontColour'],
            "fontSize": request.form['fontSize']
        }

        # set posted font under the design node
        result = db.child("users").child(user['userId']).child("design").child("font").set(data, user['idToken'])
        # return refresh token if successful
        return jsonify(refreshToken=user['refreshToken'])
    except requests.exceptions.HTTPError as e:
        new = str(e).replace("\n", '')
        parsedError = new[new.index("{"):]
        return jsonify(response=parsedError)

# route to get font data for a user
@app.route('/getFontData', methods=['GET'])
def get_font():
    auth = firebase.auth()

    try:
        user = auth.refresh(request.args['refreshToken'])

        db = firebase.database()

        # get font data under the design node
        result = db.child("users").child(user['userId']).child("design").child("font").get(user['idToken'])
        # return refresh token if successful
        return jsonify(data=result.val(), refreshToken=user['refreshToken'])
    except requests.exceptions.HTTPError as e:
        new = str(e).replace("\n", '')
        parsedError = new[new.index("{"):]
        return jsonify(response=parsedError)

# route to create or updatre icon settings
@app.route('/putIconData', methods=['POST'])
def put_icon_data():
    auth = firebase.auth()

    try:
        user = auth.refresh(request.form['refreshToken'])

        db = firebase.database()

        # get icon data under the design node
        data = {
            "iconColour": request.form['iconColour'],
            "iconSize": request.form['iconSize']
        }

        # set posted icon data under the design node
        result = db.child("users").child(user['userId']).child("design").child("icon").set(data, user['idToken'])
        # return refresh token if successful
        return jsonify(refreshToken=user['refreshToken'])
    except requests.exceptions.HTTPError as e:
        new = str(e).replace("\n", '')
        parsedError = new[new.index("{"):]
        return jsonify(response=parsedError)

# route to get icon data
@app.route('/getIconData', methods=['GET'])
def get_icon_data():
    auth = firebase.auth()

    try:
        user = auth.refresh(request.args['refreshToken'])

        db = firebase.database()

        # get icon data under the design node
        result = db.child("users").child(user['userId']).child("design").child("icon").get(user['idToken'])
        # return refresh token if successful
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

        # set posted card colour under the design node
        result = db.child("users").child(user['userId']).child("design").child("cardColour").set(request.form['cardColour'], user['idToken'])
        # return refresh token if successful
        return jsonify(refreshToken=user['refreshToken'])
    except requests.exceptions.HTTPError as e:
        new = str(e).replace("\n", '')
        parsedError = new[new.index("{"):]
        return jsonify(response=parsedError)

# route to check if the dyslexia mode is enabled
@app.route('/getIsDyslexiaModeEnabled', methods=['GET'])
def get_is_dyslexia_mode_enabled():
    auth = firebase.auth()

    try:
        user = auth.refresh(request.args['refreshToken'])

        db = firebase.database()

        # get dyslexia mode enabled under the design node
        result = db.child("users").child(user['userId']).child("design").child("dyslexiaFriendlyEnabled").get(user['idToken'])
        # return refresh token if successful
        return jsonify(data=result.val(), refreshToken=user['refreshToken'])
    except requests.exceptions.HTTPError as e:
        new = str(e).replace("\n", '')
        parsedError = new[new.index("{"):]
        return jsonify(response=parsedError)

# route set dyslexia mode enabled
@app.route('/setIsDyslexiaModeEnabled', methods=['POST'])
def set_is_dyslexia_mode_enabled():
    auth = firebase.auth()

    try:
        user = auth.refresh(request.form['refreshToken'])

        db = firebase.database()

        # set dyslexia mode enabled under the design node
        result = db.child("users").child(user['userId']).child("design").child("dyslexiaFriendlyEnabled").set(request.form['dyslexiaFriendlyEnabled'], user['idToken'])
        # return refresh token if successful
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

        # get card colour under the design node
        result = db.child("users").child(user['userId']).child("design").child("cardColour").get(user['idToken'])
        # return refresh token if successful
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

        # set posted background colour under the design node
        result = db.child("users").child(user['userId']).child("design").child("backgroundColour").set(request.form['backgroundColour'], user['idToken'])
        # return refresh token if successful
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

        # get background colour under the design node
        result = db.child("users").child(user['userId']).child("design").child("backgroundColour").get(user['idToken'])
        # return refresh token if successful
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

        # set posted theme colour under the design node
        result = db.child("users").child(user['userId']).child("design").child("themeColour").set(request.form['themeColour'], user['idToken'])
        # return refresh token if successful
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

        # get theme colour under the design node
        result = db.child("users").child(user['userId']).child("design").child("themeColour").get(user['idToken'])
        # return refresh token if successful
        return jsonify(data=result.val(), refreshToken=user['refreshToken'])
    except requests.exceptions.HTTPError as e:
        new = str(e).replace("\n", '')
        parsedError = new[new.index("{"):]
        return jsonify(response=parsedError)

# route to put note
@app.route('/putNote', methods=['POST'])
def put_note():
    auth = firebase.auth()

    try:
        user = auth.refresh(request.form['refreshToken'])

        db = firebase.database()

        # create dictionary from form data
        data = {
            "fileName": request.form['fileName'],
            "delta": request.form['delta'],
            "tag": request.form['tag']
        }

        # if nodeID is null (create)
        if (request.form['nodeID'] == 'null'):
            # if date is not null (aka its a journal note) create note for both situations
            if (request.form['date'] != "null"):
                result = db.child("users").child(user['userId']).child("subjects").child(request.form['subjectID']).child(request.form['date']).child("notes").push(data, user['idToken'])
            else:
                result = db.child("users").child(user['userId']).child("subjects").child(request.form['subjectID']).child("notes").push(data, user['idToken'])
        # else update
        else:
            # if date is not null (aka its a journal note) update note for both situations
            if (request.form['date'] != "null"):
                result = db.child("users").child(user['userId']).child("subjects").child(request.form['subjectID']).child(request.form['date']).child("notes").child(request.form['nodeID']).set(data, user['idToken'])
            else:
                result = db.child("users").child(user['userId']).child("subjects").child(request.form['subjectID']).child("notes").child(request.form['nodeID']).set(data, user['idToken'])

        # return refresh token if successful
        return jsonify(refreshToken=user['refreshToken'])
    except requests.exceptions.HTTPError as e:
        new = str(e).replace("\n", '')
        parsedError = new[new.index("{"):]
        return jsonify(response=parsedError)

# route to put tag on note
@app.route('/putTagOnNote', methods=['POST'])
def put_tag_on_note():
    auth = firebase.auth()

    try:
        user = auth.refresh(request.form['refreshToken'])

        db = firebase.database()

        # if date is not null (aka its a journal note)
        if (request.form['date'] != "null"):
            # set tag on note to form tag
            result = db.child("users").child(user['userId']).child("subjects").child(request.form['subjectID']).child(request.form['date']).child("notes").child(request.form['nodeID']).child("tag").set(request.form['tag'], user['idToken'])
        else:
            result = db.child("users").child(user['userId']).child("subjects").child(request.form['subjectID']).child("notes").child(request.form['nodeID']).child("tag").set(request.form['tag'], user['idToken'])

        # return refresh token if successful
        return jsonify(refreshToken=user['refreshToken'])
    except requests.exceptions.HTTPError as e:
        new = str(e).replace("\n", '')
        parsedError = new[new.index("{"):]
        return jsonify(response=parsedError)

# route to delete note
@app.route('/deleteNote', methods=['DELETE'])
def delete_note():
    auth = firebase.auth()

    try:
        user = auth.refresh(request.values['refreshToken'])

        db = firebase.database()

        # if date is not null (aka its a journal note)
        if (request.values['date'] != "null"):
             # remove note node
            result = db.child("users").child(user['userId']).child("subjects").child(request.values['subjectID']).child(request.values['date']).child("notes").child(request.values['nodeID']).remove(user['idToken'])
        else:
            result = db.child("users").child(user['userId']).child("subjects").child(request.values['subjectID']).child("notes").child(request.values['nodeID']).remove(user['idToken'])

        # return refresh token if successful
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

        # if date is not null (aka its a journal note)
        if (request.args['date'] != "null"):
            # get all notes for user under form data
            results = db.child("users").child(user['userId']).child("subjects").child(request.args['subjectID']).child(request.args['date']).child("notes").get(user['idToken'])
        else:
            # get all notes from database for the specific subject ID
            results = db.child("users").child(user['userId']).child("subjects").child(request.args['subjectID']).child("notes").get(user['idToken'])

        # return the notes as a list
        return jsonify(notes=results.val(), refreshToken=user['refreshToken'])
    except requests.exceptions.HTTPError as e:
        new = str(e).replace("\n", '')
        parsedError = new[new.index("{"):]
        return jsonify(response=parsedError)

# route to create or update a subject
@app.route('/putSubject', methods=['POST'])
def put_subject():
    auth = firebase.auth()

    try:
        user = auth.refresh(request.form['refreshToken'])

        db = firebase.database()

        # create dictionary from post data
        data = {
            "name": request.form['name'],
            "colour": request.form['colour']
        }

        # if noteID is null, then create
        if (request.form['nodeID'] == 'null'):
            result = db.child("users").child(user['userId']).child("subjects").push(data, user['idToken'])
        else:
            # update timeslot data
            timeslots = db.child("users").child(user['userId']).child("timeslots").get(user['idToken'])

            # for each timeslot
            for i, (key, value) in enumerate(timeslots.val().items()):
                forDay = db.child("users").child(user['userId']).child("timeslots").child(key).get(user['idToken'])

                # if the day has timeslots
                if (forDay.val() != None):
                    # for each timeslot for that day
                    for j, (slotKey, slotValue) in enumerate(forDay.val().items()):

                        # if current timeslot subjec title is the same as the form's old subject title
                        if (slotValue['subjectTitle'] == request.form['oldTitle']):
                            #create new dictionary of timeslot data
                            newData = {
                                "subjectTitle": request.form['name'],
                                "colour": request.form['colour']
                            }

                            #update timeslot
                            db.child("users").child(user['userId']).child("timeslots").child(key).child(slotKey).update(newData, user['idToken'])

            #update subject data
            result = db.child("users").child(user['userId']).child("subjects").child(request.form['nodeID']).update(data, user['idToken'])
        # return refreshtoken if successful
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

        # get all timeslots
        timeslots = db.child("users").child(user['userId']).child("timeslots").get(user['idToken'])

        # for each timeslot
        for i, (key, value) in enumerate(timeslots.val().items()):
            forDay = db.child("users").child(user['userId']).child("timeslots").child(key).get(user['idToken'])

            # if the day has timeslots
            if (forDay.val() != None):
                # for each timeslot for that day
                for j, (slotKey, slotValue) in enumerate(forDay.val().items()):

                    # if current timeslot subjec title is the same as the form's old subject title
                    if (slotValue['subjectTitle'] == request.values['title']):
                        #delete timeslot node
                        db.child("users").child(user['userId']).child("timeslots").child(key).child(slotKey).remove(user['idToken'])

        #delete subject node
        result = db.child("users").child(user['userId']).child( "subjects").child(request.values['nodeID']).remove(user['idToken'])

        # return refresh token if successful
        return jsonify(refreshToken=user['refreshToken'])
    except requests.exceptions.HTTPError as e:
        new = str(e).replace("\n", '')
        parsedError = new[new.index("{"):]
        return jsonify(response=parsedError)

# route to get all subject
@app.route('/getSubjects', methods=['GET'])
def get_subjects():
    auth = firebase.auth()

    try:
        db = firebase.database()

        user = auth.refresh(request.args['refreshToken'])

        # get all subject nodes from the database
        results = db.child("users").child(user['userId']).child("subjects").get(user['idToken'])

        # return the subjects as a list
        return jsonify(subjects=results.val(), refreshToken=user['refreshToken'])
    except requests.exceptions.HTTPError as e:
        new = str(e).replace("\n", '')
        parsedError = new[new.index("{"):]
        return jsonify(response=parsedError)

# route to create or update tag
@app.route('/putTag', methods=['POST'])
def put_tag():
    auth = firebase.auth()

    try:
        user = auth.refresh(request.form['refreshToken'])

        db = firebase.database()

        #if nodeID is null, create tag
        if (request.form['nodeID'] == 'null'):
            result = db.child("users").child(user['userId']).child("tags").push(request.form['tag'], user['idToken'])
        #if updating tag
        else:
            # get all subjects
            subjects = db.child("users").child(user['userId']).child("subjects").get(user['idToken'])

            # for each subject
            for i, (key, value) in enumerate(subjects.val().items()): 
                # if journal
                if (key == "journal"):
                    if (value != None):
                        # for each data
                        for j, (dateKey, dateValue) in enumerate(value.items()):
                            # get all notes
                            notes = db.child("users").child(user['userId']).child("subjects").child(key).child(dateKey).child("notes").get(user['idToken'])

                            # if the journal date node has notes
                            if (notes.val() != None):
                                # for each note
                                for j, (noteKey, noteValue) in enumerate(notes.val().items()):
                                    withTag = db.child("users").child(user['userId']).child("subjects").child(key).child(dateKey).child("notes").child(noteKey).get(user['idToken'])

                                    # if note tag is the same as the form's old tag
                                    if (withTag.val()['tag'] == request.form['oldTag']):
                                        # update the note's tag with the new tag
                                        db.child("users").child(user['userId']).child("subjects").child(key).child(dateKey).child("notes").child(noteKey).child("tag").set(request.form['tag'], user['idToken'])

                            # get all files
                            files = db.child("users").child(user['userId']).child("subjects").child(key).child(dateKey).child("files").get(user['idToken'])

                            # if the journal date node has files
                            if (files.val() != None):
                                # for each file
                                for j, (fileKey, fileValue) in enumerate(files.val().items()):
                                    withTag = db.child("users").child(user['userId']).child("subjects").child(key).child(dateKey).child("files").child(fileKey).get(user['idToken'])

                                    # if file tag is the same as the form's old tag
                                    if (withTag.val()['tag'] == request.form['oldTag']):
                                        # update the file's tag with the new tag
                                        db.child("users").child(user['userId']).child("subjects").child(key).child(dateKey).child("files").child(fileKey).child("tag").set(request.form['tag'], user['idToken'])
                else:
                    # get all notes
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

        # return refresh token if successful
        return jsonify(refreshToken=user['refreshToken'])
    except requests.exceptions.HTTPError as e:
        new = str(e).replace("\n", '')
        parsedError = new[new.index("{"):]
        return jsonify(response=parsedError)

# route to delete a tag
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
            # if journal
            if (key == "journal"):
                if (value != None):
                    # for each journal date node
                    for j, (dateKey, dateValue) in enumerate(value.items()):
                        # get all notes
                        notes = db.child("users").child(user['userId']).child("subjects").child(key).child(dateKey).child("notes").get(user['idToken'])

                        if (notes.val() != None):
                            # for each note
                            for j, (noteKey, noteValue) in enumerate(notes.val().items()):
                                withTag = db.child("users").child(user['userId']).child("subjects").child(key).child(dateKey).child("notes").child(noteKey).get(user['idToken'])

                                # if note tag is the same as the form's old tag
                                if (withTag.val()['tag'] == request.values['tag']):
                                    # change note tag to be 'No Tag'
                                    db.child("users").child(user['userId']).child("subjects").child(key).child(dateKey).child("notes").child(noteKey).child("tag").set("No Tag", user['idToken'])

                        files = db.child("users").child(user['userId']).child("subjects").child(key).child(dateKey).child("files").get(user['idToken'])

                        # if the subject has files
                        if (files.val() != None):
                            for j, (fileKey, fileValue) in enumerate(files.val().items()):
                                withTag = db.child("users").child(user['userId']).child("subjects").child(key).child(dateKey).child("files").child(fileKey).get(user['idToken'])

                                # if file tag is the same as the form's old tag
                                if (withTag.val()['tag'] == request.values['tag']):
                                    # change file tag to be 'No Tag'
                                    db.child("users").child(user['userId']).child("subjects").child(key).child("files").child(fileKey).child("tag").set("No Tag", user['idToken'])   
            else:
                # get all notes for subject
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
                            # change file tag to be 'No Tag'
                            db.child("users").child(user['userId']).child("subjects").child(key).child("files").child(fileKey).child("tag").set("No Tag", user['idToken'])

        # delete the tag node
        result = db.child("users").child(user['userId']).child("tags").child(request.values['nodeID']).remove(user['idToken'])

        # return refresh token if successful
        return jsonify(refreshToken=user['refreshToken'])
    except requests.exceptions.HTTPError as e:
        new = str(e).replace("\n", '')
        parsedError = new[new.index("{"):]
        return jsonify(response=parsedError)

# route to get all user tags
@app.route('/getTags', methods=['GET'])
def get_tags():
    auth = firebase.auth()

    try:
        db = firebase.database()

        user = auth.refresh(request.args['refreshToken'])

        # get all tags from database for the specific user
        results = db.child("users").child(user['userId']).child("tags").get(user['idToken'])

        # return the tags as a list
        return jsonify(tags=results.val(), refreshToken=user['refreshToken'])
    except requests.exceptions.HTTPError as e:
        new = str(e).replace("\n", '')
        parsedError = new[new.index("{"):]
        return jsonify(response=parsedError)

# get all notes and files with a specific yag
@app.route('/getNotesAndFilesWithTag', methods=['GET'])
def get_notes_and_files_with_tag():
    auth = firebase.auth()

    try:
        user = auth.refresh(request.args['refreshToken'])

        db = firebase.database()

        # dictionary arrays
        notesWithTag = []
        filesWithTag = []

        # get all subjects
        subjects = db.child("users").child(user['userId']).child("subjects").get(user['idToken'])

        # for each subject
        for i, (key, value) in enumerate(subjects.val().items()):
            # if journal
            if (key == "journal"):
                if (value != None):
                    # for each date node
                    for j, (dateKey, dateValue) in enumerate(value.items()):
                        # get notes
                        notes = db.child("users").child(user['userId']).child("subjects").child(key).child(dateKey).child("notes").get(user['idToken'])

                        if (notes.val() != None):
                            # for each note
                            for j, (noteKey, noteValue) in enumerate(notes.val().items()):
                                withTag = db.child("users").child(user['userId']).child("subjects").child(key).child(dateKey).child("notes").child(noteKey).get(user['idToken'])

                                # if note tag is the same as the form's tag
                                if (withTag.val()['tag'].lower() == request.args['tag'].lower()):
                                    # append dictionary to note array
                                    notesWithTag.append({"note": {"key": noteKey, "values": withTag.val()}, "subject": {"key": key, "value": value}});

                        # get files
                        files = db.child("users").child(user['userId']).child("subjects").child(key).child(dateKey).child("files").get(user['idToken'])

                        # if the subject has files
                        if (files.val() != None):
                            # for each file
                            for j, (fileKey, fileValue) in enumerate(files.val().items()):
                                withTag = db.child("users").child(user['userId']).child("subjects").child(key).child("files").child(fileKey).get(user['idToken'])

                                # if file tag is the same as the form's tag
                                if (withTag.val()['tag'].lower() == request.args['tag'].lower()):
                                    # append dictionary to file array
                                    filesWithTag.append({"file": {"key": fileKey, "values": withTag.val()}, "subject": {"key": key, "value": value}});    
            else:
                # get notes
                notes = db.child("users").child(user['userId']).child("subjects").child(key).child("notes").get(user['idToken'])

                # if the subject has notes
                if (notes.val() != None):
                # for each note for that subject
                    for j, (noteKey, noteValue) in enumerate(notes.val().items()):
                        withTag = db.child("users").child(user['userId']).child("subjects").child(key).child("notes").child(noteKey).get(user['idToken'])

                        # if note tag is the same as the form's tag
                        if (withTag.val()['tag'].lower() == request.args['tag'].lower()):
                            # append dictionary to note array
                            notesWithTag.append({"note": {"key": noteKey, "values": withTag.val()}, "subject": {"key": key, "value": value}});

                # get files
                files = db.child("users").child(user['userId']).child("subjects").child(key).child("files").get(user['idToken'])

                # if the subject has files
                if (files.val() != None):
                # for each file for that subject
                    for j, (fileKey, fileValue) in enumerate(files.val().items()):
                        withTag = db.child("users").child(user['userId']).child("subjects").child(key).child("files").child(fileKey).get(user['idToken'])

                        # if file tag is the same as the form's tag
                        if (withTag.val()['tag'].lower() == request.args['tag'].lower()):
                            # append dictionary to file array
                            filesWithTag.append({"file": {"key": fileKey, "values": withTag.val()}, "subject": {"key": key, "value": value}});    

        # return refresh token if successful
        return jsonify(refreshToken=user['refreshToken'], files=filesWithTag, notes=notesWithTag)
    except requests.exceptions.HTTPError as e:
        new = str(e).replace("\n", '')
        parsedError = new[new.index("{"):]
        return jsonify(response=parsedError)

# route to get user's timetslots
@app.route('/getTimeslots', methods=['GET'])
def get_timeslots():
    auth = firebase.auth()

    try:
        db = firebase.database()

        user = auth.refresh(request.args['refreshToken'])

        # get all timeslots from database for the specific user
        results = db.child("users").child(user['userId']).child("timeslots").get(user['idToken'])

        # return the timeslots as a list
        return jsonify(timeslots=results.val(), refreshToken=user['refreshToken'])
    except requests.exceptions.HTTPError as e:
        new = str(e).replace("\n", '')
        parsedError = new[new.index("{"):]
        return jsonify(response=parsedError)

# route to create or update timeslot
@app.route('/putTimeslot', methods=['POST'])
def put_timeslot():
    auth = firebase.auth()

    try:
        user = auth.refresh(request.form['refreshToken'])

        db = firebase.database()

        # create dictionary from form data
        data = {
            "subjectTitle": request.form['subjectTitle'],
            "colour": request.form['colour'],
            "room": request.form['room'],
            "time": request.form['time'],
            "teacher": request.form['teacher']
        }

        # if nodeID is null. create timeslot
        if (request.form['nodeID'] == 'null'):
            result = db.child("users").child(user['userId']).child("timeslots").child(request.form['day']).push(data, user['idToken'])
        # else update timeslot
        else:
            result = db.child("users").child(user['userId']).child("timeslots").child(request.form['day']).child(request.form['nodeID']).update(data, user['idToken'])

        # return refresh token if successful
        return jsonify(refreshToken=user['refreshToken'])
    except requests.exceptions.HTTPError as e:
        new = str(e).replace("\n", '')
        parsedError = new[new.index("{"):]
        return jsonify(response=parsedError)

# route to delete timeslot
@app.route('/deleteTimeslot', methods=['DELETE'])
def delete_timeslot():
    auth = firebase.auth()

    try:
        user = auth.refresh(request.values['refreshToken'])

        db = firebase.database()

        # delete timeslot node
        result = db.child("users").child(user['userId']).child("timeslots").child(request.values['day']).child(request.values['nodeID']).remove(user['idToken'])

        # return refresh token if successful
        return jsonify(refreshToken=user['refreshToken'])
    except requests.exceptions.HTTPError as e:
        new = str(e).replace("\n", '')
        parsedError = new[new.index("{"):]
        return jsonify(response=parsedError)

# route to create or update user's test results
@app.route('/putTestResult', methods=['POST'])
def put_test_result():
    auth = firebase.auth()

    try:
        user = auth.refresh(request.form['refreshToken'])

        db = firebase.database()

        # create dictionary from form data
        data = {
            "title": request.form['title'],
            "score": request.form['score'],
        }

        # if nodeID is null. create test result
        if (request.form['nodeID'] == 'null'):
            result = db.child("users").child(user['userId']).child("subjects").child(request.form['subjectID']).child("results").push(data, user['idToken'])
        # else update timeslot
        else:
            result = db.child("users").child(user['userId']).child("subjects").child(request.form['subjectID']).child("results").child(request.form['nodeID']).set(data, user['idToken'])

        # return refresh token if successful
        return jsonify(refreshToken=user['refreshToken'])
    except requests.exceptions.HTTPError as e:
        new = str(e).replace("\n", '')
        parsedError = new[new.index("{"):]
        return jsonify(response=parsedError)

# route to get user's test results
@app.route('/getTestResults', methods=['GET'])
def get_test_results():
    auth = firebase.auth()

    try:
        db = firebase.database()

        user = auth.refresh(request.args['refreshToken'])

        # get all test results from database for the specific user
        results = db.child("users").child(user['userId']).child("subjects").child(request.args['subjectID']).child("results").get(user['idToken'])

        # return the test results as a list
        return jsonify(results=results.val(), refreshToken=user['refreshToken'])
    except requests.exceptions.HTTPError as e:
        new = str(e).replace("\n", '')
        parsedError = new[new.index("{"):]
        return jsonify(response=parsedError)

 # route to delete a test result
@app.route('/deleteTestResult', methods=['DELETE'])
def delete_test_result():
    auth = firebase.auth()

    try:
        user = auth.refresh(request.values['refreshToken'])

        db = firebase.database()

        # delete test result node
        result = db.child("users").child(user['userId']).child("subjects").child(request.values['subjectID']).child("results").child(request.values['nodeID']).remove(user['idToken'])

        # return refresh token if successful
        return jsonify(refreshToken=user['refreshToken'])
    except requests.exceptions.HTTPError as e:
        new = str(e).replace("\n", '')
        parsedError = new[new.index("{"):]
        return jsonify(response=parsedError)

# route to create or update reminders
@app.route('/putNotification', methods=['POST'])
def put_notification():
    auth = firebase.auth()

    try:
        user = auth.refresh(request.form['refreshToken'])

        db = firebase.database()

        # create dictionary from form data
        data = {
            "description": request.form['description'],
            "time": request.form['time'],
        }

        # create or update reminder node (unlike other features, notifications have their nodes generated on the front end)
        result = db.child("users").child(user['userId']).child("notifications").child(request.form['nodeID']).set(data, user['idToken'])

        # return refresh token if successful
        return jsonify(refreshToken=user['refreshToken'])
    except requests.exceptions.HTTPError as e:
        new = str(e).replace("\n", '')
        parsedError = new[new.index("{"):]
        return jsonify(response=parsedError)

# route to get reminders
@app.route('/getNotifications', methods=['GET'])
def get_notifications():
    auth = firebase.auth()

    try:
        db = firebase.database()

        user = auth.refresh(request.args['refreshToken'])

        # get all reminders from database for the specific user
        results = db.child("users").child(user['userId']).child("notifications").get(user['idToken'])

        # return the reminders as a list
        return jsonify(notifications=results.val(), refreshToken=user['refreshToken'])
    except requests.exceptions.HTTPError as e:
        new = str(e).replace("\n", '')
        parsedError = new[new.index("{"):]
        return jsonify(response=parsedError)

 # route to delete a reminder
@app.route('/deleteNotification', methods=['DELETE'])
def delete_notification():
    auth = firebase.auth()

    try:
        user = auth.refresh(request.values['refreshToken'])

        db = firebase.database()

        # delete reminder node
        result = db.child("users").child(user['userId']).child("notifications").child(request.values['nodeID']).remove(user['idToken'])

        # return refresh token if successful
        return jsonify(refreshToken=user['refreshToken'])
    except requests.exceptions.HTTPError as e:
        new = str(e).replace("\n", '')
        parsedError = new[new.index("{"):]
        return jsonify(response=parsedError)

# route to create or update homework node
@app.route('/putHomework', methods=['POST'])
def put_homework():
    auth = firebase.auth()

    try:
        user = auth.refresh(request.form['refreshToken'])

        db = firebase.database()

        # create dictionary from form data
        data = {
            "description": request.form['description'],
            "isCompleted": request.form['isCompleted'],
        }

        # if nodeID is null, create homework node
        if (request.form['nodeID'] == 'null'):
            result = db.child("users").child(user['userId']).child("subjects").child(request.form['subjectID']).child("homework").push(data, user['idToken'])
        # else update homework node
        else:
            result = db.child("users").child(user['userId']).child("subjects").child(request.form['subjectID']).child("homework").child(request.form['nodeID']).set(data, user['idToken'])

        # return refresh token if successful
        return jsonify(refreshToken=user['refreshToken'])
    except requests.exceptions.HTTPError as e:
        new = str(e).replace("\n", '')
        parsedError = new[new.index("{"):]
        return jsonify(response=parsedError)

# route to get all of a user's homework
@app.route('/getHomework', methods=['GET'])
def get_homework():
    auth = firebase.auth()

    try:
        db = firebase.database()

        user = auth.refresh(request.args['refreshToken'])

        # get all homework nodes from database for the specific user
        results = db.child("users").child(user['userId']).child("subjects").child(request.args['subjectID']).child("homework").get(user['idToken'])

        # return the homework nodes as a list
        return jsonify(homework=results.val(), refreshToken=user['refreshToken'])
    except requests.exceptions.HTTPError as e:
        new = str(e).replace("\n", '')
        parsedError = new[new.index("{"):]
        return jsonify(response=parsedError)

 # route to delete a homework node
@app.route('/deleteHomework', methods=['DELETE'])
def delete_homework():
    auth = firebase.auth()

    try:
        user = auth.refresh(request.values['refreshToken'])

        db = firebase.database()

        # delete homework node
        result = db.child("users").child(user['userId']).child("subjects").child(request.values['subjectID']).child("homework").child(request.values['nodeID']).remove(user['idToken'])

        # return refresh token if successful
        return jsonify(refreshToken=user['refreshToken'])
    except requests.exceptions.HTTPError as e:
        new = str(e).replace("\n", '')
        parsedError = new[new.index("{"):]
        return jsonify(response=parsedError)

# create or update a user's material
@app.route('/putMaterial', methods=['POST'])
def put_material():
    auth = firebase.auth()

    try:
        user = auth.refresh(request.form['refreshToken'])

        storage = firebase.storage()
        db = firebase.database()

        # dictionary for material data
        data = {}

        # if file present in form data
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

        # if nodeID is null, create materials
        if (request.form['nodeID'] == 'null'):
            addUrl = db.child("users").child(user['userId']).child("subjects").child(request.form['subjectID']).child("materials").push(data, user['idToken'])
        # if file is null, 
        elif (request.form.get('file') == 'null'):
            # just update the name of the material
            addUrl = db.child("users").child(user['userId']).child("subjects").child(request.form['subjectID']).child("materials").child(request.form['nodeID']).set(data, user['idToken'])
        # else update all material data
        else:
            # if file has changed
            if (request.form['previousFile'] != 'null'):
                # delete old file on storage
                storage.delete("users/"+user['userId']+"/"+request.form['subjectID']+"/materials/"+request.form['previousFile'])

            addUrl = db.child("users").child(user['userId']).child("subjects").child(request.form['subjectID']).child("materials").child(request.form['nodeID']).set(data, user['idToken'])

        # return refresh token if successful
        return jsonify(refreshToken=user['refreshToken'])
    except requests.exceptions.HTTPError as e:
        new = str(e).replace("\n", '')
        parsedError = new[new.index("{"):]
        return jsonify(response=parsedError)

# get user's materials
@app.route('/getMaterials', methods=['GET'])
def get_materials():
    auth = firebase.auth()

    try:
        user = auth.refresh(request.args['refreshToken'])

        storage = firebase.storage()
        db = firebase.database()

        # get all materials from database for the specific user
        results = db.child("users").child(user['userId']).child("subjects").child(request.args['subjectID']).child("materials").get(user['idToken'])

        # return the materials as a list
        return jsonify(materials=results.val(), refreshToken=user['refreshToken'])
    except requests.exceptions.HTTPError as e:
        new = str(e).replace("\n", '')
        parsedError = new[new.index("{"):]
        return jsonify(response=parsedError)

# route to delete material
@app.route('/deleteMaterial', methods=['DELETE'])
def delete_material():
    auth = firebase.auth()

    try:
        user = auth.refresh(request.values['refreshToken'])

        storage = firebase.storage()
        db = firebase.database()

        # if form file name is not null
        if(request.values['fileName'] != 'null'):
            # delete the file on storage
            storage.delete("users/"+user['userId']+"/"+request.values['subjectID']+"/materials/"+request.values['fileName'])

        # delete material node
        result = db.child("users").child(user['userId']).child("subjects").child(request.values['subjectID']).child("materials").child(request.values['nodeID']).remove(user['idToken'])

        # return refresh token if successful
        return jsonify(refreshToken=user['refreshToken'])
    except requests.exceptions.HTTPError as e:
        new = str(e).replace("\n", '')
        parsedError = new[new.index("{"):]
        return jsonify(response=parsedError)

# run app
if __name__ == '__main__':
    app.run(debug=True)
