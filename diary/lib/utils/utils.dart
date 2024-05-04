import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

// url_launcher
Future callNumber(phoneNumber) async {
  await FlutterPhoneDirectCaller.callNumber(phoneNumber);
}

Future launchWhatsApp(phoneNumber) async {
  String url = "https://wa.me/$phoneNumber";
  try {
    await launchUrlString(url);
  } catch (e) {
    return false;
  }
}

// flutter_contacts
Future<List<Contact>> fetchContacts() async {
  List<Contact> contacts = [];
  try {
    if (await FlutterContacts.requestPermission(readonly: true)) {
      contacts = await FlutterContacts.getContacts(withProperties: true);
    }
  } catch (e) {
    print('Error fetching contacts: $e');
  }
  return contacts;
}

void deleteContacts(List<Contact> contacts) async {
  print("deleting");
  print(contacts);
  try {
    await FlutterContacts.deleteContacts(contacts);
  } catch (e) {
    print('Error while deleting contacts: $e');
  }
  print("all contact deleted");
}

void addContact() async {
  final contact = await FlutterContacts.openExternalInsert();
  print(contact);
}
