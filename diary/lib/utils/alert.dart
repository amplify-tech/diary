import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

void showSnackbar(
  BuildContext context,
  String message, {
  Duration duration = const Duration(seconds: 2),
  String? actionLabel,
  VoidCallback? onActionPressed,
}) {
  ScaffoldMessenger.of(context).clearSnackBars();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      duration: duration,
      action: actionLabel != null
          ? SnackBarAction(
              label: actionLabel,
              onPressed: onActionPressed!,
            )
          : null,
    ),
  );
}

void copytoClipBoard(String copyText, String? message) {
  Clipboard.setData(ClipboardData(text: copyText)).then((_) {
    if (message != null) {
      Fluttertoast.showToast(
          msg: message, backgroundColor: Colors.white, textColor: Colors.black);
    }
  });
}
