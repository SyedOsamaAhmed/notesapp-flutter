import 'package:flutter/material.dart';
import 'package:learning_project/constants/routes.dart';
import 'package:learning_project/enums/menu_action.dart';
import 'package:learning_project/services/auth/auth_service.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notes'), actions: [
        PopupMenuButton<MenuActions>(onSelected: (value) async {
          switch (value) {
            case MenuActions.logout:
              final shouldLogout = await showLogoutDialog(context);
              if (shouldLogout) {
                await AuthService.firebase().logout();
                if (!mounted) {
                  return;
                }
                Navigator.of(context).pushNamedAndRemoveUntil(
                  loginRoute,
                  (_) => false,
                );
              }
              break;
          }
        }, itemBuilder: (context) {
          return const [
            PopupMenuItem(value: MenuActions.logout, child: Text('Logout')),
          ];
        })
      ]),
      body: const Text('Main UI'),
    );
  }
}

Future<bool> showLogoutDialog(BuildContext context) {
  return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Sign Out'),
          content: const Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Logout'),
            ),
          ],
        );
      }).then((value) => value ?? false);
}
