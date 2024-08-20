import 'package:diary/utils/alert.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class FirebaseRealtimeTextWidget extends StatefulWidget {
  const FirebaseRealtimeTextWidget({super.key});

  @override
  FirebaseRealtimeTextWidgetState createState() =>
      FirebaseRealtimeTextWidgetState();
}

class FirebaseRealtimeTextWidgetState
    extends State<FirebaseRealtimeTextWidget> {
  String _text = '';
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    FirebaseDatabase.instance.ref().child('mydata').onValue.listen((event) {
      setState(() {
        _text = event.snapshot.value.toString();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: SelectableText(_text),
          trailing: IconButton(
              icon: const Icon(Icons.copy),
              onPressed: () => copytoClipBoard(_text, "Text copied")),
        ),
        ListTile(
          title: TextField(
            maxLines: null,
            controller: _controller,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              // labelText: '...',
            ),
            onTapOutside: (final event) {
              FocusManager.instance.primaryFocus?.unfocus();
            },
          ),
          trailing: IconButton(
            icon: const Icon(Icons.send),
            onPressed: uploadData,
          ),
        )
      ],
    );
  }

  void uploadData() {
    FirebaseDatabase.instance.ref().child('mydata').set(_controller.text);
    _controller.clear();
  }
}
