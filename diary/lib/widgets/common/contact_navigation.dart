import 'package:diary/screens/contact_page.dart';
import 'package:diary/screens/setting_screen.dart';
import 'package:diary/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:diary/screens/call_log_screen.dart';

class ContactNavigation extends StatefulWidget {
  const ContactNavigation({super.key});

  @override
  State<ContactNavigation> createState() => _ContactNavigationState();
}

class _ContactNavigationState extends State<ContactNavigation> {
  int currentPageIndex = 0;
  static const List<Widget> _screens = <Widget>[
    SettingScreen(),
    CallLogScreen(),
    ContactPageScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Diary'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: const <Widget>[
          IconButton(
            onPressed: syncFromLocal,
            icon: Icon(Icons.sync),
          )
        ],
      ),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        indicatorColor: Theme.of(context).colorScheme.inversePrimary,
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.settings),
            icon: Icon(Icons.settings_outlined),
            label: 'Setting',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.call_rounded),
            icon: Icon(Icons.call_outlined),
            label: 'Call',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.contact_page_rounded),
            icon: Icon(Icons.contact_page_outlined),
            label: 'Contacts',
          ),
        ],
      ),
      body: _screens[currentPageIndex],
      // body: IndexedStack(
      //   index: currentPageIndex,
      //   children: _screens,
      // ),
    );
  }
}
