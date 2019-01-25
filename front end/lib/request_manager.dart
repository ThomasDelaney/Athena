import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'note.dart';
import 'subject.dart';
import 'subject_file.dart';

class RequestManager
{

  static final url = "https://glassy-acolyte-228916.appspot.com";
  static final RequestManager singleton = new RequestManager._internal();

  factory RequestManager() {
    return singleton;
  }

  RequestManager._internal();

  final String uploadFileUrl = url+"/putFile";
  final String getFilesUrl = url+"/getFiles";
  final String commandUrl = url+"/command";
  final String putFontUrl = url+"/font";
  final String loginUrl = url+"/signin";
  final String registerUrl = url+"/register";
  final String uploadNoteURL = url+"/putNote";
  final String deleteNoteURL = url+"/deleteNote";
  final String getNotesURL = url+"/getNotes";
  final String addSubjectURL = url+"/putSubject";
  final String deleteSubjectURL = url+"/deleteSubject";
  final String getSubjectsURL = url+"/getSubjects";

  Dio dio = new Dio();

  Future<List<SubjectFile>> getFiles(String subjectID) async
  {
    List<SubjectFile> reqFiles = new List<SubjectFile>();
    SharedPreferences prefs = await SharedPreferences.getInstance();

    //get user images
    Response response = await dio.get(getFilesUrl, data: {"id": await prefs.getString("id"), "refreshToken": await prefs.getString("refreshToken"), "subjectID": subjectID});

    //store images in a string list
    if (response.data['files']?.values != null) {
      for (var value in response.data['files'].values) {
        SubjectFile s = new SubjectFile(value['url'], value['fileName']);
        reqFiles.add(s);
      }
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
        return new SubjectFile("error", "error");
      }
      else {
        //else store the new refresh token in shared preferences and return the image URL
        await prefs.setString("refreshToken", responseObj.data['refreshToken']);
        return new SubjectFile(responseObj.data['url'], responseObj.data['fileName']);
      }
    }
    on DioError catch(e)
    {
      return new SubjectFile("error", "error");
    }
  }

  //method to submit the new font
  Future<String> changeFont(String currentFont) async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    //create form data for the request, with the new font
    FormData formData = new FormData.from({
      "id": await prefs.getString("id"),
      "refreshToken": await prefs.getString("refreshToken"),
      "font": currentFont
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
        await prefs.setString("font", currentFont);
        return "success";
      }
    }
    //catch error and display error doalog
    on DioError catch(e)
    {
      return "error";
    }
  }

  dynamic putSubject(Map jsonMap) async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    //create form data for the request, with the new font
    FormData formData = new FormData.from({
      "id": await prefs.getString("id"),
      "nodeID": jsonMap['id'],
      "refreshToken": await prefs.getString("refreshToken"),
      "name": jsonMap['name'],
      "colour": jsonMap['colour'],
    });

    try {
      //post the request and retrieve the response data
      var responseObj = await dio.post(addSubjectURL, data: formData);

      //if the refresh token is null, then print the error in the logs and show an error dialog
      if(responseObj.data['refreshToken'] == null) {
        return "error";
      }
      //else store the new refresh token and font in shared preferences, and display snackbar the font has been updated
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

  dynamic deleteSubject(String id) async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    //create form data for the request, with the new font
    FormData formData = new FormData.from({
      "id": await prefs.getString("id"),
      "nodeID": id,
      "refreshToken": await prefs.getString("refreshToken"),
    });

    try {
      //post the request and retrieve the response data
      var responseObj = await dio.post(deleteSubjectURL, data: formData);

      //if the refresh token is null, then print the error in the logs and show an error dialog
      if(responseObj.data['refreshToken'] == null) {
        return "error";
      }
      //else store the new refresh token and font in shared preferences, and display snackbar the font has been updated
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

  dynamic putNote(Map jsonMap) async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    //create form data for the request, with the new font
    FormData formData = new FormData.from({
      "id": await prefs.getString("id"),
      "nodeID": jsonMap['id'],
      "subjectID": jsonMap['subjectID'],
      "refreshToken": await prefs.getString("refreshToken"),
      "fileName": jsonMap['fileName'],
      "delta": jsonMap['delta'],
    });

    try {
      //post the request and retrieve the response data
      var responseObj = await dio.post(uploadNoteURL, data: formData);

      //if the refresh token is null, then print the error in the logs and show an error dialog
      if(responseObj.data['refreshToken'] == null) {
        return "error";
      }
      //else store the new refresh token and font in shared preferences, and display snackbar the font has been updated
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

  dynamic deleteNote(String id, String subjectID) async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    //create form data for the request, with the new font
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
      //else store the new refresh token and font in shared preferences, and display snackbar the font has been updated
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
        Note n = new Note(key, values['fileName'], values['delta']);
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

    //create form data for the request, with the new font
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

    //create form data for the request, with the new font
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
}