import 'package:call_log/call_log.dart';
import 'package:diary/data/models/callhistory.dart';
import 'package:diary/data/models/contact.dart';
import 'package:diary/data/repositories/isar_service.dart';
import 'package:diary/utils/utils.dart';
import 'package:isar/isar.dart';
import 'package:permission_handler/permission_handler.dart';

final callTypeMap = {
  CallType.missed: 0,
  CallType.incoming: 1,
  CallType.outgoing: 2,
};
/////////////////////////////////////////////////////////////////////
// call log
Future<void> syncCallLog() async {
  try {
    if (await Permission.phone.request().isGranted) {
      print(" fetching  call log");
      int? maxCallTime =
          await IsarService.isar.callHistorys.where().lastCallProperty().max();

      print(maxCallTime);

      List<CallLogEntry> newCall =
          (await CallLog.query(dateFrom: maxCallTime)).toList();
      print(" fetched  call log ${newCall.length}");
      List<CallHistory> newCallHistory = [];

      for (final callLog in newCall.reversed) {
        print(callLog.callType);
        String phoneNumber = callLog.number!.getPhoneNumber();

        String? name = callLog.name != callLog.number ? callLog.name : null;

        if (name == null || name.isEmpty) {
          final contact =
              await IsarService.isar.myContacts.getByPhoneNumber(phoneNumber);
          name = contact?.name ?? "";
        }
        int callType = callTypeMap[callLog.callType] ?? 3;

        newCallHistory
            .add(CallHistory(phoneNumber, name, callLog.timestamp!, callType));
      }

      print(" added from local ${newCallHistory.length}");
      if (newCallHistory.isNotEmpty) {
        IsarService.addCallLogs(newCallHistory);
        print("added in db");
      }
    }
  } catch (e) {
    print('Error fetching call log: $e');
  }
}
