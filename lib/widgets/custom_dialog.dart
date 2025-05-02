import 'package:flutter/material.dart';

class CustomDialog {
  static void showLoadingDialog(
    BuildContext context, {
    String message = "Please wait...",
  }) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent closing by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 20),
              Expanded(child: Text(message)),
            ],
          ),
        );
      },
    );
  }

  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context).pop(); // Close the dialog
  }
}
