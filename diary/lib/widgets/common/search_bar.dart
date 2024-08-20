import 'package:diary/data/providers/meta_provider.dart';
import 'package:diary/screens/contact_navigation.dart';
import 'package:diary/screens/contact_page.dart';
import 'package:diary/utils/utils.dart';
import 'package:diary/widgets/common/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SearchBars extends StatefulWidget {
  static final ValueNotifier<String> searchText = ValueNotifier<String>('');
  // static is imp to share state across widget
  const SearchBars({super.key});

  @override
  State<SearchBars> createState() => _SearchBarsState();
}

class _SearchBarsState extends State<SearchBars> {
  bool _isFocused = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 2, right: 2, top: 8),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(50),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                onChanged: (text) {
                  SearchBars.searchText.value = text;
                },
                onTapOutside: (final event) {
                  FocusManager.instance.primaryFocus?.unfocus();
                },
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.only(top: 2),
                  hintText: "Search Contacts",
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: Icon(Icons.search),
                ),
                onTap: () {
                  if (ContactNavigation.screens[2] is SizedBox) {
                    ContactNavigation.screens[2] = const ContactPageScreen();
                  }
                  context.read<MetaProvider>().updatePage(2);
                  setState(() {
                    _isFocused = true;
                  });
                },
              ),
            ),
            if (_isFocused)
              IconButton(
                icon: Icon(
                  Icons.clear_rounded,
                  color: Colors.grey[800],
                ),
                onPressed: () {
                  SearchBars.searchText.value = "";
                  _searchController.clear();
                  FocusManager.instance.primaryFocus?.unfocus();
                  setState(() {
                    _isFocused = false;
                  });
                },
              ),
            if (!_isFocused)
              IconButton(
                icon: Icon(
                  Icons.sync,
                  color: Colors.grey[800],
                ),
                onPressed: () => syncFromLocal(context),
              ),
            if (!_isFocused)
              IconButton(
                icon: Icon(
                  Icons.cloud_upload_sharp,
                  color: Colors.grey[800],
                ),
                onPressed: () => _handleBackupLogin(context),
              ),
          ],
        ),
      ),
    );
  }

  void _handleBackupLogin(BuildContext context) {
    if (FirebaseAuth.instance.currentUser != null) {
      handleBackup(context);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }
}
