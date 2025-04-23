import 'package:diary/utils/alert.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class RealtimeTextWidget extends StatefulWidget {
  const RealtimeTextWidget({super.key});

  @override
  State<RealtimeTextWidget> createState() => RealtimeTextWidgetState();
}

class RealtimeTextWidgetState extends State<RealtimeTextWidget> {
  String _text = '';
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    FirebaseDatabase.instance.ref().child('mydata').onValue.listen((event) {
      try {
        setState(() {
          _text = event.snapshot.value.toString();
        });
      } catch (e) {
        _text = e.toString();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      ListTile(
          title: SelectableText(_text),
          trailing: IconButton(
              icon: const Icon(Icons.copy),
              onPressed: () => copytoClipBoard(_text, "Text copied"))),
      ListTile(
          title: TextField(
              maxLines: null,
              controller: _controller,
              decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(22))),
              onTapOutside: (final event) {
                FocusManager.instance.primaryFocus?.unfocus();
              }),
          trailing:
              IconButton(icon: const Icon(Icons.send), onPressed: uploadData))
    ]);
  }

  void uploadData() {
    FirebaseDatabase.instance.ref().child('mydata').set(_controller.text);
    _controller.clear();
  }
}
