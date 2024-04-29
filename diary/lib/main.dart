import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Multi Selection List',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MultiSelectionList(),
    );
  }
}

class MultiSelectionList extends StatefulWidget {
  const MultiSelectionList({super.key});

  @override
  _MultiSelectionListState createState() => _MultiSelectionListState();
}

class _MultiSelectionListState extends State<MultiSelectionList> {
  List<String> items = List.generate(20, (index) => 'Item $index');
  List<String> selectedItems = [];
  bool isMultiSelecting = false;

  void _toggleSelection(String item) {
    if (selectedItems.contains(item)) {
      setState(() {
        selectedItems.remove(item);
      });
    } else {
      setState(() {
        selectedItems.add(item);
      });
    }
  }

  void _deleteSelectedItems() {
    setState(() {
      items.removeWhere((item) => selectedItems.contains(item));
      selectedItems.clear();
      isMultiSelecting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Multi Selection List'),
        actions: [
          isMultiSelecting
              ? IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: _deleteSelectedItems,
                )
              : const SizedBox.shrink(),
        ],
      ),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return InkWell(
            onTap: () {
              if (isMultiSelecting) {
                _toggleSelection(item);
              }
            },
            onLongPress: () {
              setState(() {
                isMultiSelecting = true;
                selectedItems.add(item);
              });
            },
            child: ListTile(
              title: Text(item),
              leading: isMultiSelecting
                  ? Checkbox(
                      value: selectedItems.contains(item),
                      onChanged: (_) {
                        _toggleSelection(item);
                      },
                    )
                  : null,
              trailing: isMultiSelecting && selectedItems.contains(item)
                  ? const Icon(Icons.check)
                  : null,
            ),
          );
        },
      ),
    );
  }
}
