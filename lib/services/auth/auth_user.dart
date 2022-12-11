import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/foundation.dart';

@immutable // internals of parrent and sub classes can't be changed
class AuthUser {
  final bool isEmailVerified;

  const AuthUser(this.isEmailVerified);
  //taking user info from firebase making a copy to this class without directly exposing it to user interface.
  factory AuthUser.fromFirebase(User user) => AuthUser(user.emailVerified);
}
