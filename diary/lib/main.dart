import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> items = List.generate(20, (index) => 'Item ${index + 1}');
  List<String> selectedItems = [];

  bool isMultiSelectMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Multi-Select List'),
        actions: [
          isMultiSelectMode
              ? IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    setState(() {
                      items.removeWhere((item) => selectedItems.contains(item));
                      selectedItems.clear();
                      isMultiSelectMode = false;
                    });
                  },
                )
              : Container(),
        ],
      ),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return InkWell(
            onTap: () {
              if (isMultiSelectMode) {
                setState(() {
                  if (selectedItems.contains(item)) {
                    selectedItems.remove(item);
                  } else {
                    selectedItems.add(item);
                  }
                });
              }
            },
            onLongPress: () {
              setState(() {
                isMultiSelectMode = true;
                selectedItems.add(item);
              });
            },
            child: ListTile(
              title: Text(item),
              trailing: isMultiSelectMode
                  ? Icon(
                      selectedItems.contains(item)
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                    )
                  : null,
            ),
          );
        },
      ),
      floatingActionButton: isMultiSelectMode && selectedItems.isNotEmpty
          ? FloatingActionButton(
              onPressed: () {
                // Action to perform on selected items
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Selected Items'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: selectedItems
                            .map((item) => Text('- $item'))
                            .toList(),
                      ),
                    );
                  },
                );
              },
              child: const Icon(Icons.check),
            )
          : null,
    );
  }
}
