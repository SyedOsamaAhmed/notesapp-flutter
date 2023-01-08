import 'package:flutter/material.dart';
import 'package:learning_project/utilities/dialogs/generic_dialog.dart';

Future<void> showResetPasswordDialog(BuildContext context) {
  return showGenericDialog(
    context: context,
    title: 'Password Reset',
    content:
        'We have sent you password reset link.Check inbox for gven information',
    optionbuilder: () => {
      'OK': null,
    },
  );
}
