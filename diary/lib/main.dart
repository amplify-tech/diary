import 'package:flutter/material.dart';
import 'isar_service.dart';
import 'models/contact.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final isarService = IsarService();
  await isarService.openDB();
  runApp(MyApp(isarService));
}

class MyApp extends StatelessWidget {
  final IsarService isarService;

  const MyApp(this.isarService, {super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Isar Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Contacts', isarService: isarService),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;
  final IsarService isarService;

  const MyHomePage({super.key, required this.title, required this.isarService});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<List<Contact>> _contacts;

  @override
  void initState() {
    super.initState();
    _contacts = widget.isarService.getContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: FutureBuilder<List<Contact>>(
        future: _contacts,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(snapshot.data![index].name),
                  subtitle: Text(snapshot.data![index].phoneNumber),
                  leading: CircleAvatar(
                    child: Text(snapshot.data![index].name[0]),
                  ),
                );
              },
            );
          } else {
            return const CircularProgressIndicator();
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print("1");
          addDummyData(widget.isarService).then((_) {
            print("4");
            setState(() {
              _contacts = widget.isarService.getContacts();
            });
            print("5");
          });

          print("6");
        },
        tooltip: 'Add',
        child: const Icon(Icons.add),
      ),
    );
  }
}

Future<void> addDummyData(IsarService isarService) async {
  print("2");
  final contact = Contact()
    ..name = 'John Doe'
    ..phoneNumber = '123-456-7890'
    ..tag = 'Friend'
    ..dateAdded = DateTime.now();

  return isarService.addContact(contact).then((_) {
    print("3");
  });
}
