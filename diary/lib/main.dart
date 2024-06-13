import 'package:diary/data/providers/tag_provider.dart';
import 'package:flutter/material.dart';
import 'package:diary/widgets/common/contact_navigation.dart';
import 'package:provider/provider.dart';
import 'package:diary/data/repositories/isar_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await IsarService.initialize();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MultiProvider(providers: [
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
        // appBarTheme: const AppBarTheme(
        //   backgroundColor: Colors.white,
        //   titleTextStyle: TextStyle(
        //     fontSize: 24, // Change the font size
        //     fontWeight: FontWeight.bold, // Change the font weight
        //   ),
        // ),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
        primarySwatch: Colors.lightBlue,
        listTileTheme: ListTileThemeData(
            selectedTileColor: Colors.lightBlue.withOpacity(0.15)),
        scaffoldBackgroundColor: Colors.white, // Set the body background color

        useMaterial3: true,
      ),
      home: const ContactNavigation(),
    );
  }
}
