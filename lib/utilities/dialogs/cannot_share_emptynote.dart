import 'package:flutter/material.dart';
import 'package:learning_project/utilities/dialogs/generic_dialog.dart';

Future<void> cannotShareEmptyNotes(BuildContext context) {
  return showGenericDialog<void>(
      context: context,
      title: 'Sharing',
      content: 'You cannot share empty note',
      optionbuilder: () => {
            'OK': null,
          });
}
