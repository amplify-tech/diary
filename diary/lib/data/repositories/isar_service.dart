import 'package:diary/data/models/contact.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class IsarService {
  late Future<Isar> db;

  IsarService() {
    db = openDB();
  }

  Future<Isar> openDB() async {
    if (Isar.instanceNames.isEmpty) {
      final dir = await getApplicationDocumentsDirectory();
      final isar = await Isar.open(
        [MyContactSchema],
        directory: dir.path,
        inspector: true,
      );

      return isar;
    }

    return Future.value(Isar.getInstance());
  }

  Future<void> addMyContact(MyContact contact) async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.myContacts.put(contact);
    });
  }

  Future<List<MyContact>> getMyContacts() async {
    final isar = await db;
    return isar.myContacts.where().findAll();
  }
}
