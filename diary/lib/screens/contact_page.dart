import 'package:diary/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class ContactPageScreen extends StatefulWidget {
  const ContactPageScreen({super.key});

  @override
  State<ContactPageScreen> createState() => _ContactPageScreenState();
}

class _ContactPageScreenState extends State<ContactPageScreen> {
  List<Contact>? _contacts;

  @override
  void initState() {
    super.initState();
    _fetchContacts();
  }

  Future _fetchContacts() async {
    final contacts = await fetchContacts();
    print(contacts);
    setState(() => _contacts = contacts);
  }

  @override
  Widget build(BuildContext context) {
    if (_contacts == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      itemCount: _contacts!.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: CircleAvatar(
            child: _contacts![index].displayName.isNotEmpty
                ? Text(_contacts![index].displayName[0])
                : const Icon(Icons.person_rounded),
          ),
          title: Text(_contacts![index].displayName),
          subtitle: Wrap(
            spacing: 12,
            children: <Widget>[
              Text(_contacts![index].phones.isNotEmpty
                  ? _contacts![index].phones.first.number
                  : '(none)'),
            ],
          ),
          trailing: Wrap(
            spacing: 18,
            children: <Widget>[
              IconButton(
                icon: const Icon(Icons.call),
                onPressed: () =>
                    callNumber(_contacts![index].phones.first.number),
              ),
              IconButton(
                icon: const Icon(Icons.chat_rounded),
                onPressed: () =>
                    launchWhatsApp(_contacts![index].phones.first.number),
              ),
            ],
          ),
        );
      },
    );
  }
}
