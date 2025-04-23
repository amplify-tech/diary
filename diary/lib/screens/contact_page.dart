// ignore_for_file: use_build_context_synchronously

import 'package:diary/utils/alert.dart';
import 'package:diary/utils/device_contact.dart';
import 'package:diary/widgets/common/contact_input_popup.dart';
import 'package:diary/widgets/common/search_bar.dart';
import 'package:diary/widgets/common/taglist_popup.dart';
import 'package:flutter/material.dart';
import 'package:diary/data/models/contact.dart';
import 'package:diary/utils/utils.dart';
import 'package:diary/data/repositories/isar_service.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:contacts_service/contacts_service.dart';

class ContactPageScreen extends StatefulWidget {
  const ContactPageScreen({super.key});

  @override
  State<ContactPageScreen> createState() => _ContactPageScreenState();
}

class _ContactPageScreenState extends State<ContactPageScreen> {
  bool _isMultiSelectEnabled = false;
  String selectedTag = 'all';
  late Stream<List<MyContact>> getAllContacts =
      IsarService.watchContacts("all");
  late List<MyContact> filteredContacts;
  final List<MyContact> _selectedContacts = [];

  @override
  void initState() {
    super.initState();
    BackButtonInterceptor.add(_myInterceptor);
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(_myInterceptor);
    super.dispose();
  }

  bool _myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    if (_isMultiSelectEnabled) {
      _disableMultiSelect();
      return true; // Prevent default back button
    }
    return false; // Allow
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 52,
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        title: Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            children: _isMultiSelectEnabled
                ? [
                    Text(_selectedContacts.length.toString(),
                        style: TextStyle(
                            fontSize: _selectedContacts.length > 9 ? 14 : 20)),
                    IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: _disableMultiSelect),
                    const Spacer(),
                    IconButton(
                        icon: const Icon(Icons.select_all),
                        onPressed: _selectAllContacts),
                    IconButton(
                        icon: const Icon(Icons.copy, size: 18),
                        onPressed: _copytoClipBoard),
                    IconButton(
                        icon: const Icon(Icons.swap_horiz),
                        onPressed: _moveTag),
                    IconButton(
                        icon: const Icon(Icons.delete_outline_rounded),
                        onPressed: _deleteFromIsar),
                    IconButton(
                        icon: const Icon(Icons.file_download_outlined),
                        onPressed: _addtoLocal),
                    IconButton(
                        icon: const Icon(Icons.delete_rounded),
                        onPressed: _deleteFromLocal),
                  ]
                : [
                    TextButton.icon(
                        label: Text(selectedTag),
                        iconAlignment: IconAlignment.end,
                        icon: const Icon(Icons.keyboard_arrow_down_rounded),
                        onPressed: _filterTag),
                  ],
          ),
        ),
      ),
      body: StreamBuilder<List<MyContact>>(
        stream: getAllContacts,
        builder: (context, snapshot) {
          // if (snapshot.connectionState == ConnectionState.waiting) {
          //   return Container();
          // }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Container();
          }

          return ValueListenableBuilder<String>(
              valueListenable: SearchBars.searchText,
              builder: (context, searchText, _) {
                if (searchText == "") {
                  filteredContacts = snapshot.data!;
                } else if (searchText.getPhoneNumber() != "") {
                  filteredContacts = snapshot.data!.where((contact) {
                    return contact.phoneNumber
                        .contains(searchText.getPhoneNumber());
                  }).toList();
                } else {
                  filteredContacts = snapshot.data!.where((contact) {
                    return contact.name
                        .toLowerCase()
                        .contains(searchText.toLowerCase());
                  }).toList();
                }

                return ListView.builder(
                  itemCount: filteredContacts.length,
                  itemBuilder: (context, index) {
                    final contact = filteredContacts[index];
                    return ListTile(
                      selected: _selectedContacts.contains(contact),
                      leading: IconButton(
                        icon: CircleAvatar(
                          child: Text(contact.name[0]),
                        ),
                        onPressed: () => _isMultiSelectEnabled
                            ? null
                            : showEditContactPopup(context, contact),
                      ),
                      title: Text(contact.name),
                      subtitle: Text(contact.phoneNumber),
                      trailing: Wrap(
                        spacing: 18,
                        children: <Widget>[
                          IconButton(
                            icon: const Icon(Icons.call),
                            onPressed: () => callNumber(contact.phoneNumber),
                          ),
                          IconButton(
                            icon: const Icon(Icons.chat_rounded),
                            onPressed: () =>
                                launchWhatsApp(contact.phoneNumber),
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
              });
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showEditContactPopup(context, null), // add contact
        child: const Icon(Icons.add),
      ),
    );
  }

  void _disableMultiSelect() {
    setState(() {
      _isMultiSelectEnabled = false;
      _selectedContacts.clear();
    });
  }

  void _selectAllContacts() {
    setState(() {
      _selectedContacts.clear();
      _selectedContacts.addAll(filteredContacts);
    });
  }

  void _moveTag([String? newTag]) async {
    newTag ??= await showTagPopup(
        context, selectedTag); // show popup if new tag not given
    if (newTag != null && newTag != "all") {
      List<MyContact> updatedList =
          _selectedContacts.map((c) => (c..tag = newTag!)).toList();
      _disableMultiSelect();
      await IsarService.addMyContacts(updatedList);
      showSnackbar(context, "${updatedList.length} Contacts Moved to $newTag");
    }
  }

  void _filterTag() async {
    String? tag = await showTagPopup(context, selectedTag);
    if (tag != null && tag != selectedTag) {
      setState(() {
        selectedTag = tag;
        getAllContacts = IsarService.watchContacts(tag);
      });
    }
  }

  void _copytoClipBoard() {
    if (_selectedContacts.isNotEmpty) {
      String copyText = _selectedContacts.length == 1
          ? _selectedContacts[0].phoneNumber
          : _selectedContacts.join(" \n");
      copytoClipBoard(copyText, "Contact Copied");
    }
  }

  void _addtoLocal() async {
    List<Contact> updatedList = _selectedContacts
        .map((c) => (Contact(givenName: c.name, phones: [
              Item(label: "mobile", value: c.phoneNumber),
            ])))
        .toList();
    addContactToLocal(context, updatedList);
    _disableMultiSelect();
  }

  void _deleteFromLocal() async {
    List<Contact> contactList = [];
    for (final c in _selectedContacts) {
      final deviceContact = await ContactsService.getContactsForPhone(
          c.phoneNumber,
          withThumbnails: false);
      contactList.addAll(deviceContact);
    }
    deleteContactsFromLocal(context, contactList);
  }

  void _deleteFromIsar() {
    if (selectedTag != "trash") {
      _moveTag("trash");
    } else {
      List<int> ids = _selectedContacts.map((contact) => contact.id).toList();
      IsarService.deleteMyContacts(ids);
      showSnackbar(context, "${ids.length} Contacts Permanently Deleted!");
      _disableMultiSelect();
    }
  }
}
