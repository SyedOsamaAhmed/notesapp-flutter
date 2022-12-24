import 'package:flutter/material.dart';
import 'package:learning_project/utilities/dialogs/generic_dialog.dart';

Future<bool> showDeleteDialog(BuildContext context) {
  return showGenericDialog(
      context: context,
      title: 'Delete',
      content: 'Are you sure you want to delete selected note?',
      optionbuilder: () => {
            'Cancel': false,
            'delete': true,
          }).then((value) => value ?? false);
}
