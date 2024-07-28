// ignore_for_file: use_build_context_synchronously

import 'package:contacts_service/contacts_service.dart';
import 'package:diary/data/models/contact.dart';
import 'package:diary/data/repositories/isar_service.dart';
import 'package:diary/utils/alert.dart';
import 'package:diary/utils/device_contact.dart';
import 'package:diary/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:diary/data/providers/tag_provider.dart';

class ContactInputWidget extends StatefulWidget {
  final MyContact? givenContact;

  const ContactInputWidget({super.key, this.givenContact});

  @override
  State<ContactInputWidget> createState() => _ContactInputWidgetState();
}

class _ContactInputWidgetState extends State<ContactInputWidget> {
  final _formKey = GlobalKey<FormState>();
  final _dropDownKey = GlobalKey<FormFieldState>();
  final _phoneNumberController = TextEditingController();
  final _nameController = TextEditingController();
  String _selectedTag = "all";
  List<DropdownMenuItem<String>> dropdownItems = [];

  @override
  void initState() {
    super.initState();
    // in case of edit contact
    if (widget.givenContact != null) {
      _phoneNumberController.text = widget.givenContact!.phoneNumber;
      _nameController.text = widget.givenContact!.name;
      _selectedTag = widget.givenContact!.tag;
    }
    // dropdown items same as list of tag in the provider
    final tagList = context.read<TagProvider>().tagCountMap.keys;
    dropdownItems = tagList
        .map((tag) => DropdownMenuItem(value: tag, child: Text(tag)))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 550,
      child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 30),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  onTapOutside: (final event) {
                    FocusScope.of(context).unfocus();
                  },
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 20, vertical: 13),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a valid phone number';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  controller: _phoneNumberController,
                  autofocus: widget.givenContact == null,
                ),
                const SizedBox(height: 22),
                TextFormField(
                  onTapOutside: (final event) {
                    FocusScope.of(context).unfocus();
                  },
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 20, vertical: 13),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                  controller: _nameController,
                  autofocus: widget.givenContact != null,
                ),
                const SizedBox(height: 22),
                DropdownButtonFormField(
                  key: _dropDownKey,
                  decoration: const InputDecoration(
                    labelText: 'Tag',
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 20, vertical: 13),
                  ),
                  value: _selectedTag,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedTag = newValue!;
                    });
                  },
                  items: dropdownItems,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      onPressed: () => savetoIsar(true),
                      child: const Text('Save to Device'),
                    ),
                    ElevatedButton(
                      onPressed: savetoIsar,
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ],
            ),
          )),
    );
  }

  void savetoIsar([bool? savetoDevice]) async {
    if (_formKey.currentState!.validate()) {
      String newTag = _selectedTag == "all" ? "new added" : _selectedTag;

      if (savetoDevice != null) {
        if (widget.givenContact != null) {
          final deviceContact = await ContactsService.getContactsForPhone(
            widget.givenContact!.phoneNumber,
          );
          deleteContactsFromLocal(context, deviceContact);
        }
        ContactsService.addContact(
            Contact(givenName: _nameController.text, phones: [
          Item(label: "mobile", value: _phoneNumberController.text),
        ]));
      }

      IsarService.addMyContact(MyContact(_phoneNumberController.text,
          _nameController.text.capitalize(), newTag));

      showSnackbar(
          context,
          widget.givenContact != null
              ? "${widget.givenContact!.name} Contact Updated!"
              : "${_nameController.text} Contact Added!");

      _phoneNumberController.clear();
      _nameController.clear();
      Navigator.of(context).pop();
    }
  }
}
