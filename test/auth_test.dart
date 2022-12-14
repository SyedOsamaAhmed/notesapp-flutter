import 'package:learning_project/services/auth/auth_exceptions.dart';
import 'package:learning_project/services/auth/auth_provider.dart';
import 'package:learning_project/services/auth/auth_user.dart';
import 'package:test/test.dart';

//unit test:
void main() {}

class NotInitializedException implements Exception {}

//Mocking: cutting firebase and introducing our authprovider where we are in control
class MockAuthProvider implements AuthProvider {
  var _isInitialised = false;
  AuthUser? _user;
  bool get isIntialised => _isInitialised;
  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) async {
    if (!isIntialised) throw NotInitializedException();

    await Future.delayed(const Duration(seconds: 1));
    return login(
      email: email,
      password: password,
    );
  }

  @override
  AuthUser? get currentUser => _user;

  @override
  Future<void> initialize() async {
    await Future.delayed(const Duration(seconds: 1));
    _isInitialised = true;
  }

  @override
  Future<AuthUser> login({
    required String email,
    required String password,
  }) {
    if (!isIntialised) throw NotInitializedException();
    if (email == 'foo@bar.com') throw UserNotFoundAuthException();
    if (password == 'foobar') throw WrongPasswordAuthException();

    const user = AuthUser(isEmailVerified: false);
    _user = user;
    return Future.value(user);
  }

  @override
  Future<void> logout() async {
    if (!isIntialised) throw NotInitializedException();
    await Future.delayed(const Duration(seconds: 1));
    if (_user == null) throw UserNotFoundAuthException();
    _user = null;
  }

  @override
  Future<void> sendEmailVerification() {
    if (!isIntialised) throw NotInitializedException();
    final user = _user;
    if (user == null) throw UserNotFoundAuthException();
    const newUser = AuthUser(isEmailVerified: true);
    _user = newUser;
    throw UnimplementedError();
  }
}
