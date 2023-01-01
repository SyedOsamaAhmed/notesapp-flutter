import 'package:flutter/foundation.dart' show immutable;
import 'package:learning_project/services/auth/auth_user.dart';
import 'package:equatable/equatable.dart';

@immutable
abstract class AuthState {
  const AuthState();
}

class AuthStateUnInitialized extends AuthState {
  const AuthStateUnInitialized();
}

class AuthStateRegistering extends AuthState {
  final Exception? exception;
  const AuthStateRegistering(this.exception);
}

class AuthStateLoggedIn extends AuthState {
  final AuthUser user;
  const AuthStateLoggedIn(this.user);
}

class AuthStateNeedsVerification extends AuthState {
  const AuthStateNeedsVerification();
}

//logout:true exception:null  isLoading:false
//logout:true exception:null  isLoading:true
//logout:true exception:true  isLoading:false

//Using equality package to compare exception and isloading in AuthStateLogout to differentiate between three different states of same class instance
class AuthStateLogout extends AuthState with EquatableMixin {
  final Exception? exception;
  final bool isLoading;
  const AuthStateLogout({
    required this.exception,
    required this.isLoading,
  });

  @override
  List<Object?> get props => [exception, isLoading];
}
