import 'package:diary/data/providers/tag_provider.dart';
import 'package:diary/utils/alert.dart';
import 'package:diary/widgets/common/contact_input.dart';
import 'package:flutter/material.dart';
import 'package:diary/data/models/contact.dart';
import 'package:diary/utils/utils.dart';
import 'package:diary/data/repositories/isar_service.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:provider/provider.dart';
import 'package:contacts_service/contacts_service.dart';

class ContactPageScreen extends StatefulWidget {
  final ValueNotifier<String> searchTextNotifier;

  const ContactPageScreen({super.key, required this.searchTextNotifier});

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
                    Text(_selectedContacts.length.toString()),
                    IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: _disableMultiSelect),
                    const Spacer(),
                    IconButton(
                        icon: const Icon(Icons.select_all),
                        onPressed: _selectAllContacts),
                    IconButton(
                        icon: const Icon(
                          Icons.copy,
                          size: 20,
                        ),
                        onPressed: _copytoClipBoard),
                    IconButton(
                        icon: const Icon(Icons.swap_horiz),
                        onPressed: _moveTag),
                    IconButton(
                        icon: const Icon(Icons.file_download_outlined),
                        onPressed: addtoLocal),
                    IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: _deleteSelectedContacts),
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
              valueListenable: widget.searchTextNotifier,
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
                      leading: CircleAvatar(
                        child: Text(contact.name[0]),
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
      floatingActionButton: const ContactInputWidget(),
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

  void _deleteSelectedContacts() {
    if (selectedTag != "trash") {
      _moveTag("trash");
    } else {
      List<int> ids = _selectedContacts.map((contact) => contact.id).toList();
      IsarService.deleteMyContacts(ids);
      showSnackbar(context, "${ids.length} Contacts Permanently Deleted!");

      _disableMultiSelect();
    }
  }

  void _moveTag([String? newTag]) async {
    newTag ??= await _tagPopup(); // show popup if new tag not given
    if (newTag != null && newTag != "all") {
      List<MyContact> updatedList =
          _selectedContacts.map((c) => (c..tag = newTag!)).toList();
      _disableMultiSelect();
      await IsarService.addMyContacts(updatedList);
      showSnackbar(context, "${updatedList.length} Contacts Moved to $newTag");
    }
  }

  void addtoLocal() async {
    List<Contact> updatedList = _selectedContacts
        .map((c) => (Contact(givenName: c.name, phones: [
              Item(label: "Mobile", value: c.phoneNumber),
            ])))
        .toList();
    addContactToLocal(context, updatedList);
    _disableMultiSelect();
  }

  void _filterTag() async {
    String? tag = await _tagPopup();
    if (tag != null) changeViewTag(tag);
  }

  void changeViewTag(String newTag) {
    if (newTag != selectedTag) {
      setState(() {
        selectedTag = newTag;
        getAllContacts = IsarService.watchContacts(newTag);
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

  Future<String?> _tagPopup() async {
    final tag = await showModalBottomSheet(
        context: context,
        builder: (context) {
          final controller = TextEditingController();
          return Container(
            height: 600,
            padding:
                const EdgeInsets.only(top: 20, left: 15, right: 15, bottom: 20),
            child: Column(
              children: [
                Padding(
                    padding: const EdgeInsets.all(20),
                    child: TextField(
                      controller: controller,
                      decoration: InputDecoration(
                        labelText: 'Add New Tag',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                      ),
                      onSubmitted: (value) {
                        context.read<TagProvider>().addTag(value);
                        controller.clear();
                      },
                    )),
                Expanded(child: TagList(selectedTag)),
              ],
            ),
          );
        });

    return tag;
  }
}

class TagList extends StatelessWidget {
  final String selectedTag;
  const TagList(this.selectedTag, {super.key});

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
          onTap: () => Navigator.pop(context, entry.key),
        );
      },
    );
  }
}
