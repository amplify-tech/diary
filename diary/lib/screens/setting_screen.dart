import 'package:diary/utils/alert.dart';
import 'package:diary/utils/utils.dart';
import 'package:diary/widgets/common/login_screen.dart';
import 'package:diary/widgets/common/realtime_text_widget.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
        child: ListView(children: <Widget>[
          // Realtime widget
          cardDivider,
          heading("Realtime"),
          const FirebaseRealtimeTextWidget(),

          // cloud division
          cardDivider,
          heading("Cloud"),
          FirebaseAuth.instance.currentUser == null
              ? fixButton("Download Contact", null)
              : fixButton("Download Contact", () => handleDownload(context)),
          FirebaseAuth.instance.currentUser == null
              ? fixButton("Sign In", login)
              : fixButton("Sign Out", () {
                  FirebaseAuth.instance.signOut();
                  showSnackbar(context,
                      "${FirebaseAuth.instance.currentUser!.email} Signed Out!");
                }),

          // device division
          cardDivider,
          heading("Device"),
          fixButton("sync and delete", () => syncAndDelete(context)),
          fixButton("Save to Device", () => saveToDevice(context)),
          cardDivider,
        ]));
  }

  void login() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }
}

////////////////////////////////////////////////////////////////////////////////
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

Widget fixButton(String title, VoidCallback? onPress) {
  return ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(160, 40),
      ),
      onPressed: onPress,
      child: Text(title));
}
