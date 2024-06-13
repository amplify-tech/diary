import 'package:diary/screens/call_log_screen.dart';
import 'package:diary/screens/contact_page.dart';
import 'package:diary/screens/setting_screen.dart';
import 'package:diary/widgets/common/search_bar.dart';
import 'package:flutter/material.dart';

class ContactNavigation extends StatefulWidget {
  const ContactNavigation({super.key});

  @override
  State<ContactNavigation> createState() => _ContactNavigationState();
}

class _ContactNavigationState extends State<ContactNavigation> {
  int currentPageIndex = 0;
  final ValueNotifier<String> _searchText = ValueNotifier<String>('');

  late final List<Widget> _screens = <Widget>[
    ContactPageScreen(searchTextNotifier: _searchText),
    const SettingScreen(),
    const CallLogScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 66,
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        title: SearchBars(searchTextNotifier: _searchText),
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
