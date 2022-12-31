import 'package:bloc/bloc.dart';
import 'package:learning_project/services/auth/auth_provider.dart';
import 'package:learning_project/services/auth/bloc/auth_events.dart';
import 'package:learning_project/services/auth/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(AuthProvider provider) : super(const AuthStateLoading()) {
    //initiallaze using bloc:
    on<AuthEventInitialise>((event, emit) async {
      await provider.initialize();
      final user = provider.currentUser;
      if (user == null) {
        emit(const AuthStateLogout(null));
      } else if (!user.isEmailVerified) {
        emit(const AuthStateNeedsVerification());
      } else {
        emit(AuthStateLoggedIn(user));
      }
    });

    on<AuthEventLogIn>(
      (event, emit) async {
        final String email = event.email;
        final String password = event.password;

        try {
          final user = await provider.login(
            email: email,
            password: password,
          );

          emit(AuthStateLoggedIn(user));
        } on Exception catch (e) {
          emit(AuthStateLogout(e));
        }
      },
    );

    on<AuthEventLogOut>(
      (event, emit) async {
        try {
          emit(const AuthStateLoading());
          await provider.logout();
          emit(const AuthStateLogout(null));
        } on Exception catch (e) {
          emit(AuthStateLogOutFailure(e));
        }
      },
    );
  }
}
