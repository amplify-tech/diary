import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'models/contact.dart';

class IsarService {
  late Future<Isar> db;

  IsarService() {
    db = openDB();
  }

  Future<Isar> openDB() async {
    if (Isar.instanceNames.isEmpty) {
      final dir = await getApplicationDocumentsDirectory();
      final isar = await Isar.open(
        [ContactSchema],
        directory: dir.path,
        inspector: true,
      );

      return isar;
    }

    return Future.value(Isar.getInstance());
  }

  Future<void> addContact(Contact contact) async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.contacts.put(contact);
    });
  }

  Future<List<Contact>> getContacts() async {
    final isar = await db;
    return isar.contacts.where().findAll();
  }
}
