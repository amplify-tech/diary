import 'package:isar/isar.dart';

part 'contact.g.dart';

@collection
class MyContact {
  Id id = Isar.autoIncrement;
  @Index(unique: true, replace: true)
  late String phoneNumber;
  late String name;
  late String tag;
  late DateTime dateAdded = DateTime.now();

  MyContact(this.phoneNumber, this.name, this.tag);
}
