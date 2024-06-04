import 'package:diary/data/providers/tag_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:diary/data/models/contact.dart';
import 'package:diary/utils/utils.dart';
import 'package:diary/data/repositories/isar_service.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:provider/provider.dart';

class ContactPageScreen extends StatefulWidget {
  const ContactPageScreen({super.key});

  @override
  State<ContactPageScreen> createState() => _ContactPageScreenState();
}

class _ContactPageScreenState extends State<ContactPageScreen> {
  bool _isMultiSelectEnabled = false;
  String selectedTag = 'all';
  final List<MyContact> _selectedContacts = [];
  late Stream<List<MyContact>> getAllContacts;

  @override
  void initState() {
    super.initState();
    getAllContacts = IsarService.watchContacts(selectedTag);
    BackButtonInterceptor.add(_myInterceptor);
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(_myInterceptor);
    super.dispose();
  }

  bool _myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    print("back button");
    if (_isMultiSelectEnabled) {
      print("back button in me");

      setState(() {
        _isMultiSelectEnabled = false;
        _selectedContacts.clear();
      });
      return true; // Prevent default back button
    }
    print("back button out");
    return false; // Allow
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(selectedTag),
        actions: _isMultiSelectEnabled
            ? [
                IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: _deleteSelectedContacts),
                IconButton(icon: const Icon(Icons.tag), onPressed: _moveTag),
              ]
            : [
                IconButton(
                    icon: const Icon(Icons.filter_list), onPressed: _filterTag),
              ],
      ),
      body: StreamBuilder<List<MyContact>>(
        stream: getAllContacts,
        builder: (context, snapshot) {
          // if (snapshot.connectionState == ConnectionState.waiting) {
          //   return Container();
          // }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No contacts found!'));
          }
          final contacts = snapshot.data!;
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
                    "${DateFormat('h:mm:ss').format(contact.dateAdded)} ${contact.tag}"),
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

  Future<String?> _tagPopup() async {
    final tag = await showModalBottomSheet<String>(
      context: context,
      builder: (context) {
        return TagFilterBottomSheet(
          selectedTag: selectedTag,
          onTagSelected: (tag) {
            Navigator.pop(context, tag);
          },
        );
      },
    );
    print(tag);
    return tag;
  }

  void _filterTag() async {
    print("filtering 1");
    String? tag = await _tagPopup();
    if (tag != null) {
      setState(() {
        selectedTag = tag;
        getAllContacts = IsarService.watchContacts(selectedTag);
      });
    }
  }

  void _moveTag() async {
    print("updating 1");
    String? tag = await _tagPopup();
    if (tag != null && tag != "all") {
      List<MyContact> updatedList =
          _selectedContacts.map((c) => (c..tag = tag)).toList();
      print("updating");
      IsarService.addMyContacts(updatedList);
      setState(() {
        _isMultiSelectEnabled = false;
        _selectedContacts.clear();
      });
    }
  }
}

class TagFilterBottomSheet extends StatelessWidget {
  final String selectedTag;
  final Function(String) onTagSelected;

  const TagFilterBottomSheet(
      {super.key, required this.selectedTag, required this.onTagSelected});

  @override
  Widget build(BuildContext context) {
    final tagCountMap = context.watch<TagProvider>().tagCountMap;
    return ListView.builder(
      itemCount: tagCountMap.keys.length,
      itemBuilder: (context, index) {
        final entry = tagCountMap.entries.elementAt(index);
        return ListTile(
          title: Text(entry.key),
          trailing: Wrap(spacing: 12, children: <Widget>[
            Visibility(
              visible: selectedTag == entry.key,
              child: const Icon(Icons.check),
            ),
            Text(entry.value.toString()),
          ]),
          onTap: () => onTagSelected(entry.key),
        );
      },
    );
  }
}
