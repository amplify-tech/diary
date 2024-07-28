// ignore_for_file: use_build_context_synchronously

import 'package:call_log/call_log.dart';
import 'package:diary/data/models/callhistory.dart';
import 'package:diary/data/models/contact.dart';
import 'package:diary/data/repositories/isar_service.dart';
import 'package:diary/utils/alert.dart';
import 'package:diary/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:permission_handler/permission_handler.dart';

final callTypeMap = {
  CallType.missed: 0,
  CallType.incoming: 1,
  CallType.outgoing: 2,
};
/////////////////////////////////////////////////////////////////////
// call log
Future<void> syncCallLog(BuildContext context) async {
  try {
    if (await Permission.phone.request().isGranted) {
      showSnackbar(context, 'Fetching  CallLog...');
      int? maxCallTime =
          await IsarService.isar.callHistorys.where().lastCallProperty().max();

      List<CallLogEntry> newCall =
          (await CallLog.query(dateFrom: maxCallTime)).toList();
      List<CallHistory> newCallHistory = [];

      for (final callLog in newCall.reversed) {
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

      if (newCallHistory.isNotEmpty) {
        await IsarService.addCallLogs(newCallHistory);
        showSnackbar(context, 'CallLog Updated!');
      }
    }
  } catch (e) {
    showSnackbar(context, 'Error Fetching CallLog: \n $e');
  }
}
