import 'package:isar/isar.dart';

part 'contact.g.dart';

@collection
class MyContact {
  Id id = Isar.autoIncrement;
  late String name;
  late String phoneNumber;
  late String tag;
  late DateTime dateAdded = DateTime.now();
  MyContact(this.name, this.phoneNumber, this.tag);
}
