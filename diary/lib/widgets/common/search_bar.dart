import 'package:diary/utils/utils.dart';
import 'package:flutter/material.dart';

class SearchBars extends StatefulWidget {
  final ValueNotifier<String> searchTextNotifier;

  const SearchBars({super.key, required this.searchTextNotifier});

  @override
  _SearchBarsState createState() => _SearchBarsState();
}

class _SearchBarsState extends State<SearchBars> {
  bool _isFocused = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    print('''_______________________________________-
        new search bar 000000 ''');
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
                  widget.searchTextNotifier.value = text;
                  print("inside see ${widget.searchTextNotifier.value}");
                },
                onTapOutside: (final event) {
                  FocusManager.instance.primaryFocus?.unfocus();
                },
                decoration: const InputDecoration(
                  hintText: "Search Contacts",
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: Icon(Icons.search),
                ),
                onTap: () {
                  print("focus me ");
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
                  widget.searchTextNotifier.value = "";
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
                  // color: Colors.grey,
                  color: Colors.grey[800],
                ),
                onPressed: syncFromLocal,
              ),
            if (!_isFocused)
              IconButton(
                icon: Icon(
                  Icons.cloud_upload_sharp,
                  color: Colors.grey[800],
                ),
                onPressed: handleBackup,
              ),
          ],
        ),
      ),
    );
  }
}
