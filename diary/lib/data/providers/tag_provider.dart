import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:diary/data/models/contact.dart';
import 'package:diary/data/repositories/isar_service.dart';

class TagProvider with ChangeNotifier {
  final Map<String, int> _tagCountMap = {};
  Map<String, int> get tagCountMap => _tagCountMap;

  TagProvider() {
    IsarService.isar.myContacts
        .where()
        .watch(fireImmediately: true)
        .listen((data) {
      _tagCountMap.clear();
      _tagCountMap["all"] = data.length;
      for (var contact in data) {
        _tagCountMap[contact.tag] = (_tagCountMap[contact.tag] ?? 0) + 1;
      }
      notifyListeners();
    });
  }

  void addTag(String tag) {
    if (!_tagCountMap.keys.contains(tag)) {
      _tagCountMap[tag] = 0;
      // notifyListeners();
    }
  }
}
