import 'package:diary/data/providers/tag_provider.dart';
import 'package:diary/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
          trailing: Wrap(
              spacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: <Widget>[
                if (selectedTag == entry.key) const Icon(Icons.check),
                Text(entry.value.toString(), textAlign: TextAlign.center),
                IconButton(
                    icon: const Icon(Icons.file_download_outlined),
                    onPressed: () => saveToDevice(context, tag: entry.key)),
              ]),
          onTap: () => Navigator.pop(context, entry.key),
        );
      },
    );
  }
}
