import 'package:diary/data/models/contact.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class IsarService {
  static late Isar _isar;
  static Isar get isar => _isar;

  static Future<void> initialize() async {
    _isar = Isar.getInstance() ??
        await Isar.open(
          [MyContactSchema],
          directory: (await getApplicationDocumentsDirectory()).path,
          inspector: true,
        );
  }

  static Future<void> addMyContact(MyContact contact) async {
    await _isar.writeTxn(() async {
      await _isar.myContacts.put(contact);
    });
  }

  static Future<void> addMyContacts(List<MyContact> contacts) async {
    print("adding");
    await _isar.writeTxn(() async {
      print("adding ${contacts.length}");
      await _isar.myContacts.putAll(contacts);
      print("added ${contacts.length}");
    });
  }

  static Future<void> deleteMyContacts(List<int> ids) async {
    await _isar.writeTxn(() async {
      await _isar.myContacts.deleteAll(ids);
    });
  }

  static Stream<List<MyContact>> watchContacts(String tag) {
    print("_isar fetch new");
    return tag == "all"
        ? _isar.myContacts.where().sortByName().watch(fireImmediately: true)
        : _isar.myContacts
            .filter()
            .tagEqualTo(tag)
            .sortByName()
            .watch(fireImmediately: true);
  }

  static Future<List<MyContact>> getAllMyContacts() async {
    return await _isar.myContacts.where().findAll();
  }

  static Future<void> updateMyContact(MyContact contact) async {
    await _isar.writeTxn(() async {
      await _isar.myContacts.put(contact);
    });
  }

  static Future<MyContact?> getMyContactById(int id) async {
    return await _isar.myContacts.get(id);
  }
}
