import 'package:flutter/material.dart';

class MetaProvider with ChangeNotifier {
  int _currentPageIndex = 1;
  int get currentPageIndex => _currentPageIndex;

  void updatePage(int newPage) {
    _currentPageIndex = newPage;
    notifyListeners();
  }
}
