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
            // Placeholder for the data
            FutureBuilder(
              future: getData(),
              builder: (context, AsyncSnapshot<DataSnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }
                if (snapshot.hasData && snapshot.data!.value != null) {
                  var data = snapshot.data!.value;
                  return Text(data.toString());
                } else {
                  return Text('No data available');
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<DataSnapshot> getData() async {
    // Get the data once
    DatabaseEvent event = await FirebaseDatabase.instance
        .ref()
        .child("some_path/${user.uid}")
        .once();

    // Print the data of the snapshot
    return event.snapshot;
  }
}
