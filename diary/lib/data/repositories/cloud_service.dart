import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CloudService {
  static Future<void> uploadContact(Map<String, dynamic> jsonData) async {
    print("in class u");

    final uid = FirebaseAuth.instance.currentUser?.uid;
    final contactRef =
        FirebaseDatabase.instance.ref().child('users/$uid/contacts');
    await contactRef.update(jsonData);
  }

  static Future<Map> downloadContact() async {
    print("in class d");
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final contactRef =
        FirebaseDatabase.instance.ref().child('users/$uid/contacts');
    final snapshot = await contactRef.get();
    return snapshot.value as Map<dynamic, dynamic>;
  }
}
