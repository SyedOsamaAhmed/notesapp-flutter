import 'package:flutter/material.dart';
import 'package:learning_project/utilities/dialogs/generic_dialog.dart';

Future<bool> showLogoutDialog(BuildContext context) {
  return showGenericDialog(
    context: context,
    title: 'Log out',
    content: 'Are you sure you want to log out?',
    optionbuilder: () => {
      'Cancel': false,
      'Log out': true,
    },
  ).then((value) =>
      value ??
      false); //Safegard for ios especially for interaction with dialog necessary
}
