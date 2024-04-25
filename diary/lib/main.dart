
import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Contacts',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ContactListPage(),
    );
  }
}

class ContactListPage extends StatefulWidget {
  const ContactListPage({super.key});

  @override
  _ContactListPageState createState() => _ContactListPageState();
}

class _ContactListPageState extends State<ContactListPage> {
  late Iterable<Contact> _contacts = [];

  @override
  void initState() {
    super.initState();
    _getContacts();
  }

  Future<void> _getContacts() async {
    if (await Permission.contacts.request().isGranted) {
      final Iterable<Contact> contacts = await ContactsService.getContacts();
      setState(() {
        _contacts = contacts;
      });
    } else {
      // Handle case when permission is denied
    }
  }

  Future<void> _deleteAllContacts() async {
    for (final contact in _contacts) {
      await ContactsService.deleteContact(contact);
    }
    setState(() {
      _contacts = [];
    });
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts'),
      ),
      body: _contacts != null
          ? ListView.builder(
              itemCount: _contacts.length,
              itemBuilder: (context, index) {
                Contact contact = _contacts.elementAt(index);
                return ListTile(
                  leading: CircleAvatar(
                    child: Text(contact.initials()),
                  ),
                  title: Text(contact.displayName ?? ''),
                  subtitle: Text((contact.phones?.length ?? 0) > 0
                      ? contact.phones!.elementAt(0).value ?? ''
                      : ''),
                );
              },
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _deleteAllContacts,
        tooltip: 'Delete All Contacts',
        child: const Icon(Icons.delete),
      ),
    );
  }
}
