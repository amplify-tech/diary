import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WhatsApp Chat',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final String phoneNumber = "+918085904091";

  const MyHomePage(
      {super.key}); // Replace this with the desired WhatsApp number

  void _launchWhatsApp(BuildContext context) async {
    String url = "https://wa.me/$phoneNumber?text=Hello+There!";
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Could not launch WhatsApp"),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("WhatsApp Chat"),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            _launchWhatsApp(context);
          },
          child: const Text("Chat on WhatsApp"),
        ),
      ),
    );
  }
}
