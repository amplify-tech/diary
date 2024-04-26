import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_database/firebase_database.dart';

class HomeScreen extends StatelessWidget {
  final User user = FirebaseAuth.instance.currentUser!;

  HomeScreen({super.key});

  final DatabaseReference _ref =
      FirebaseDatabase.instance.ref().child('some_path');

  Future<void> saveDummyData() async {
    try {
      // Use the user's UID to construct the reference path
      DatabaseReference userRef = _ref.child(user.uid);

      // Save dummy data under the user's UID
      await userRef.set({
        "name": user.displayName,
        "phone": user.phoneNumber,
        "email": user.email,
        "age": 22,
        "address": {"line1": "100 pg View"}
      });

      print('Data saved successfully for user: ${user.email}');
    } catch (error) {
      print('Failed to save dummy data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome, ${user.displayName}!'),
            ElevatedButton(
              onPressed: saveDummyData,
              child: const Text('save data'),
            ),
            ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                GoogleSignIn().signOut();

                Navigator.pushNamedAndRemoveUntil(
                    context, '/login', (route) => false);
              },
              child: const Text('Sign out'),
            ),
          ],
        ),
      ),
    );
  }
}
