import 'package:flutter/material.dart';
import 'package:call_log/call_log.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Call Log Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const CallLogScreen(),
    );
  }
}

class CallLogScreen extends StatefulWidget {
  const CallLogScreen({super.key});

  @override
  _CallLogScreenState createState() => _CallLogScreenState();
}

class _CallLogScreenState extends State<CallLogScreen> {
  List<CallLogEntry> _callLogs = [];

  @override
  void initState() {
    super.initState();
    _getCallLogs();
  }

  Future<void> _getCallLogs() async {
    Iterable<CallLogEntry> entries = await CallLog.get();
    entries.toList().forEach((list) {
      // print("hello    ${list.name.toString()}");
    });

    setState(() {
      _callLogs = entries.toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Call Logs'),
      ),
      body: ListView.builder(
        itemCount: _callLogs.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: const Icon(Icons.call),
            title: Text(_callLogs[index].name ?? "Unknown"),
            subtitle: Text(_callLogs[index].number.toString()),
            trailing: Text(_callLogs[index].callType == CallType.incoming
                ? "Incoming"
                : _callLogs[index].callType == CallType.outgoing
                    ? "Outgoing"
                    : "Missed"),
          );
        },
      ),
    );
  }
}
