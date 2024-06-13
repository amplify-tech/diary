import 'package:contacts_service/contacts_service.dart';
import 'package:diary/data/models/contact.dart';
import 'package:diary/data/repositories/isar_service.dart';
import 'package:diary/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:diary/data/providers/tag_provider.dart';

class ContactInputWidget extends StatefulWidget {
  const ContactInputWidget({super.key});

  @override
  State<ContactInputWidget> createState() => _ContactInputWidgetState();
}

class _ContactInputWidgetState extends State<ContactInputWidget> {
  final _formKey = GlobalKey<FormState>();
  final _dropDownKey = GlobalKey<FormFieldState>();
  final _phoneNumberController = TextEditingController();
  final _nameController = TextEditingController();
  String _selectedTag = "new added";

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        _showBottomSheet(context);
      },
      child: const Icon(Icons.add),
    );
  }

  void _showBottomSheet(BuildContext context) {
    final tagList = context.read<TagProvider>().tagCountMap.keys;
    List<DropdownMenuItem<String>> dropdownItems = tagList
        .map((tag) => DropdownMenuItem(value: tag, child: Text(tag)))
        .toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
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
                      autofocus: true,
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
      },
    );
  }

  void savetoIsar([bool? savetoDevice]) {
    if (_formKey.currentState!.validate()) {
      String newTag = _selectedTag == "all" ? "new added" : _selectedTag;

      if (savetoDevice != null) {
        ContactsService.addContact(
            Contact(givenName: _nameController.text, phones: [
          Item(label: "Mobile", value: _phoneNumberController.text),
        ]));
        print("saved to device ");
      }

      IsarService.addMyContact(MyContact(_phoneNumberController.text,
          _nameController.text.capitalize(), newTag));
      print(
          'Contact: added ${_nameController.text}, ${_phoneNumberController.text} $_selectedTag');

      _phoneNumberController.clear();
      _nameController.clear();
      Navigator.of(context).pop();
    }
  }
}
