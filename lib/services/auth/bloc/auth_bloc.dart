import 'package:bloc/bloc.dart';
import 'package:learning_project/services/auth/auth_provider.dart';
import 'package:learning_project/services/auth/bloc/auth_events.dart';
import 'package:learning_project/services/auth/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(AuthProvider provider)
      : super(const AuthStateUnInitialized(isLoading: true)) {
    on<AuthEventShouldRegister>((event, emit) {
      emit(const AuthStateRegistering(
        exception: null,
        isLoading: false,
      ));
    });
    //Forget Password:
    on<AuthEventForgotPassword>((event, emit) async {
      emit(const AuthStateForgotPassword(
        exception: null,
        isEmailSent: false,
        isLoading: false,
      ));

      final email = event.email;
      //user just wants to land on forgot password screen
      if (email == null) {
        return;
      }

      //user actually sent forgot password email
      emit(const AuthStateForgotPassword(
        exception: null,
        isEmailSent: false,
        isLoading: true,
      ));

      bool emailSent;
      Exception? exception;

      try {
        await provider.sendResetPassword(email: email);
        emailSent = true;
        exception = null;
      } on Exception catch (e) {
        emailSent = false;
        exception = e;
      }

      emit(AuthStateForgotPassword(
        exception: exception,
        isEmailSent: emailSent,
        isLoading: false,
      ));
    });
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
          emit(const AuthStateNeedsVerification(isLoading: false));
        } on Exception catch (e) {
          emit(AuthStateRegistering(
            exception: e,
            isLoading: false,
          ));
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
        emit(const AuthStateNeedsVerification(isLoading: false));
      } else {
        emit(AuthStateLoggedIn(user: user, isLoading: false));
      }
    });

    on<AuthEventLogIn>(
      (event, emit) async {
        emit(const AuthStateLogout(
            exception: null,
            isLoading: true,
            loadingText: 'Please wait logging in'));
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
            emit(const AuthStateNeedsVerification(isLoading: false));
          } else {
            //disabled loading screen:
            emit(const AuthStateLogout(
              exception: null,
              isLoading: false,
            ));

            emit(AuthStateLoggedIn(
              user: user,
              isLoading: false,
            ));
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
