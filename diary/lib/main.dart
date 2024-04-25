import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Contact Saving App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ContactSavePage(),
    );
  }
}

class ContactSavePage extends StatefulWidget {
  const ContactSavePage({super.key});

  @override
  _ContactSavePageState createState() => _ContactSavePageState();
}

class _ContactSavePageState extends State<ContactSavePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Save Contact'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
              ),
            ),
            const SizedBox(height: 20.0),
            TextField(
              controller: _phoneNumberController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
              ),
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: _saveContact,
              child: const Text('Save Contact'),
            ),
          ],
        ),
      ),
    );
  }

  void _saveContact() async {
    if (_nameController.text.isNotEmpty &&
        _phoneNumberController.text.isNotEmpty) {
      final newContact = Contact()
        ..name.first = _nameController.text
        ..phones = [Phone(_phoneNumberController.text)];

      try {
        await newContact.insert();
        _showSnackbar('Contact saved successfully');
        // _nameController.clear();
        // _phoneNumberController.clear();
      } catch (e) {
        _showSnackbar('Failed to save contact');
        print(e);
      }
    } else {
      _showSnackbar('Please enter name and phone number');
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 2),
    ));
  }
}
