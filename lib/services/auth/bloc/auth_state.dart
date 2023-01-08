import 'package:flutter/foundation.dart' show immutable;
import 'package:learning_project/services/auth/auth_user.dart';
import 'package:equatable/equatable.dart';

@immutable
abstract class AuthState {
  final bool isLoading;
  final String? loadingText;
  const AuthState(
      {required this.isLoading, this.loadingText = 'Please wait a moment'});
}

class AuthStateUnInitialized extends AuthState {
  const AuthStateUnInitialized({required bool isLoading})
      : super(
          isLoading: isLoading,
        );
}

class AuthStateRegistering extends AuthState {
  final Exception? exception;
  const AuthStateRegistering({
    required this.exception,
    required bool isLoading,
  }) : super(
          isLoading: isLoading,
        );
}

class AuthStateLoggedIn extends AuthState {
  final AuthUser user;
  const AuthStateLoggedIn({required this.user, required bool isLoading})
      : super(
          isLoading: isLoading,
        );
}

class AuthStateForgotPassword extends AuthState {
  final Exception? exception;
  final bool isEmailSent;

  const AuthStateForgotPassword({
    required this.exception,
    required this.isEmailSent,
    required bool isLoading,
  }) : super(
          isLoading: isLoading,
        );
}

class AuthStateNeedsVerification extends AuthState {
  const AuthStateNeedsVerification({required bool isLoading})
      : super(
          isLoading: isLoading,
        );
}

//logout:true exception:null  isLoading:false
//logout:true exception:null  isLoading:true
//logout:true exception:true  isLoading:false

//Using equality package to compare exception and isloading in AuthStateLogout to differentiate between three different states of same class instance
class AuthStateLogout extends AuthState with EquatableMixin {
  final Exception? exception;

  const AuthStateLogout({
    required this.exception,
    required bool isLoading,
    String? loadingText,
  }) : super(
          isLoading: isLoading,
          loadingText: loadingText,
        );

  @override
  List<Object?> get props => [exception, isLoading];
}
