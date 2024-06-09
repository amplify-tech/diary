import 'package:diary/widgets/common/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:diary/utils/utils.dart';

class BackupButton extends StatelessWidget {
  const BackupButton({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        return ElevatedButton(
          onPressed:
              snapshot.hasData ? handleBackup : () => _handleLogin(context),
          child: const Text('Backup'),
        );
      },
    );
  }

  void _handleLogin(BuildContext context) {
    print('wait login');

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }
}
