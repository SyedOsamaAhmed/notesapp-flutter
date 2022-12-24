import 'package:flutter/material.dart' show BuildContext, ModalRoute;

extension GetArguments on BuildContext {
  ///We made generic function here to get any type of argument to get values of any type from  Navigation argument objects from any widget.

  T? getArguments<T>() {
    final modalRoute = ModalRoute.of(this);

    if (modalRoute != null) {
      //ModalRoute.settings.arguments is use to get values from navigation object
      final args = modalRoute.settings.arguments;
      if (args != null && args is T) {
        return args as T;
      }
    }
    return null;
  }
}
