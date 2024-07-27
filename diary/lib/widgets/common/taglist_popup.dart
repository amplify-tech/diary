import 'package:diary/data/providers/tag_provider.dart';
import 'package:diary/widgets/common/taglist.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future<String?> showTagPopup(BuildContext context, String selectedTag) async {
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
