import 'package:flutter/material.dart';
import 'package:diary/data/repositories/isar_service.dart';
import 'package:diary/data/models/contact.dart';

class MyContactProvider with ChangeNotifier {
  final IsarService _isarService;

  MyContactProvider(this._isarService);

  Future<void> addMyContact(MyContact contact) async {
    await _isarService.addMyContact(contact);
    // notifyListeners();
  }

  Future<void> deleteMyContact(int id) async {
    await _isarService.deleteMyContact(id);
    // notifyListeners();
  }

  Stream<List<MyContact>> getMyContacts() {
    print("provider fetch new");
    return _isarService.getMyContacts();
  }

  Future<List<MyContact>> getAllMyContacts() async {
    return await _isarService.getAllMyContacts();
  }

  Future<void> updateMyContact(MyContact contact) async {
    await _isarService.updateMyContact(contact);
    // notifyListeners();
  }

  Future<MyContact?> getMyContactById(int id) async {
    return await _isarService.getMyContactById(id);
  }
}
