// ignore_for_file: use_build_context_synchronously

import 'package:contacts_service/contacts_service.dart';
import 'package:diary/utils/alert.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

// ContactsService
Future<List<Contact>> getContactsFromLocal(BuildContext context) async {
  try {
    if (await Permission.contacts.request().isGranted) {
      return ContactsService.getContacts(withThumbnails: false);
    }
  } catch (e) {
    showSnackbar(context, 'Error fetching contacts: \n $e');
  }
  return [];
}

Future<void> deleteContactsFromLocal(
    BuildContext context, List<Contact> contactList) async {
  showSnackbar(context, "${contactList.length} Device Contact Deleting...");
  for (final contact in contactList) {
    try {
      await ContactsService.deleteContact(contact);
    } catch (e) {
      showSnackbar(context,
          'Error while deleting contacts: ${contact.displayName} \n $e');
    }
  }
  showSnackbar(context, "${contactList.length} Device Contact Deleted!");
}

void addContactToLocal(BuildContext context, List<Contact> contactList) async {
  showSnackbar(context, "${contactList.length} Contacts Saving...");
  for (final contact in contactList) {
    try {
      await ContactsService.addContact(contact);
    } catch (e) {
      showSnackbar(
          context, 'Error while adding contacts: ${contact.givenName} \n $e');
    }
  }
  showSnackbar(context, "${contactList.length} Contacts Saved!");
}

void updateContactToLocal(
    BuildContext context, String phoneNumber, String name) async {
  try {
    final oldContacts = await ContactsService.getContactsForPhone(phoneNumber);
    for (final contact in oldContacts) {
      ContactsService.deleteContact(contact);
    }
    await ContactsService.addContact(Contact(givenName: name, phones: [
      Item(label: "mobile", value: phoneNumber),
    ]));
    showSnackbar(context, "$name Contact Updated!");
  } catch (e) {
    showSnackbar(context, 'Error while updating contacts: $name \n $e');
  }
}
