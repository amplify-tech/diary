import 'package:isar/isar.dart';

part 'contact.g.dart';

@collection
class Contact {
  Id id = Isar.autoIncrement;
  late String name;
  late String phoneNumber;
  late String tag;
  late DateTime dateAdded;
}
