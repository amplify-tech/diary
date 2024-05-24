import 'package:diary/data/repositories/isar_service.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
// import 'package:provider/provider.dart';

class IsarProvider with ChangeNotifier {
  final IsarService _isarService;

  IsarProvider(this._isarService);

  Future<Isar> get db async {
    return _isarService.db;
  }

  // Add your provider methods here, e.g., fetch data, update data
}
