import 'package:diary/utils/utils.dart';
import 'package:diary/widgets/common/backup_button.dart';
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
    return Scaffold(
        body:
            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
      Column(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
        const BackupButton(),
        const ElevatedButton(
            onPressed: handleDownload, child: Text('Download Contact')),
        ElevatedButton(
            child: const Text('Sign Out'),
            onPressed: () => FirebaseAuth.instance.signOut()),
        const Text("________________________________"),
        const ElevatedButton(onPressed: syncFromLocal, child: Text('sync')),
        const ElevatedButton(
            onPressed: syncAndDelete, child: Text('sync and delete ')),
      ]),
    ]));
  }
}
