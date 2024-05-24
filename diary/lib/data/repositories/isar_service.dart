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

  Future<void> addMyContacts(List<MyContact> contacts) async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.myContacts.putAll(contacts);
    });
  }

  Future<void> deleteMyContact(int id) async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.myContacts.delete(id);
    });
  }

  Stream<List<MyContact>> getMyContacts() async* {
    print("isar fetch new");

    final isar = await db;
    yield* isar.myContacts.where().watch(fireImmediately: true);
  }

  Future<List<MyContact>> getAllMyContacts() async {
    final isar = await db;
    return await isar.myContacts.where().findAll();
  }

  Future<void> updateMyContact(MyContact contact) async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.myContacts.put(contact);
    });
  }

  Future<MyContact?> getMyContactById(int id) async {
    final isar = await db;
    return await isar.myContacts.get(id);
  }
}
