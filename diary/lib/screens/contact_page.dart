import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:diary/data/models/contact.dart';
import 'package:diary/utils/utils.dart';
import 'package:diary/data/repositories/isar_service.dart';

class ContactPageScreen extends StatelessWidget {
  const ContactPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MyContacts'),
      ),
      body: StreamBuilder<List<MyContact>>(
        stream: IsarService.watchContacts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No contacts found!'));
          }
          final contacts = snapshot.data!;
          return ListView.builder(
            itemCount: contacts.length,
            itemBuilder: (context, index) {
              final contact = contacts[index];
              print(contacts.length);
              return ListTile(
                leading:
                    CircleAvatar(child: Text(contact.name[0].toUpperCase())),
                title: Text(contact.name),
                subtitle: Text(DateFormat('h:mm:ss a d - MMM - yyyy')
                    .format(contact.dateAdded)),
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
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        IsarService.deleteMyContact(contact.id);
                      },
                    )
                  ],
                ),
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
}
