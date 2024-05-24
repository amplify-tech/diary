import 'package:diary/data/models/contact.dart';
import 'package:diary/data/repositories/isar_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:contacts_service/contacts_service.dart';

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
void fetchContacts() async {
  try {
    if (await Permission.contacts.request().isGranted) {
      // contacts = (await FastContacts.getAllContacts()).cast<Contact>();
      debugPrint(" fetching ");
      List<Contact> contactList = await ContactsService.getContacts();
      Map<String, String> contactMap = {};

      for (final contact in contactList) {
        for (Item phone in contact.phones ?? []) {
          if (phone.value != null) {
            String phoneNumber = phone.value!
                .replaceAll('+91', '')
                .replaceAll(RegExp(r'\D'), '');
            contactMap[phoneNumber] = contact.displayName!;
          }
        }
      }

      List<MyContact> myContactList = [];
      contactMap.forEach((phoneNumber, name) {
        myContactList.add(MyContact(name, phoneNumber, "main"));
      });

      debugPrint("contact fetched ${contactList.length}");
      debugPrint("map fetched ${contactMap.length}");
      debugPrint("mycontact created ${myContactList.length}");
      IsarService.addMyContacts(myContactList);
      debugPrint("added in db ");
    }
  } catch (e) {
    print('Error fetching contacts: $e');
  }
}

void deleteContacts() async {
  print("wait fetching now ");
  List<Contact> contacts = [];
  print("deleting");
  print(contacts);
  for (final contact in contacts) {
    try {
      await ContactsService.deleteContact(contact);
    } catch (e) {
      print('Error while deleting contacts: $e');
    }
  }
  print("all contact deleted");
}

void addContact() async {
  final newContact = Contact()
    ..givenName = 'John'
    ..phones = [
      Item(label: "Mobile", value: '+918085904091'),
    ];
  await ContactsService.addContact(newContact);
  print("new contact added $newContact");
}
