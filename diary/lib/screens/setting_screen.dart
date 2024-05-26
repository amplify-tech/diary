import 'package:diary/utils/utils.dart';
import 'package:flutter/material.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        body:
            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
      Column(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
        ElevatedButton(onPressed: fetchContacts, child: Text('fetch')),
        ElevatedButton(onPressed: syncFromLocal, child: Text('sync')),
        ElevatedButton(
            onPressed: syncAndDelete, child: Text('sync and delete ')),
      ]),
    ]));
  }
}
