import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'package:call_log/call_log.dart';

class CallLogScreen extends StatefulWidget {
  const CallLogScreen({super.key});

  @override
  State<CallLogScreen> createState() => _CallLogScreenState();
}

class _CallLogScreenState extends State<CallLogScreen> {
  List<CallLogEntry> _callLogs = [];

  @override
  void initState() {
    super.initState();
    _getCallLogs();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _callLogs.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: CircleAvatar(
            child: _callLogs[index].name!.isNotEmpty
                ? Text(_callLogs[index].name![0])
                : const Icon(Icons.person_rounded),
          ),
          title: Text(_callLogs[index].name ?? "Unknown"),
          subtitle: Wrap(
            spacing: 12,
            children: <Widget>[
              Text(_callLogs[index].number.toString()),
              Text(DateFormat('h:mm a d - MMM').format(
                  DateTime.fromMillisecondsSinceEpoch(
                      _callLogs[index].timestamp ?? 1 * 1000))),
              _callLogs[index].callType == CallType.incoming
                  ? const Icon(
                      Icons.call_received_rounded,
                      size: 16,
                    )
                  : _callLogs[index].callType == CallType.outgoing
                      ? const Icon(
                          Icons.call_made_rounded,
                          size: 16,
                        )
                      : const Icon(
                          Icons.call_missed_rounded,
                          size: 16,
                          color: Colors.red,
                        ),
            ],
          ),
          trailing: Wrap(
            spacing: 18,
            children: <Widget>[
              IconButton(
                icon: const Icon(Icons.call),
                onPressed: () => _callNumber(_callLogs[index].number),
              ),
              IconButton(
                icon: const Icon(Icons.chat_rounded),
                onPressed: () => _launchWhatsApp(_callLogs[index].number),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _getCallLogs() async {
    Iterable<CallLogEntry> entries = await CallLog.get();
    setState(() {
      _callLogs = entries.toList();
    });
    // entries.toList().forEach((list) {
    //   print(
    //       "hello    ${DateTime.fromMillisecondsSinceEpoch(list.timestamp ?? 1 * 1000)}");
    // });
  }

  _callNumber(phoneNumber) async {
    await FlutterPhoneDirectCaller.callNumber(phoneNumber);
  }

  _launchWhatsApp(phoneNumber) async {
    String url = "https://wa.me/$phoneNumber";
    try {
      await launchUrlString(url);
    } catch (e) {
      return false;
    }
  }
}
