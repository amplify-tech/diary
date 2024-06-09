import 'package:diary/data/models/contact.dart';
import 'package:diary/data/repositories/cloud_service.dart';
import 'package:diary/data/repositories/isar_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:call_log/call_log.dart';

/////////////////////////////////////////////////////////////////////
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

/////////////////////////////////////////////////////////////////////
// call log
Future<List<CallLogEntry>> fetchCallLog() async {
  try {
    if (await Permission.phone.request().isGranted) {
      debugPrint(" fetching  call log");
      return (await CallLog.get()).toList();
    }
  } catch (e) {
    debugPrint('Error fetching call log: $e');
  }
  return [];
}

/////////////////////////////////////////////////////////////////////
// flutter_contacts
Future<List<Contact>> getContactsFromLocal() async {
  try {
    if (await Permission.contacts.request().isGranted) {
      debugPrint(" fetching contact");
      return ContactsService.getContacts(withThumbnails: false);
    }
  } catch (e) {
    debugPrint('Error fetching contacts: $e');
  }
  return [];
}

void deleteContactsFromLocal(List<Contact> contactList) async {
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

void addContactToLocal(List<Contact> contactList) async {
  debugPrint("adding to local");
  for (final contact in contactList) {
    try {
      await ContactsService.addContact(contact);
    } catch (e) {
      debugPrint('Error while adding contacts: $e ${contact.givenName}');
    }
  }
  debugPrint(" ${contactList.length} all contact added");
}

/////////////////////////////////////////////////////////////////////
// isar Db
Future<List<Contact>> syncFromLocal() async {
  List<Contact> contactList = [];

  try {
    contactList = await getContactsFromLocal();
    debugPrint("contact fetched ${contactList.length}");

    List<MyContact> myContactList = [];

    // data cleaning and ignore duplicate
    Set<String> dbPhones = await IsarService.getUniquePhoneNumbers();

    for (final contact in contactList) {
      for (Item phone in contact.phones ?? []) {
        if (phone.value != null && contact.displayName != null) {
          String phoneNumber =
              phone.value!.replaceAll('+91', '').replaceAll(RegExp(r'\D'), '');
          if (!dbPhones.contains(phoneNumber)) {
            myContactList
                .add(MyContact(phoneNumber, contact.displayName!, "local"));
          }
        }
      }
    }

    print(" added from local ${myContactList.length}");

    IsarService.addMyContacts(myContactList);
    debugPrint("added in db ");
  } catch (e) {
    debugPrint('Error saving db : $e');
  }
  return contactList;
}

void syncAndDelete() async {
  deleteContactsFromLocal(await syncFromLocal());
}

/////////////////////////////////////////////////////////////////////
// online cloud firebase databse
void handleBackup() async {
  try {
    final contacts = await IsarService.getAllMyContacts();
    final Map<String, dynamic> contactsJson = contacts.fold({}, (acc, contact) {
      acc[contact.phoneNumber] = [contact.name, contact.tag];
      return acc;
    });

    await CloudService.uploadContact(contactsJson);
    print('Backup successful!');
  } catch (e) {
    print('Error backing up contacts: $e');
  }
}

void handleDownload() async {
  try {
    Map contactsJson = await CloudService.downloadContact();
    // ignore duplicate
    Set<String> dbPhones = await IsarService.getUniquePhoneNumbers();
    List<MyContact> myContactList = [];
    for (final entry in contactsJson.entries) {
      if (!dbPhones.contains(entry.key)) {
        myContactList.add(MyContact(entry.key, entry.value[0], entry.value[1]));
      }
    }
    IsarService.addMyContacts(myContactList);

    print(myContactList.length);
    print('Download successful!');
  } catch (e) {
    // Handle errors
    print('Error downloading contacts: $e');
  }
}



/////////////////////////////////////////////////////////////////////
// alternate method
// contacts = (await FastContacts.getAllContacts()).cast<Contact>();
