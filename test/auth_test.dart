import 'package:learning_project/services/auth/auth_exceptions.dart';
import 'package:learning_project/services/auth/auth_provider.dart';
import 'package:learning_project/services/auth/auth_user.dart';
import 'package:test/test.dart';

//unit test:
void main() {
  group('Mock Authentication', () {
    final provider = MockAuthProvider();

    //Initialization only if member value false
    test('Should not be initialized to begin with', () {
      expect(provider._isInitialised, false);
    });
//Must be Intiallzed before logout test:
    test('Cannot logout if not initialized', () {
      throwsA(const TypeMatcher<NotInitializedException>());
    });
//Initialization test:
    test('Should be able to initialize', () async {
      await provider.initialize();
      expect(provider._isInitialised, true);
    });
    //Null user test:
    test('User Should be null after initialization', (() {
      expect(provider.currentUser, null);
    }));

//Initialization time test:
    test(
      'Should be able to initialize in less than 2 seconds',
      () async {
        await provider.initialize();
        expect(provider._isInitialised, true);
      },
      timeout: const Timeout(Duration(seconds: 2)),
    );

//create user is calling login function test:
    test('Create user should delegate login function', () async {
      final badEmail = provider.createUser(
        email: 'foo@bar.com',
        password: 'anypassword',
      );

      expect(badEmail, throwsA(const TypeMatcher<UserNotFoundAuthException>()));
      final badPassword = provider.createUser(
        email: 'anyone@bar.com',
        password: 'foobar',
      );

      expect(badPassword,
          throwsA(const TypeMatcher<WrongPasswordAuthException>()));

      final user = await provider.createUser(
        email: 'foo',
        password: 'bar',
      );

      expect(provider.currentUser, user);
      expect(user.isEmailVerified, false);
    });
//email verification test:
    test(
      'Logged in user should be able to verify',
      () {
        provider.sendEmailVerification();
        final user = provider.currentUser;
        expect(user, isNotNull);
        expect(user!.isEmailVerified, true);
      },
    );
    //log out andlogin again test:

    test('Should be able to logout and login again', (() async {
      await provider.logout();
      await provider.login(
        email: 'email',
        password: 'password',
      );
      final user = provider.currentUser;
      expect(user, isNotNull);
    }));
  });
}

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
  Future<void> sendEmailVerification() async {
    if (!isIntialised) throw NotInitializedException();
    final user = _user;
    if (user == null) throw UserNotFoundAuthException();
    const newUser = AuthUser(isEmailVerified: true);
    _user = newUser;
  }
}
