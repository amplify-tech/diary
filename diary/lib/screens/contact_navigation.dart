import 'package:diary/data/providers/meta_provider.dart';
import 'package:diary/screens/call_log_screen.dart';
import 'package:diary/screens/contact_page.dart';
import 'package:diary/screens/setting_screen.dart';
import 'package:diary/utils/calllog.dart';
import 'package:diary/widgets/common/search_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ContactNavigation extends StatelessWidget {
  static List<Widget> screens = [
    const SizedBox(),
    const CallLogScreen(),
    const SizedBox(),
  ];
  const ContactNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 66,
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        title: const SearchBars(),
      ),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (index) => navigateToPage(context, index),
        indicatorColor: Theme.of(context).colorScheme.inversePrimary,
        selectedIndex: context.watch<MetaProvider>().currentPageIndex,
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
      body: IndexedStack(
        index: context.watch<MetaProvider>().currentPageIndex,
        children: ContactNavigation.screens,
      ),
    );
  }
}

void navigateToPage(BuildContext context, int index) {
  if (ContactNavigation.screens[index] is SizedBox && index == 0) {
    ContactNavigation.screens[index] = const SettingScreen();
  } else if (ContactNavigation.screens[index] is SizedBox && index == 2) {
    ContactNavigation.screens[index] = const ContactPageScreen();
  } else if (index == 1) {
    syncCallLog(context);
  }
  context.read<MetaProvider>().updatePage(index);
}
