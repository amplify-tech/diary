import 'package:diary/data/models/contact.dart';
import 'package:diary/data/repositories/isar_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:isar/isar.dart';
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
Future<List<Contact>> fetchContacts() async {
  try {
    if (await Permission.contacts.request().isGranted) {
      debugPrint(" fetching ");
      return ContactsService.getContacts();
    }
  } catch (e) {
    debugPrint('Error fetching contacts: $e');
  }
  return [];
}

void deleteContacts(List<Contact> contactList) async {
  debugPrint("deleting");
  for (final contact in contactList) {
    try {
      await ContactsService.deleteContact(contact);
    } catch (e) {
      debugPrint('Error while deleting contacts: $e ${contact.displayName}');
    }
  }
  debugPrint("all contact deleted");
}

void addContact() async {
  final newContact = Contact()
    ..givenName = 'John'
    ..phones = [
      Item(label: "Mobile", value: '+918085904091'),
    ];
  await ContactsService.addContact(newContact);
  debugPrint("new contact added $newContact");
}

// isar Db
Future<List<Contact>> syncFromLocal() async {
  List<Contact> contactList = [];

  try {
    contactList = await fetchContacts();
    debugPrint("contact fetched ${contactList.length}");

    List<MyContact> myContactList = [];

    // data cleaning and ignore duplicate
    final dbPhones = (await IsarService.isar.myContacts
            .where()
            .phoneNumberProperty()
            .findAll())
        .toSet();

    for (final contact in contactList) {
      for (Item phone in contact.phones ?? []) {
        if (phone.value != null && contact.displayName != null) {
          String phoneNumber =
              phone.value!.replaceAll('+91', '').replaceAll(RegExp(r'\D'), '');
          if (!dbPhones.contains(phoneNumber)) {
            myContactList
                .add(MyContact(phoneNumber, contact.displayName!, "main"));
          }
        }
      }
    }

    IsarService.addMyContacts(myContactList);
    debugPrint("added in db ");
  } catch (e) {
    debugPrint('Error saving db : $e');
  }
  return contactList;
}

void syncAndDelete() async {
  deleteContacts(await syncFromLocal());
}


/////////////////////////////////////////////////////////////////////
// alternate method
// contacts = (await FastContacts.getAllContacts()).cast<Contact>();
