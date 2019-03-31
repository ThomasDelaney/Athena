import 'dart:io';
import 'package:Athena/media/note.dart';
import 'package:Athena/reminders/athena_notification.dart';
import 'package:Athena/tags/tag.dart';
import 'package:Athena/utilities/theme_check.dart';
import 'package:flutter/material.dart';
import 'package:Athena/design/athena_icon_data.dart';
import 'package:Athena/subjects/class_material.dart';
import 'package:Athena/design/font_data.dart';
import 'package:Athena/subjects/homework.dart';
import 'package:Athena/subjects/test_result.dart';
import 'package:Athena/timetables/timetable_slot.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:Athena/subjects/subject.dart';
import 'package:Athena/subjects/subject_file.dart';

class RequestManager
{

  static final url = "https://qualified-cedar-235821.appspot.com";
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
  final String putCardColourUrl = url+"/putCardColour";
  final String getCardColourUrl = url+"/getCardColour";
  final String putBackgroundColourUrl = url+"/putBackgroundColour";
  final String getBackgroundColourUrl = url+"/getBackgroundColour";
  final String putThemeColourUrl = url+"/putThemeColour";
  final String getThemeColourUrl = url+"/getThemeColour";
  final String putIsDyslexiaModeEnabledUrl = url+"/setIsDyslexiaModeEnabled";
  final String getIsDyslexiaModeEnabledUrl = url+"/getIsDyslexiaModeEnabled";
  final String deleteNotificationURL = url+"/deleteNotification";
  final String putNotificationURL = url+"/putNotification";
  final String getNotificationsURL = url+"/getNotifications";

  Dio dio = new Dio();

  Future<List<SubjectFile>> getFiles(String subjectID, [String date]) async
  {
    List<SubjectFile> reqFiles = new List<SubjectFile>();
    SharedPreferences prefs = await SharedPreferences.getInstance();

    //get user images
    Response response = await dio.get(getFilesUrl, queryParameters: {
      "id": await prefs.getString("id"),
      "refreshToken": await prefs.getString("refreshToken"),
      "subjectID": subjectID,
      "date": date != null ? date : "null"
    });

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
  Future<SubjectFile> uploadFile(String filePath, String subjectID, [String date]) async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    //create form with relevant data and image as file
    FormData formData = new FormData.from({
      "id": await prefs.getString("id"),
      "subjectID": subjectID,
      "date": date != null ? date : "null",
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

  dynamic deleteFile(String id, String subjectID, String fileName, [String date]) async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    try {
      //post the request and retrieve the response data
      var responseObj = await dio.delete(deleteFileUrl, queryParameters: {
        "id": await prefs.getString("id"),
        "nodeID": id,
        "subjectID": subjectID,
        "fileName": fileName,
        "date": date != null ? date : "null",
        "refreshToken": await prefs.getString("refreshToken"),
      });

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
    Response response = await dio.get(getFontUrl, queryParameters: {"id": await prefs.getString("id"), "refreshToken": await prefs.getString("refreshToken")});

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

    if (!await getDyslexiaFriendlyModeEnabled()){
      await prefs.setInt("fontColour", data.color.value);
    }else{
      if(await prefs.getInt("fontColour") != null){
        data.color = await Color(prefs.getInt("fontColour"));
      }
      else{
        await prefs.setInt("fontColour", Colors.black.value);
        data.color = await Color(prefs.getInt("fontColour"));
      }
    }

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
    Response response = await dio.get(getIconUrl, queryParameters: {"id": await prefs.getString("id"), "refreshToken": await prefs.getString("refreshToken")});

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

    if (!await getDyslexiaFriendlyModeEnabled()){
      await prefs.setInt("iconColour", data.color.value);
    }else{
      if(await prefs.getInt("iconColour") != null){
        data.color = await Color(prefs.getInt("iconColour"));
      }
      else{
        await prefs.setInt("iconColour", Colors.black.value);
        data.color = await Color(prefs.getInt("iconColour"));
      }
    }

    await prefs.setDouble("iconSize", data.size);

    return data;
  }

  //method to submit the new font
  Future<String> putCardColour(Color color) async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    //create form data for the request, with the new font
    FormData formData = new FormData.from({
      "id": await prefs.getString("id"),
      "refreshToken": await prefs.getString("refreshToken"),
      "cardColour": color.value,
    });

    try {
      //post the request and retrieve the response data
      var responseObj = await dio.post(putCardColourUrl, data: formData);

      //if the refresh token is null, then print the error in the logs and show an error dialog
      if(responseObj.data['refreshToken'] == null) {
        return "error";
      }
      //else store the new refresh token and font in shared preferences, and display snackbar the font has been updated
      else {
        await prefs.setString("refreshToken", responseObj.data['refreshToken']);
        await prefs.setInt("cardColour", color.value);
        return "success";
      }
    }
    //catch error and display error doalog
    on DioError catch(e)
    {
      return "error";
    }
  }

  Future<Color> getCardColour() async
  {
    Color data;
    SharedPreferences prefs = await SharedPreferences.getInstance();

    //get user images
    Response response = await dio.get(getCardColourUrl, queryParameters: {"id": await prefs.getString("id"), "refreshToken": await prefs.getString("refreshToken")});

    //store images in a string list
    if (response.data['data'] != null) {

      data = Color(int.tryParse(response.data['data']));
    }else{
      data = Colors.white;
    }

    if (!await getDyslexiaFriendlyModeEnabled()){
      await prefs.setInt("cardColour", data.value);
    }else{
      if(await prefs.getInt("cardColour") != null){
        data = await Color(prefs.getInt("cardColour"));
      }else{
        await prefs.setInt("cardColour", Color.fromRGBO(242, 227, 198, 1).value);
        data = await Color(prefs.getInt("cardColour"));
      }
    }

    return data;
  }

  //method to submit the new font
  Future<String> putDyslexiaFriendlyModeEnabled(bool enabled) async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    //create form data for the request, with the new font
    FormData formData = new FormData.from({
      "id": await prefs.getString("id"),
      "refreshToken": await prefs.getString("refreshToken"),
      "dyslexiaFriendlyEnabled": enabled.toString(),
    });

    try {
      //post the request and retrieve the response data
      var responseObj = await dio.post(putIsDyslexiaModeEnabledUrl, data: formData);

      //if the refresh token is null, then print the error in the logs and show an error dialog
      if(responseObj.data['refreshToken'] == null) {
        return "error";
      }
      //else store the new refresh token and font in shared preferences, and display snackbar the font has been updated
      else {
        await prefs.setString("refreshToken", responseObj.data['refreshToken']);
        await prefs.setBool("dyslexiaFriendlyEnabled", enabled);
        return "success";
      }
    }
    //catch error and display error doalog
    on DioError catch(e)
    {
      return "error";
    }
  }

  Future<bool> getDyslexiaFriendlyModeEnabled() async
  {
    bool data;
    SharedPreferences prefs = await SharedPreferences.getInstance();

    //get user images
    Response response = await dio.get(getIsDyslexiaModeEnabledUrl, queryParameters: {"id": await prefs.getString("id"), "refreshToken": await prefs.getString("refreshToken")});

    //store images in a string list
    if (response.data['data'] != null) {

      data = response.data['data'].toLowerCase() == 'true';
    }else{
      data = false;
    }

    await prefs.setBool("dyslexiaFriendlyEnabled", data);

    return data;
  }

  //method to submit the new font
  Future<String> putBackgroundColour(Color color) async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    //create form data for the request, with the new font
    FormData formData = new FormData.from({
      "id": await prefs.getString("id"),
      "refreshToken": await prefs.getString("refreshToken"),
      "backgroundColour": color.value,
    });

    try {
      //post the request and retrieve the response data
      var responseObj = await dio.post(putBackgroundColourUrl, data: formData);

      //if the refresh token is null, then print the error in the logs and show an error dialog
      if(responseObj.data['refreshToken'] == null) {
        return "error";
      }
      //else store the new refresh token and font in shared preferences, and display snackbar the font has been updated
      else {
        await prefs.setString("refreshToken", responseObj.data['refreshToken']);
        await prefs.setInt("backgroundColour", color.value);
        return "success";
      }
    }
    //catch error and display error doalog
    on DioError catch(e)
    {
      return "error";
    }
  }

  Future<Color> getBackgroundColour() async
  {
    Color data;
    SharedPreferences prefs = await SharedPreferences.getInstance();

    //get user images
    Response response = await dio.get(getBackgroundColourUrl, queryParameters: {"id": await prefs.getString("id"), "refreshToken": await prefs.getString("refreshToken")});

    //store images in a string list
    if (response.data['data'] != null) {

      data = Color(int.tryParse(response.data['data']));
    }else{
      data = Colors.white;
    }

    if (!await getDyslexiaFriendlyModeEnabled()){
      await prefs.setInt("backgroundColour", data.value);
    }else{
      if(await prefs.getInt("backgroundColour") != null){
        data = await Color(prefs.getInt("backgroundColour"));
      }else{
        await prefs.setInt("backgroundColour", ThemeCheck.errorColorOfColor(Color.fromRGBO(242, 227, 198, 1)).value);
        data = await Color(prefs.getInt("backgroundColour"));
      }
    }

    return data;
  }

  //method to submit the new font
  Future<String> putThemeColour(Color color) async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    //create form data for the request, with the new font
    FormData formData = new FormData.from({
      "id": await prefs.getString("id"),
      "refreshToken": await prefs.getString("refreshToken"),
      "themeColour": color.value,
    });

    try {
      //post the request and retrieve the response data
      var responseObj = await dio.post(putThemeColourUrl, data: formData);

      //if the refresh token is null, then print the error in the logs and show an error dialog
      if(responseObj.data['refreshToken'] == null) {
        return "error";
      }
      //else store the new refresh token and font in shared preferences, and display snackbar the font has been updated
      else {
        await prefs.setString("refreshToken", responseObj.data['refreshToken']);
        await prefs.setInt("themeColour", color.value);
        return "success";
      }
    }
    //catch error and display error doalog
    on DioError catch(e)
    {
      return "error";
    }
  }

  Future<Color> getThemeColour() async
  {
    Color data;
    SharedPreferences prefs = await SharedPreferences.getInstance();

    //get user images
    Response response = await dio.get(getThemeColourUrl, queryParameters: {"id": await prefs.getString("id"), "refreshToken": await prefs.getString("refreshToken")});

    //store images in a string list
    if (response.data['data'] != null) {

      data = Color(int.tryParse(response.data['data']));
    }else{
      data = Colors.white;
    }

    if (!await getDyslexiaFriendlyModeEnabled()){
      await prefs.setInt("themeColour", data.value);
    }else{
      if(await prefs.getInt("themeColour") != null){
        data = await Color(prefs.getInt("themeColour"));
      }else{
        await prefs.setInt("themeColour", Color.fromRGBO(113, 180, 227, 1).value);
        data = await Color(prefs.getInt("themeColour"));
      }
    }

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

    try {
      //post the request and retrieve the response data
      var responseObj = await dio.delete(deleteSubjectURL, queryParameters: {
        "id": await prefs.getString("id"),
        "nodeID": id,
        "title": title,
        "refreshToken": await prefs.getString("refreshToken"),
      });

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
    Response response = await dio.get(getSubjectsURL, queryParameters: {"id": await prefs.getString("id"), "refreshToken": await prefs.getString("refreshToken")});

    //store images in a string list
    if (response.data['subjects']?.values != null) {

      response.data['subjects'].forEach((key, values) {
        if (key != "journal"){
          Subject s = new Subject(key, values['name'], values['colour']);
          reqSubjects.add(s);
        }
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
      "date": jsonMap['date'] != null ? jsonMap['date'] : "null",
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

  dynamic deleteTag(Tag tag, [String date]) async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    try {
      //post the request and retrieve the response data
      var responseObj = await dio.delete(deleteTagURL, queryParameters: {
        "id": await prefs.getString("id"),
        "nodeID": tag.id,
        "tag": tag.tag,
        "date": date != null ? date : "null",
        "refreshToken": await prefs.getString("refreshToken"),
      });

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
    Response response = await dio.get(getTagsURL, queryParameters: {"id": await prefs.getString("id"), "refreshToken": await prefs.getString("refreshToken")});

    //store images in a string list
    if (response.data['tags']?.values != null) {

      response.data['tags'].forEach((key, values) {
        Tag t = new Tag(key, values);
        reqTags.add(t);
      });
    }

    return reqTags;
  }

  Future<List> getNotesAndFilesByTag(String tag, [String date]) async
  {
    Map<Subject, Note> notes = new Map<Subject, Note>();
    Map<Subject, SubjectFile> files = new Map<Subject, SubjectFile>();

    SharedPreferences prefs = await SharedPreferences.getInstance();

    //get user images
    Response response = await dio.get(getNotesAndFilesWithTagURL, queryParameters: {
      "id": await prefs.getString("id"),
      "refreshToken": await prefs.getString("refreshToken"),
      "tag": tag,
      "date": date != null ? date : "null",
    });

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
      "date": jsonMap['date'] != null ? jsonMap['date'] : "null"
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
      "date": jsonMap['date'] != null ? jsonMap['date'] : "null",
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
      "date": jsonMap['date'] != null ? jsonMap['date'] : "null",
      "refreshToken": await prefs.getString("refreshToken"),
    });

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

  dynamic deleteNote(String id, String subjectID, [String date]) async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    try {
      //post the request and retrieve the response data
      var responseObj = await dio.delete(deleteNoteURL, queryParameters: {
        "id": await prefs.getString("id"),
        "nodeID": id,
        "subjectID": subjectID,
        "date": date != null ? date : "null",
        "refreshToken": await prefs.getString("refreshToken"),
      });

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

  Future<List<Note>> getNotes(String subjectID, [String date]) async
  {
    List<Note> reqNotes = new List<Note>();
    SharedPreferences prefs = await SharedPreferences.getInstance();

    //get user notes
    Response response = await dio.get(getNotesURL, queryParameters: {
      "id": await prefs.getString("id"),
      "refreshToken": await prefs.getString("refreshToken"),
      "subjectID": subjectID,
      "date": date != null ? date : "null"
    });

    //store images in a string list
    if (response.data['notes']?.values != null) {

      response.data['notes'].forEach((key, values) {
        Note n = new Note(key, values['fileName'], values['delta'], values['tag']);
        reqNotes.add(n);
      });
    }

    return reqNotes;
  }

  dynamic command(String uri) async
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
    Response response = await dio.get(getTimeslotsURL, queryParameters: {"id": await prefs.getString("id"), "refreshToken": await prefs.getString("refreshToken")});

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

    try {
      //post the request and retrieve the response data
      var responseObj = await dio.delete(deleteTimeslotURL, queryParameters: {
        "id": await prefs.getString("id"),
        "nodeID": id,
        "day": day,
        "refreshToken": await prefs.getString("refreshToken"),
      });

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
    Response response = await dio.get(getTestResultsURL, queryParameters: {"id": await prefs.getString("id"), "refreshToken": await prefs.getString("refreshToken"), "subjectID": subjectID});

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

    try {
      //post the request and retrieve the response data
      var responseObj = await dio.delete(deleteTestResultURL, queryParameters: {
        "id": await prefs.getString("id"),
        "nodeID": id,
        "subjectID": subjectID,
        "refreshToken": await prefs.getString("refreshToken"),
      });

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
    Response response = await dio.get(getHomeworkURL, queryParameters: {"id": await prefs.getString("id"), "refreshToken": await prefs.getString("refreshToken"), "subjectID": subjectID});

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

    try {
      //post the request and retrieve the response data
      var responseObj = await dio.delete(deleteHomeworkURL, queryParameters: {
        "id": await prefs.getString("id"),
        "nodeID": id,
        "subjectID": subjectID,
        "refreshToken": await prefs.getString("refreshToken"),
      });

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
    Response response = await dio.get(getMaterialsURL, queryParameters: {"id": await prefs.getString("id"), "refreshToken": await prefs.getString("refreshToken"), "subjectID": subjectID});

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

    try {
      //post the request and retrieve the response data
      var responseObj = await dio.delete(deleteMaterialURL, queryParameters: {
        "id": await prefs.getString("id"),
        "nodeID": id,
        "subjectID": subjectID,
        "refreshToken": await prefs.getString("refreshToken"),
        "fileName": fileName
      });

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

  dynamic putNotification(Map jsonMap) async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    FormData formData = new FormData.from({
      "id": await prefs.getString("id"),
      "nodeID": jsonMap['id'],
      "refreshToken": await prefs.getString("refreshToken"),
      "description": jsonMap['description'],
      "time": jsonMap['time'],
    });

    try {
      //post the request and retrieve the response data
      var responseObj = await dio.post(putNotificationURL, data: formData);

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

  Future<List<AthenaNotification>> getNotifications() async
  {
    List<AthenaNotification> reqNotifs = new List<AthenaNotification>();
    SharedPreferences prefs = await SharedPreferences.getInstance();

    //get user notes
    Response response = await dio.get(getNotificationsURL, queryParameters: {"id": await prefs.getString("id"), "refreshToken": await prefs.getString("refreshToken")});

    //store images in a string list
    if (response.data['notifications']?.values != null) {

      response.data['notifications'].forEach((key, values) {
        AthenaNotification n = AthenaNotification(key, values['description'], values['time']);
        reqNotifs.add(n);
      });
    }

    return reqNotifs;
  }

  dynamic deleteNotification(String id) async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    try {
      //post the request and retrieve the response data
      var responseObj = await dio.delete(deleteNotificationURL, queryParameters: {
        "id": await prefs.getString("id"),
        "nodeID": id,
        "refreshToken": await prefs.getString("refreshToken"),
      });

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