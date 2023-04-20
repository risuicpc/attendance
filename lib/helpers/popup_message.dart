import 'package:flutter/material.dart'
    show BuildContext, ScaffoldMessenger, SnackBar, Colors, Text;

void showErorr(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    backgroundColor: Colors.red,
    content: Text(message),
  ));
}

void showSuccess(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    backgroundColor: Colors.green,
    content: Text(message),
  ));
}
