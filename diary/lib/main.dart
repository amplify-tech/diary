import 'package:diary/data/providers/tag_provider.dart';
import 'package:diary/widgets/extra.dart';
import 'package:flutter/material.dart';
import 'package:diary/widgets/common/contact_navigation.dart';
import 'package:provider/provider.dart';
import 'package:diary/data/repositories/isar_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await IsarService.initialize();

  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => Counter()),
    ChangeNotifierProvider(create: (_) => TagProvider()),
  ], child: const App()));
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Contact Diary',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
        listTileTheme: ListTileThemeData(
            selectedTileColor: Colors.lightBlue.withOpacity(0.15)),
        useMaterial3: true,
      ),
      home: const ContactNavigation(),
    );
  }
}
