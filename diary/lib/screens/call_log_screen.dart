import 'package:diary/data/models/callhistory.dart';
import 'package:diary/data/repositories/isar_service.dart';
import 'package:diary/utils/calllog.dart';
import 'package:diary/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phone_state/phone_state.dart';

const iconList = [
  Icon(
    Icons.call_missed_rounded,
    size: 16,
    color: Colors.red,
  ),
  Icon(
    Icons.call_received_rounded,
    size: 16,
  ),
  Icon(
    Icons.call_made_rounded,
    size: 16,
  ),
  Icon(
    Icons.call_end_outlined,
    size: 16,
  ),
];

class CallLogScreen extends StatefulWidget {
  const CallLogScreen({super.key});

  @override
  State<CallLogScreen> createState() => _CallLogScreenState();
}

class _CallLogScreenState extends State<CallLogScreen> {
  late Stream<List<CallHistory>> getCallLog = IsarService.watchCallLog();

  @override
  void initState() {
    super.initState();
    syncCallLog(context);
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      StreamBuilder(
        initialData: PhoneState.nothing(),
        stream: PhoneState.stream,
        builder: (context, snapshot) {
          syncCallLog(context);
          final phoneState = snapshot.data;
          if (phoneState != null &&
              (phoneState.status == PhoneStateStatus.CALL_INCOMING ||
                  phoneState.status == PhoneStateStatus.CALL_STARTED)) {
            return Column(
              children: [
                const SizedBox(height: 200),
                Text(
                  "${phoneState.number} \n name \n last call ",
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(height: 10),
                IconButton(
                  icon: const Icon(Icons.chat_rounded),
                  onPressed: () =>
                      launchWhatsApp(phoneState.number!.getPhoneNumber()),
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
      //////////////////
      Expanded(
        child: StreamBuilder<List<CallHistory>>(
            stream: getCallLog,
            builder: (context, snapshot) {
              // if (snapshot.connectionState == ConnectionState.waiting) {
              //   return Container();
              // }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Container();
              }

              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final callLog = snapshot.data![index];
                  return ListTile(
                    leading: CircleAvatar(
                      child: callLog.name.isNotEmpty
                          ? Text(callLog.name[0])
                          : const Icon(Icons.person_rounded),
                    ),
                    title: Text(callLog.name.isNotEmpty
                        ? callLog.name
                        : callLog.phoneNumber),
                    subtitle: Wrap(
                      spacing: 12,
                      children: <Widget>[
                        if (callLog.name.isNotEmpty) Text(callLog.phoneNumber),
                        Text(DateFormat('h:mm a d - MMM').format(
                            DateTime.fromMillisecondsSinceEpoch(
                                callLog.lastCall))),
                        iconList[callLog.lastCallType],
                      ],
                    ),
                    trailing: Wrap(
                      spacing: 18,
                      children: <Widget>[
                        IconButton(
                          icon: const Icon(Icons.call),
                          onPressed: () => callNumber(callLog.phoneNumber),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chat_rounded),
                          onPressed: () => launchWhatsApp(callLog.phoneNumber),
                        ),
                      ],
                    ),
                  );
                },
              );
            }),
      ),
    ]);
  }

  // Get the corresponding icon based on the phone state status
  IconData getIcons(PhoneStateStatus status) {
    switch (status) {
      case PhoneStateStatus.NOTHING:
        return Icons.clear;
      case PhoneStateStatus.CALL_INCOMING:
        return Icons.add_call;
      case PhoneStateStatus.CALL_STARTED:
        return Icons.call;
      case PhoneStateStatus.CALL_ENDED:
        return Icons.call_end;
    }
  }

  // Get the corresponding color based on the phone state status
  Color getColor(PhoneStateStatus status) {
    switch (status) {
      case PhoneStateStatus.NOTHING:
      case PhoneStateStatus.CALL_ENDED:
        return Colors.red;
      case PhoneStateStatus.CALL_INCOMING:
        return Colors.green;
      case PhoneStateStatus.CALL_STARTED:
        return Colors.orange;
    }
  }
}
