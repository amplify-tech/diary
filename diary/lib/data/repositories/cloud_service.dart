import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CloudService {
  static Future<void> uploadContact(Map<String, dynamic> jsonData) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final contactRef =
        FirebaseDatabase.instance.ref().child('users/$uid/contacts');
    await contactRef.update(jsonData);
  }

  static Future<Map> downloadContact() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final contactRef =
        FirebaseDatabase.instance.ref().child('users/$uid/contacts');
    final snapshot = await contactRef.get();
    return snapshot.value as Map<dynamic, dynamic>;
  }
}
