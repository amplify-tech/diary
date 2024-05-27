import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:diary/data/models/contact.dart';
import 'package:diary/utils/utils.dart';
import 'package:diary/data/repositories/isar_service.dart';
// import 'package:isar/isar.dart';

class ContactPageScreen extends StatefulWidget {
  const ContactPageScreen({super.key});

  @override
  _ContactPageScreenState createState() => _ContactPageScreenState();
}

class _ContactPageScreenState extends State<ContactPageScreen> {
  bool _isMultiSelectEnabled = false;
  final List<MyContact> _selectedContacts = [];
  Stream<List<MyContact>> getAllContacts = IsarService.watchContacts();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MyContacts'),
        actions: _isMultiSelectEnabled
            ? [
                IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: _deleteSelectedContacts),
                IconButton(
                    icon: const Icon(Icons.tag),
                    onPressed: _updateTagsForSelectedContacts),
              ]
            : null,
      ),
      body: StreamBuilder<List<MyContact>>(
        stream: getAllContacts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No contacts found!'));
          }
          final contacts = snapshot.data!;
          print(contacts.length);
          return ListView.builder(
            itemCount: contacts.length,
            itemBuilder: (context, index) {
              final contact = contacts[index];
              return ListTile(
                selected: _selectedContacts.contains(contact),
                leading: CircleAvatar(
                  child: Text(contact.name[0].toUpperCase()),
                ),
                title: Text(contact.name),
                subtitle: Text(
                    "${DateFormat('h:mm:ss a d - MMM - yyyy').format(contact.dateAdded)} ${contact.tag}"),
                trailing: Wrap(
                  spacing: 18,
                  children: <Widget>[
                    IconButton(
                      icon: const Icon(Icons.call),
                      onPressed: () => callNumber(contact.phoneNumber),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chat_rounded),
                      onPressed: () => launchWhatsApp(contact.phoneNumber),
                    ),
                  ],
                ),
                onLongPress: () {
                  setState(() {
                    _isMultiSelectEnabled = true;
                    if (!_selectedContacts.contains(contact)) {
                      _selectedContacts.add(contact);
                    }
                  });
                },
                onTap: () {
                  if (_isMultiSelectEnabled) {
                    setState(() {
                      if (_selectedContacts.contains(contact)) {
                        _selectedContacts.remove(contact);
                      } else {
                        _selectedContacts.add(contact);
                      }
                    });
                  }
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          IsarService.addMyContact(MyContact("857656", "Aaaaa", "relative"));
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _deleteSelectedContacts() {
    List<int> ids = _selectedContacts.map((contact) => contact.id).toList();
    print("deleting");
    IsarService.deleteMyContacts(ids);
    setState(() {
      _isMultiSelectEnabled = false;
      _selectedContacts.clear();
    });
  }

  void _updateTagsForSelectedContacts() {
    for (final contact in _selectedContacts) {
      contact.tag = "${DateTime.now()}";
    }
    print("updating");
    print(_selectedContacts[0].id);
    IsarService.addMyContacts(_selectedContacts);
    setState(() {
      _isMultiSelectEnabled = false;
      _selectedContacts.clear();
    });
  }
}
