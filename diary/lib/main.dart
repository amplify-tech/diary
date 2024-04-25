import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter Call Button Example'),
        ),
        body: const Center(
          child: CallButton(),
        ),
      ),
    );
  }
}

class CallButton extends StatelessWidget {
  const CallButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _callNumber,
      child: const Text('Call Number'),
    );
  }

  _callNumber() async {
    const number = '9999454562';
    await FlutterPhoneDirectCaller.callNumber(number);
  }
}
