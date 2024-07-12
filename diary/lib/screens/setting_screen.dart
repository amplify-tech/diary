import 'package:diary/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

const cardDivider = Divider(
  height: 36,
);

Widget heading(String title) {
  return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 24.0,
          fontWeight: FontWeight.bold,
        ),
      ));
}

Widget fixButton(String title, VoidCallback onPress) {
  return ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(160, 40),
      ),
      onPressed: onPress,
      child: Text(title));
}

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
        child: Column(children: <Widget>[
          // cloud division
          cardDivider,
          heading("Cloud"),
          fixButton("Download Contact", handleDownload),
          fixButton("Sign Out", () => FirebaseAuth.instance.signOut()),
          cardDivider,

          // device division
          heading("Device"),
          fixButton("sync and delete", syncAndDelete),
          fixButton("Save to Device", saveToDevice),
          cardDivider,
        ]));
  }
}
