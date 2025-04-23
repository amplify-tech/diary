// ignore_for_file: use_build_context_synchronously

import 'package:diary/data/models/contact.dart';
import 'package:diary/data/repositories/cloud_service.dart';
import 'package:diary/data/repositories/isar_service.dart';
import 'package:diary/utils/alert.dart';
import 'package:diary/utils/device_contact.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:isar/isar.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:contacts_service/contacts_service.dart';

////////////////////////////////////////////////////////////////////////////////
// url_launcher
Future callNumber(phoneNumber) async {
  await FlutterPhoneDirectCaller.callNumber("+91$phoneNumber");
}

Future launchWhatsApp(phoneNumber) async {
  String url = "https://wa.me/+91$phoneNumber";
  try {
    await launchUrlString(url);
  } catch (e) {
    return false;
  }
}

////////////////////////////////////////////////////////////////////////////////
// device contact <-> isar Db
Future<List<Contact>> syncFromLocal(BuildContext context) async {
  List<Contact> contactList = [];
  showSnackbar(context, "Syncing from local...");

  try {
    contactList = await getContactsFromLocal(context);
    showSnackbar(context, "${contactList.length} Contacts Fetched");

    List<MyContact> myContactList = [];

    // data cleaning and ignore duplicate
    Set<String> dbPhones = await IsarService.getUniquePhoneNumbers();

    for (final contact in contactList) {
      for (Item phone in contact.phones ?? []) {
        if (phone.value != null && contact.displayName != null) {
          String phoneNumber = phone.value!.getPhoneNumber();
          if (!dbPhones.contains(phoneNumber)) {
            myContactList.add(MyContact(
                phoneNumber, contact.displayName!.capitalize(), "special"));
          }
        }
      }
    }

    await IsarService.addMyContacts(myContactList);
    showSnackbar(context, "${contactList.length} Contacts Added");
  } catch (e) {
    showSnackbar(context, 'Error saving db : \n $e');
  }
  return contactList;
}

Future<void> syncAndDelete(BuildContext context) async {
  await deleteContactsFromLocal(context, await syncFromLocal(context));
}

// save special contact to device
void saveToDevice(BuildContext context, {String? tag}) async {
  List<MyContact> myContactList = tag == null
      ? await IsarService.isar.myContacts
          .filter()
          .tagContains("special", caseSensitive: false)
          .findAll()
      : await IsarService.isar.myContacts
          .filter()
          .tagEqualTo(tag, caseSensitive: false)
          .findAll();

  List<Contact> deviceList = myContactList
      .map((c) => (Contact(givenName: c.name, phones: [
            Item(label: "mobile", value: c.phoneNumber),
          ])))
      .toList();
  addContactToLocal(context, deviceList);
}

////////////////////////////////////////////////////////////////////////////////
// online cloud firebase databse
void handleBackup(BuildContext context) async {
  try {
    final contacts = await IsarService.getAllMyContacts();
    showSnackbar(context, "${contacts.length} Contacts Uploading...");

    final Map<String, dynamic> contactsJson = contacts.fold({}, (acc, contact) {
      acc[contact.phoneNumber] = [contact.name, contact.tag];
      return acc;
    });

    await CloudService.uploadContact(contactsJson);
    showSnackbar(context, "Backup Successful (${contacts.length} Contacts)");
  } catch (e) {
    showSnackbar(context, 'Backup Failed! \n $e');
  }
}

void handleDownload(BuildContext context) async {
  try {
    showSnackbar(context, 'Downloading...');
    Map contactsJson = await CloudService.downloadContact();
    // ignore duplicate
    Set<String> dbPhones = await IsarService.getUniquePhoneNumbers();
    List<MyContact> myContactList = [];
    for (final entry in contactsJson.entries) {
      if (!dbPhones.contains(entry.key)) {
        myContactList.add(MyContact(entry.key, entry.value[0], entry.value[1]));
      }
    }
    await IsarService.addMyContacts(myContactList);
    showSnackbar(context, "${myContactList.length}  New Contacts Downloaded");
  } catch (e) {
    showSnackbar(context, 'Download Failed! \n $e');
  }
}

////////////////////////////////////////////////////////////////////////////////
/// string formating
extension StringExtensions on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  String getPhoneNumber() {
    return replaceAll('+91', '').replaceAll(RegExp(r'\D'), '');
  }
}


////////////////////////////////////////////////////////////////////////////////
// alternate method
// contacts = (await FastContacts.getAllContacts()).cast<Contact>();
