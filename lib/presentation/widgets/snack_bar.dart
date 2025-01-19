import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void showCustomSnackBar(BuildContext context, String message,
    {bool isError = false}) {
  final snackBar = SnackBar(
    content: Text(
      message,
      style: TextStyle(color: isError ? Colors.red : Colors.white),
    ),
    backgroundColor: isError ? Colors.white : Colors.black,
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

void responseHandlerPost(
    http.Response response, BuildContext context, String correct, String err) {
  if (response.statusCode == 201) {
    showCustomSnackBar(context, correct);
  } else {
    showCustomSnackBar(context, err);
  }
}

void responseHandlerDelete(
    http.Response response, BuildContext context, String correct, String err) {
  if (response.statusCode == 200) {
    showCustomSnackBar(context, correct);
  } else {
    showCustomSnackBar(context, err);
  }
}

void responseHandlerPut(
    http.Response response, BuildContext context, String correct, String err) {
  if (response.statusCode == 200) {
    showCustomSnackBar(context, correct);
  } else {
    showCustomSnackBar(context, err);
  }
}

void responseHandlerGet(
    http.Response response, BuildContext context, String correct, String err) {
  if (response.statusCode == 201) {
    showCustomSnackBar(context, correct);
  } else {
    showCustomSnackBar(context, err);
  }
}
