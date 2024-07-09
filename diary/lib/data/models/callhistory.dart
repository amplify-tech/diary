import 'package:isar/isar.dart';

part 'callhistory.g.dart';

@collection
class CallHistory {
  Id id = Isar.autoIncrement;
  @Index(unique: true, replace: true)
  late String phoneNumber;
  late String name;
  late int lastCall; // timestamp
  late int lastCallType;

  CallHistory(this.phoneNumber, this.name, this.lastCall, this.lastCallType);
}
