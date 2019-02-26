import 'dart:io';
import 'package:flutter/material.dart';
import 'package:my_school_life_prototype/athena_icon_data.dart';
import 'package:my_school_life_prototype/class_material.dart';
import 'package:my_school_life_prototype/font_data.dart';
import 'package:my_school_life_prototype/homework.dart';
import 'package:my_school_life_prototype/test_result.dart';
import 'package:my_school_life_prototype/timetable_slot.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'note.dart';
import 'subject.dart';
import 'subject_file.dart';
import 'tag.dart';

class RequestManager
{

  static final url = "https://moonlit-caster-232518.appspot.com";
  static final RequestManager singleton = new RequestManager._internal();

  factory RequestManager() {
    return singleton;
  }

  RequestManager._internal();

  final String uploadFileUrl = url+"/putFile";
  final String deleteFileUrl = url+"/deleteFile";
  final String getFilesUrl = url+"/getFiles";
  final String commandUrl = url+"/command";
  final String putFontUrl = url+"/putFontData";
  final String getFontUrl = url+"/getFontData";
  final String loginUrl = url+"/signin";
  final String registerUrl = url+"/register";
  final String uploadNoteURL = url+"/putNote";
  final String deleteNoteURL = url+"/deleteNote";
  final String getNotesURL = url+"/getNotes";
  final String addSubjectURL = url+"/putSubject";
  final String deleteSubjectURL = url+"/deleteSubject";
  final String getSubjectsURL = url+"/getSubjects";
  final String addTagURL = url+"/putTag";
  final String deleteTagURL = url+"/deleteTag";
  final String getTagsURL = url+"/getTags";
  final String putTagOnNoteURL = url+"/putTagOnNote";
  final String getTagForNoteURL = url+"/getTagForNote";
  final String putTagOnFileURL = url+"/putTagOnFile";
  final String getNotesAndFilesWithTagURL = url+"/getNotesAndFilesWithTag";
  final String getTimeslotsURL = url+"/getTimeslots";
  final String putTimeslotURL = url+"/putTimeslot";
  final String deleteTimeslotURL = url+"/deleteTimeslot";
  final String putTestResultURL = url+"/putTestResult";
  final String getTestResultsURL = url+"/getTestResults";
  final String deleteTestResultURL = url+"/deleteTestResult";
  final String putHomeworkURL = url+"/putHomework";
  final String getHomeworkURL = url+"/getHomework";
  final String deleteHomeworkURL = url+"/deleteHomework";
  final String putMaterialURL = url+"/putMaterial";
  final String getMaterialsURL = url+"/getMaterials";
  final String deleteMaterialURL = url+"/deleteMaterial";
  final String putIconUrl = url+"/putIconData";
  final String getIconUrl = url+"/getIconData";

  Dio dio = new Dio();

  Future<List<SubjectFile>> getFiles(String subjectID) async
  {
    List<SubjectFile> reqFiles = new List<SubjectFile>();
    SharedPreferences prefs = await SharedPreferences.getInstance();

    //get user images
    Response response = await dio.get(getFilesUrl, data: {"id": await prefs.getString("id"), "refreshToken": await prefs.getString("refreshToken"), "subjectID": subjectID});

    //store files in a SubjectFile list
    if (response.data['files']?.values != null) {

      response.data['files'].forEach((key, values) {
        SubjectFile s = new SubjectFile(key, values['url'], values['fileName'], values['tag']);
        reqFiles.add(s);
      });
    }

    return reqFiles;
  }

  //method for uploading user chosen image
  Future<SubjectFile> uploadFile(String filePath, String subjectID, BuildContext context) async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    //create form with relevant data and image as file
    FormData formData = new FormData.from({
      "id": await prefs.getString("id"),
      "subjectID": subjectID,
      "refreshToken": await prefs.getString("refreshToken"),
      "file": new UploadFileInfo(new File(filePath), new DateTime.now().millisecondsSinceEpoch.toString()+filePath.split('/').last)
    });

    try {
      //post the form data to the url
      var responseObj = await dio.post(uploadFileUrl, data: formData);

      //if the refresh token is null, then display an alert dialog with an error
      if(responseObj.data['refreshToken'] == null) {
        return new SubjectFile("error", "error", "error", "error");
      }
      else {
        //else store the new refresh token in shared preferences and return the image URL
        await prefs.setString("refreshToken", responseObj.data['refreshToken']);
        return new SubjectFile(responseObj.data['key'], responseObj.data['url'], responseObj.data['fileName'], "No Tag");
      }
    }
    on DioError catch(e)
    {
      return new SubjectFile("error", "error", "error", "error");
    }
  }

  dynamic deleteFile(String id, String subjectID, String fileName) async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    FormData formData = new FormData.from({
      "id": await prefs.getString("id"),
      "nodeID": id,
      "subjectID": subjectID,
      "fileName": fileName,
      "refreshToken": await prefs.getString("refreshToken"),
    });

    try {
      //post the request and retrieve the response data
      var responseObj = await dio.post(deleteFileUrl, data: formData);

      //if the refresh token is null, then print the error in the logs and show an error dialog
      if(responseObj.data['refreshToken'] == null) {
        return "error";
      }
      else {
        await prefs.setString("refreshToken", responseObj.data['refreshToken']);
        return "success";
      }
    }
    //catch error and display error doalog
    on DioError catch(e)
    {
      return "error";
    }
  }

  //method to submit the new font
  Future<String> putFontData(FontData fontData) async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    //create form data for the request, with the new font
    FormData formData = new FormData.from({
      "id": await prefs.getString("id"),
      "refreshToken": await prefs.getString("refreshToken"),
      "font": fontData.font,
      "fontColour": fontData.color.value,
      "fontSize": double.tryParse(fontData.size.toStringAsFixed(1))
    });

    try {
      //post the request and retrieve the response data
      var responseObj = await dio.post(putFontUrl, data: formData);

      //if the refresh token is null, then print the error in the logs and show an error dialog
      if(responseObj.data['refreshToken'] == null) {
        return "error";
      }
      //else store the new refresh token and font in shared preferences, and display snackbar the font has been updated
      else {
        await prefs.setString("refreshToken", responseObj.data['refreshToken']);
        await prefs.setString("font", fontData.font);
        await prefs.setInt("fontColour", fontData.color.value);
        await prefs.setDouble("fontSize", fontData.size);
        return "success";
      }
    }
    //catch error and display error doalog
    on DioError catch(e)
    {
      return "error";
    }
  }

  Future<FontData> getFontData() async
  {
    FontData data;
    SharedPreferences prefs = await SharedPreferences.getInstance();

    //get user images
    Response response = await dio.get(getFontUrl, data: {"id": await prefs.getString("id"), "refreshToken": await prefs.getString("refreshToken")});

    //store images in a string list
    if (response.data['data']?.values != null) {

      final values = response.data['data'];

      data = new FontData(
          values['font'],
          Color(int.tryParse(values['fontColour'])),
          double.tryParse(values['fontSize'])
      );
    }else{
      data = new FontData(
        "", Colors.black, 24.0
      );
    }

    await prefs.setString("font", data.font);
    await prefs.setInt("fontColour", data.color.value);
    await prefs.setDouble("fontSize", data.size);

    return data;
  }

  //method to submit the new font
  Future<String> putIconData(AthenaIconData iconData) async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    //create form data for the request, with the new font
    FormData formData = new FormData.from({
      "id": await prefs.getString("id"),
      "refreshToken": await prefs.getString("refreshToken"),
      "iconColour": iconData.color.value,
      "iconSize": double.tryParse(iconData.size.toStringAsFixed(1))
    });

    try {
      //post the request and retrieve the response data
      var responseObj = await dio.post(putIconUrl, data: formData);

      //if the refresh token is null, then print the error in the logs and show an error dialog
      if(responseObj.data['refreshToken'] == null) {
        return "error";
      }
      //else store the new refresh token and font in shared preferences, and display snackbar the font has been updated
      else {
        await prefs.setString("refreshToken", responseObj.data['refreshToken']);
        await prefs.setInt("iconColour", iconData.color.value);
        await prefs.setDouble("iconSize", iconData.size);
        return "success";
      }
    }
    //catch error and display error doalog
    on DioError catch(e)
    {
      return "error";
    }
  }

  Future<AthenaIconData> getIconData() async
  {
    AthenaIconData data;
    SharedPreferences prefs = await SharedPreferences.getInstance();

    //get user images
    Response response = await dio.get(getIconUrl, data: {"id": await prefs.getString("id"), "refreshToken": await prefs.getString("refreshToken")});

    //store images in a string list
    if (response.data['data']?.values != null) {

      final values = response.data['data'];

      data = new AthenaIconData(
          Color(int.tryParse(values['iconColour'])),
          double.tryParse(values['iconSize'])
      );
    }else{
      data = new AthenaIconData(
          Colors.black, 24.0
      );
    }

    await prefs.setInt("iconColour", data.color.value);
    await prefs.setDouble("iconSize", data.size);

    return data;
  }

  dynamic putSubject(Map jsonMap) async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    FormData formData = new FormData.from({
      "id": await prefs.getString("id"),
      "nodeID": jsonMap['id'],
      "refreshToken": await prefs.getString("refreshToken"),
      "name": jsonMap['name'],
      "colour": jsonMap['colour'],
      "oldTitle": jsonMap['oldTitle'],
    });

    try {
      //post the request and retrieve the response data
      var responseObj = await dio.post(addSubjectURL, data: formData);

      //if the refresh token is null, then print the error in the logs and show an error dialog
      if(responseObj.data['refreshToken'] == null) {
        return "error";
      }
      else {
        await prefs.setString("refreshToken", responseObj.data['refreshToken']);
        return "success";
      }
    }
    //catch error and display error doalog
    on DioError catch(e)
    {
      return "error";
    }
  }

  dynamic deleteSubject(String id, String title) async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    FormData formData = new FormData.from({
      "id": await prefs.getString("id"),
      "nodeID": id,
      "title": title,
      "refreshToken": await prefs.getString("refreshToken"),
    });

    try {
      //post the request and retrieve the response data
      var responseObj = await dio.post(deleteSubjectURL, data: formData);

      //if the refresh token is null, then print the error in the logs and show an error dialog
      if(responseObj.data['refreshToken'] == null) {
        return "error";
      }
      else {
        await prefs.setString("refreshToken", responseObj.data['refreshToken']);
        return "success";
      }
    }
    //catch error and display error doalog
    on DioError catch(e)
    {
      return "error";
    }
  }

  Future<List<Subject>> getSubjects() async
  {
    List<Subject> reqSubjects = new List<Subject>();
    SharedPreferences prefs = await SharedPreferences.getInstance();

    //get user images
    Response response = await dio.get(getSubjectsURL, data: {"id": await prefs.getString("id"), "refreshToken": await prefs.getString("refreshToken")});

    //store images in a string list
    if (response.data['subjects']?.values != null) {

      response.data['subjects'].forEach((key, values) {
        Subject s = new Subject(key, values['name'], values['colour']);
        reqSubjects.add(s);
      });
    }

    return reqSubjects;
  }

  dynamic putTag(Map jsonMap) async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    FormData formData = new FormData.from({
      "id": await prefs.getString("id"),
      "nodeID": jsonMap['id'],
      "refreshToken": await prefs.getString("refreshToken"),
      "tag": jsonMap['tag'],
      "oldTag": jsonMap['oldTag']
    });

    try {
      //post the request and retrieve the response data
      var responseObj = await dio.post(addTagURL, data: formData);

      //if the refresh token is null, then print the error in the logs and show an error dialog
      if(responseObj.data['refreshToken'] == null) {
        return "error";
      }
      else {
        await prefs.setString("refreshToken", responseObj.data['refreshToken']);
        return "success";
      }
    }
    //catch error and display error doalog
    on DioError catch(e)
    {
      return "error";
    }
  }

  dynamic deleteTag(Tag tag) async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    FormData formData = new FormData.from({
      "id": await prefs.getString("id"),
      "nodeID": tag.id,
      "tag": tag.tag,
      "refreshToken": await prefs.getString("refreshToken"),
    });

    try {
      //post the request and retrieve the response data
      var responseObj = await dio.post(deleteTagURL, data: formData);

      //if the refresh token is null, then print the error in the logs and show an error dialog
      if(responseObj.data['refreshToken'] == null) {
        return "error";
      }
      else {
        await prefs.setString("refreshToken", responseObj.data['refreshToken']);
        return "success";
      }
    }
    //catch error and display error doalog
    on DioError catch(e)
    {
      return "error";
    }
  }

  Future<List<Tag>> getTags() async
  {
    List<Tag> reqTags = new List<Tag>();
    SharedPreferences prefs = await SharedPreferences.getInstance();

    //get user images
    Response response = await dio.get(getTagsURL, data: {"id": await prefs.getString("id"), "refreshToken": await prefs.getString("refreshToken")});

    //store images in a string list
    if (response.data['tags']?.values != null) {

      response.data['tags'].forEach((key, values) {
        Tag t = new Tag(key, values);
        reqTags.add(t);
      });
    }

    return reqTags;
  }

  Future<List> getNotesAndFilesByTag(String tag) async
  {
    Map<Subject, Note> notes = new Map<Subject, Note>();
    Map<Subject, SubjectFile> files = new Map<Subject, SubjectFile>();

    SharedPreferences prefs = await SharedPreferences.getInstance();

    //get user images
    Response response = await dio.get(getNotesAndFilesWithTagURL, data: {"id": await prefs.getString("id"), "refreshToken": await prefs.getString("refreshToken"), "tag": tag});

    //print(response.data['notes']);

    //store notes in a note map
    if (response.data['notes'] != null) {

      //for each note
      response.data['notes'].forEach((note) {
        Note n = new Note(note['note']['key'], note['note']['values']['fileName'], note['note']['values']['delta'], note['note']['values']['tag']);
        Subject s = new Subject(note['subject']['key'], note['subject']['value']['name'], note['subject']['value']['colour']);

        notes.putIfAbsent(s, () => n);
      });
    }

    //store files in a file map
    if (response.data['files'] != null) {

      //for each file
      response.data['files'].forEach((file) {
        SubjectFile sf = new SubjectFile(file['file']['key'], file['file']['values']['url'], file['file']['values']['fileName'], file['file']['values']['tag']);
        Subject s = new Subject(file['subject']['key'], file['subject']['value']['name'], file['subject']['value']['colour']);

        files.putIfAbsent(s, () => sf);
      });
    }

    return [notes, files];
  }

  dynamic putNote(Map jsonMap) async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    //create form data for the request, with the new note
    FormData formData = new FormData.from({
      "id": await prefs.getString("id"),
      "nodeID": jsonMap['id'],
      "subjectID": jsonMap['subjectID'],
      "refreshToken": await prefs.getString("refreshToken"),
      "fileName": jsonMap['fileName'],
      "delta": jsonMap['delta'],
      "tag": jsonMap['tag'],
    });

    try {
      //post the request and retrieve the response data
      var responseObj = await dio.post(uploadNoteURL, data: formData);

      //if the refresh token is null, then print the error in the logs and show an error dialog
      if(responseObj.data['refreshToken'] == null) {
        return "error";
      }
      //else store the new refresh token and note in shared preferences, and display snackbar the note has been updated
      else {
        await prefs.setString("refreshToken", responseObj.data['refreshToken']);
        return "success";
      }
    }
    //catch error and display error doalog
    on DioError catch(e)
    {
      return "error";
    }
  }

  dynamic putTagOnNote(Map jsonMap) async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    FormData formData = new FormData.from({
      "id": await prefs.getString("id"),
      "nodeID": jsonMap['id'],
      "subjectID": jsonMap['subjectID'],
      "tag": jsonMap['tag'],
      "refreshToken": await prefs.getString("refreshToken"),
    });

    try {
      //post the request and retrieve the response data
      var responseObj = await dio.post(putTagOnNoteURL, data: formData);

      //if the refresh token is null, then print the error in the logs and show an error dialog
      if(responseObj.data['refreshToken'] == null) {
        return "error";
      }
      else {
        await prefs.setString("refreshToken", responseObj.data['refreshToken']);
        return "success";
      }
    }
    //catch error and display error doalog
    on DioError catch(e)
    {
      return "error";
    }
  }

  dynamic putTagOnFile(Map jsonMap) async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    FormData formData = new FormData.from({
      "id": await prefs.getString("id"),
      "nodeID": jsonMap['id'],
      "subjectID": jsonMap['subjectID'],
      "tag": jsonMap['tag'],
      "refreshToken": await prefs.getString("refreshToken"),
    });

    print(formData);

    try {
      //post the request and retrieve the response data
      var responseObj = await dio.post(putTagOnFileURL, data: formData);

      //if the refresh token is null, then print the error in the logs and show an error dialog
      if(responseObj.data['refreshToken'] == null) {
        return "error";
      }
      else {
        await prefs.setString("refreshToken", responseObj.data['refreshToken']);
        return "success";
      }
    }
    //catch error and display error doalog
    on DioError catch(e)
    {
      return "error";
    }
  }

  Future<String> getTagForNote(Map jsonMap) async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    try {
      //post the request and retrieve the response data
      Response response = await dio.get(getTagForNoteURL, data: {
        "id": await prefs.getString("id"),
        "nodeID": jsonMap['id'],
        "subjectID": jsonMap['subjectID'],
        "refreshToken": await prefs.getString("refreshToken"),
      });

      //if the refresh token is null, then print the error in the logs and show an error dialog
      if(response.data['refreshToken'] == null) {
        return "error";
      }
      else {
        await prefs.setString("refreshToken", response.data['refreshToken']);

        if (response.data['tag'] != null) {
          return response.data['tag'];
        }
      }
    }
    //catch error and display error doalog
    on DioError catch(e)
    {
      print(e.message);
      return "error";
    }
  }

  dynamic deleteNote(String id, String subjectID) async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    FormData formData = new FormData.from({
      "id": await prefs.getString("id"),
      "nodeID": id,
      "subjectID": subjectID,
      "refreshToken": await prefs.getString("refreshToken"),
    });

    try {
      //post the request and retrieve the response data
      var responseObj = await dio.post(deleteNoteURL, data: formData);

      //if the refresh token is null, then print the error in the logs and show an error dialog
      if(responseObj.data['refreshToken'] == null) {
        return "error";
      }
      else {
        await prefs.setString("refreshToken", responseObj.data['refreshToken']);
        return "success";
      }
    }
    //catch error and display error doalog
    on DioError catch(e)
    {
      return "error";
    }
  }

  Future<List<Note>> getNotes(String subjectID) async
  {
    List<Note> reqNotes = new List<Note>();
    SharedPreferences prefs = await SharedPreferences.getInstance();

    //get user notes
    Response response = await dio.get(getNotesURL, data: {"id": await prefs.getString("id"), "refreshToken": await prefs.getString("refreshToken"), "subjectID": subjectID});

    //store images in a string list
    if (response.data['notes']?.values != null) {

      response.data['notes'].forEach((key, values) {
        Note n = new Note(key, values['fileName'], values['delta'], values['tag']);
        reqNotes.add(n);
      });
    }

    return reqNotes;
  }

  dynamic command(String uri, BuildContext context) async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    //create file object from audio URI
    File file = new File.fromUri(new Uri.file(uri));

    //post the form data with the audio file
    FormData formData = new FormData.from({
      "id": await prefs.getString("id"),
      "refreshToken": await prefs.getString("refreshToken"),
      "file": new UploadFileInfo(file, uri),
    });

    var responseObj;

    try
    {
      //post the form data and retrieve the response
      responseObj = await dio.post(commandUrl, data: formData);

      //delete the audio file
      File currentAudio = File.fromUri(new Uri.file(uri));
      currentAudio.deleteSync();

      //if the function is null then set the state of the application that recording has stopped
      if(responseObj.data['function'] == null) {
        return "error";
      }
      else {
        await prefs.setString("refreshToken", responseObj.data['refreshToken']);
        return responseObj;
      }
    }
    on DioError catch(e)
    {
      return "error";
    }
  }

  dynamic signInRequest(Map jsonMap) async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    FormData formData = new FormData.from({
      "id": await prefs.getString("id"),
      "refreshToken": await prefs.getString("refreshToken"),
      "email": jsonMap['email'],
      "password": jsonMap['password']
    });

    try {
      //post the request and retrieve the response data
      var responseObj =  await dio.post(loginUrl, data: formData);

      if (responseObj.data['message'] == null) {
        return {"error": responseObj.data};
      }
      else {
        return {"Success": responseObj.data};
      }
    }
    //catch error and display error doalog
    on DioError catch(e)
    {
      return {"error": {"response": "An Error Has Occured, Please Try Again!"}};
    }
  }

  dynamic register(Map jsonMap) async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    FormData formData = new FormData.from({
      "refreshToken": await prefs.getString("refreshToken"),
      "email": jsonMap['email'],
      "password": jsonMap['password'],
      "firstName": jsonMap['firstName'],
      "secondName": jsonMap['secondName'],
    });

    try {
      //post the request and retrieve the response data
      var responseObj =  await dio.post(registerUrl, data: formData);

      if (responseObj.data['message'] == null) {
        return {"error": responseObj.data};
      }
      else {
        return {"Success": responseObj.data};
      }
    }
    //catch error and display error doalog
    on DioError catch(e)
    {
      return {"error": {"response": "An Error Has Occured, Please Try Again!"}};
    }
  }

  Future<Map<String, List<TimetableSlot>>> getTimeslots() async
  {
    Map<String, List<TimetableSlot>> reqTimeslots = new Map<String, List<TimetableSlot>>();
    SharedPreferences prefs = await SharedPreferences.getInstance();

    //get user images
    Response response = await dio.get(getTimeslotsURL, data: {"id": await prefs.getString("id"), "refreshToken": await prefs.getString("refreshToken")});

    //store images in a string list
    if (response.data['timeslots']?.values != null) {

      response.data['timeslots'].forEach((key, values) {

        List<TimetableSlot> timeslots = new List<TimetableSlot>();

        values.forEach((slotKey, slotValues) {

          timeslots.add(new TimetableSlot(slotKey, slotValues['subjectTitle'], slotValues['colour'], slotValues['time'], slotValues['teacher'], slotValues['room']));

        });

        reqTimeslots.putIfAbsent(key, () => timeslots);

      });
    }

    return reqTimeslots;
  }

  dynamic putTimeslot(Map jsonMap) async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    FormData formData = new FormData.from({
      "id": await prefs.getString("id"),
      "nodeID": jsonMap['id'],
      "refreshToken": await prefs.getString("refreshToken"),
      "day": jsonMap['day'],
      "subjectTitle": jsonMap['subjectTitle'],
      "room": jsonMap['room'],
      "time": jsonMap['time'],
      "teacher": jsonMap['teacher'],
      "colour": jsonMap['colour'],
    });

    try {
      //post the request and retrieve the response data
      var responseObj = await dio.post(putTimeslotURL, data: formData);

      //if the refresh token is null, then print the error in the logs and show an error dialog
      if(responseObj.data['refreshToken'] == null) {
        return "error";
      }
      else {
        await prefs.setString("refreshToken", responseObj.data['refreshToken']);
        return "success";
      }
    }
    //catch error and display error doalog
    on DioError catch(e)
    {
      return "error";
    }
  }

  dynamic deleteTimeslot(String id, String day) async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    FormData formData = new FormData.from({
      "id": await prefs.getString("id"),
      "nodeID": id,
      "day": day,
      "refreshToken": await prefs.getString("refreshToken"),
    });

    try {
      //post the request and retrieve the response data
      var responseObj = await dio.post(deleteTimeslotURL, data: formData);

      //if the refresh token is null, then print the error in the logs and show an error dialog
      if(responseObj.data['refreshToken'] == null) {
        return "error";
      }
      else {
        await prefs.setString("refreshToken", responseObj.data['refreshToken']);
        return "success";
      }
    }
    //catch error and display error doalog
    on DioError catch(e)
    {
      return "error";
    }
  }

  dynamic putTestResult(Map jsonMap) async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    FormData formData = new FormData.from({
      "id": await prefs.getString("id"),
      "nodeID": jsonMap['id'],
      "subjectID": jsonMap['subjectID'],
      "refreshToken": await prefs.getString("refreshToken"),
      "title": jsonMap['title'],
      "score": jsonMap['score'],
    });

    try {
      //post the request and retrieve the response data
      var responseObj = await dio.post(putTestResultURL, data: formData);

      //if the refresh token is null, then print the error in the logs and show an error dialog
      if(responseObj.data['refreshToken'] == null) {
        return "error";
      }
      else {
        await prefs.setString("refreshToken", responseObj.data['refreshToken']);
        return "success";
      }
    }
    //catch error and display error doalog
    on DioError catch(e)
    {
      return "error";
    }
  }

  Future<List<TestResult>> getTestResults(String subjectID) async
  {
    List<TestResult> reqResults = new List<TestResult>();
    SharedPreferences prefs = await SharedPreferences.getInstance();

    //get user notes
    Response response = await dio.get(getTestResultsURL, data: {"id": await prefs.getString("id"), "refreshToken": await prefs.getString("refreshToken"), "subjectID": subjectID});

    //store images in a string list
    if (response.data['results']?.values != null) {

      response.data['results'].forEach((key, values) {
        TestResult r = TestResult(key, values['title'], double.tryParse(values['score']));
        reqResults.add(r);
      });
    }

    return reqResults;
  }

  dynamic deleteTestResult(String id, String subjectID) async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    FormData formData = new FormData.from({
      "id": await prefs.getString("id"),
      "nodeID": id,
      "subjectID": subjectID,
      "refreshToken": await prefs.getString("refreshToken"),
    });

    try {
      //post the request and retrieve the response data
      var responseObj = await dio.post(deleteTestResultURL, data: formData);

      //if the refresh token is null, then print the error in the logs and show an error dialog
      if(responseObj.data['refreshToken'] == null) {
        return "error";
      }
      else {
        await prefs.setString("refreshToken", responseObj.data['refreshToken']);
        return "success";
      }
    }
    //catch error and display error doalog
    on DioError catch(e)
    {
      return "error";
    }
  }

  dynamic putHomework(Map jsonMap) async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    FormData formData = new FormData.from({
      "id": await prefs.getString("id"),
      "nodeID": jsonMap['id'],
      "subjectID": jsonMap['subjectID'],
      "refreshToken": await prefs.getString("refreshToken"),
      "description": jsonMap['description'],
      "isCompleted": jsonMap['isCompleted'],
    });

    try {
      //post the request and retrieve the response data
      var responseObj = await dio.post(putHomeworkURL, data: formData);

      //if the refresh token is null, then print the error in the logs and show an error dialog
      if(responseObj.data['refreshToken'] == null) {
        return "error";
      }
      else {
        await prefs.setString("refreshToken", responseObj.data['refreshToken']);
        return "success";
      }
    }
    //catch error and display error doalog
    on DioError catch(e)
    {
      return "error";
    }
  }

  Future<List<Homework>> getHomework(String subjectID) async
  {
    List<Homework> reqHomework = new List<Homework>();
    SharedPreferences prefs = await SharedPreferences.getInstance();

    //get user notes
    Response response = await dio.get(getHomeworkURL, data: {"id": await prefs.getString("id"), "refreshToken": await prefs.getString("refreshToken"), "subjectID": subjectID});

    //store images in a string list
    if (response.data['homework']?.values != null) {

      response.data['homework'].forEach((key, values) {
        Homework h = Homework(key, values['description'], values['isCompleted'].toLowerCase() == 'true');
        reqHomework.add(h);
      });
    }

    return reqHomework;
  }

  dynamic deleteHomework(String id, String subjectID) async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    FormData formData = new FormData.from({
      "id": await prefs.getString("id"),
      "nodeID": id,
      "subjectID": subjectID,
      "refreshToken": await prefs.getString("refreshToken"),
    });

    try {
      //post the request and retrieve the response data
      var responseObj = await dio.post(deleteHomeworkURL, data: formData);

      //if the refresh token is null, then print the error in the logs and show an error dialog
      if(responseObj.data['refreshToken'] == null) {
        return "error";
      }
      else {
        await prefs.setString("refreshToken", responseObj.data['refreshToken']);
        return "success";
      }
    }
    //catch error and display error doalog
    on DioError catch(e)
    {
      return "error";
    }
  }

  Future<List<ClassMaterial>> getMaterials(String subjectID) async
  {
    List<ClassMaterial> reqMaterials = new List<ClassMaterial>();
    SharedPreferences prefs = await SharedPreferences.getInstance();

    //get user notes
    Response response = await dio.get(getMaterialsURL, data: {"id": await prefs.getString("id"), "refreshToken": await prefs.getString("refreshToken"), "subjectID": subjectID});

    //store images in a string list
    if (response.data['materials']?.values != null) {

      response.data['materials'].forEach((key, values) {
        ClassMaterial m = ClassMaterial(key, values['name'], values['photoUrl'] == null ? "" : values['photoUrl'], values['fileName'] == null ? "" : values['fileName']);
        reqMaterials.add(m);
      });
    }

    return reqMaterials;
  }

  //method for uploading user chosen image
  dynamic putMaterial(Map jsonMap) async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    //create form with relevant data and image as file
    FormData formData = new FormData.from({
      "id": await prefs.getString("id"),
      "nodeID": jsonMap['id'],
      "subjectID": jsonMap['subjectID'],
      "name": jsonMap['name'],
      "previousFile": jsonMap['previousFile'],
      "refreshToken": await prefs.getString("refreshToken"),
      "file": jsonMap['fileName'] == "" ? null : new UploadFileInfo(new File(jsonMap['fileName']), new DateTime.now().millisecondsSinceEpoch.toString()+jsonMap['fileName'].split('/').last)
    });

    try {
      //post the form data to the url
      var responseObj = await dio.post(putMaterialURL, data: formData);

      //if the refresh token is null, then display an alert dialog with an error
      //if the refresh token is null, then print the error in the logs and show an error dialog
      if(responseObj.data['refreshToken'] == null) {
        return "error";
      }
      else {
        await prefs.setString("refreshToken", responseObj.data['refreshToken']);
        return "success";
      }
    }
    on DioError catch(e)
    {
      return "error";
    }
  }

  dynamic deleteMaterial(String id, String subjectID, String fileName) async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    FormData formData = new FormData.from({
      "id": await prefs.getString("id"),
      "nodeID": id,
      "subjectID": subjectID,
      "refreshToken": await prefs.getString("refreshToken"),
      "fileName": fileName
    });

    try {
      //post the request and retrieve the response data
      var responseObj = await dio.post(deleteMaterialURL, data: formData);

      //if the refresh token is null, then print the error in the logs and show an error dialog
      if(responseObj.data['refreshToken'] == null) {
        return "error";
      }
      else {
        await prefs.setString("refreshToken", responseObj.data['refreshToken']);
        return "success";
      }
    }
    //catch error and display error doalog
    on DioError catch(e)
    {
      return "error";
    }
  }
}