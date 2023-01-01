import 'package:bloc/bloc.dart';
import 'package:learning_project/services/auth/auth_provider.dart';
import 'package:learning_project/services/auth/bloc/auth_events.dart';
import 'package:learning_project/services/auth/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(AuthProvider provider) : super(const AuthStateUnInitialized()) {
    //Email Verfication:
    on<AuthEventSendEmailVerification>(
      (event, emit) async {
        await provider.sendEmailVerification();
        emit(state);
      },
    );

    //register:
    on<AuthEventRegister>(
      (event, emit) async {
        final email = event.email;
        final password = event.password;
        try {
          await provider.createUser(
            email: email,
            password: password,
          );

          await provider.sendEmailVerification();
          emit(const AuthStateNeedsVerification());
        } on Exception catch (e) {
          emit(AuthStateRegistering(e));
        }
      },
    );

    //initiallaze using bloc:
    on<AuthEventInitialise>((event, emit) async {
      await provider.initialize();
      final user = provider.currentUser;
      if (user == null) {
        emit(const AuthStateLogout(
          exception: null,
          isLoading: false,
        ));
      } else if (!user.isEmailVerified) {
        emit(const AuthStateNeedsVerification());
      } else {
        emit(AuthStateLoggedIn(user));
      }
    });

    on<AuthEventLogIn>(
      (event, emit) async {
        emit(const AuthStateLogout(
          exception: null,
          isLoading: true,
        ));
        final String email = event.email;
        final String password = event.password;

        try {
          final user = await provider.login(
            email: email,
            password: password,
          );
          if (!user.isEmailVerified) {
            //disabled loading screen:
            emit(const AuthStateLogout(
              exception: null,
              isLoading: false,
            ));
            emit(const AuthStateNeedsVerification());
          } else {
            //disabled loading screen:
            emit(const AuthStateLogout(
              exception: null,
              isLoading: false,
            ));

            emit(AuthStateLoggedIn(user));
          }
        } on Exception catch (e) {
          emit(AuthStateLogout(
            exception: e,
            isLoading: false,
          ));
        }
      },
    );

    on<AuthEventLogOut>(
      (event, emit) async {
        try {
          await provider.logout();
          emit(const AuthStateLogout(
            exception: null,
            isLoading: false,
          ));
        } on Exception catch (e) {
          emit(AuthStateLogout(
            exception: e,
            isLoading: false,
          ));
        }
      },
    );
  }
}
