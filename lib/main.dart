import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learning_project/constants/routes.dart';

// import 'package:learning_project/services/auth/auth_service.dart';
import 'package:learning_project/views/login_view.dart';
import 'package:learning_project/notes/notes_view.dart';

import 'package:learning_project/views/register_view.dart';
import 'package:learning_project/views/verifyEmail_view.dart';

import 'notes/create_update_note.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
      //movement b/w screens. These are named routes
      routes: {
        loginRoute: (context) => const LoginView(),
        registerRoute: (context) => const RegisterView(),
        notesRoute: (context) => const NotesView(),
        verifyEmailRoute: (context) => const VerificationView(),
        createUpdateNoteRoute: (context) => const CreateUpdateNotesView(),
      },
    );
  }
}

//widget:elements of UI on screen of fluuter app.
//stateful widget:
/*
    state: data mutated(chaneged) by user or application.
    > on the screen that can be seen.
    > contains data changing and can read/write itself.

 */

//stateless widget: cannot redraw itself and contain mutable data.

/* class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    //Future Builder: for firebase initialiazation before app starts it takes future and return callback on the basis of success or error
    return FutureBuilder(
      future: AuthService.firebase().initialize(),
      builder: (context, snapshot) {
        //while waiting on firebase connection we tell user that its loading
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            final currentUser = AuthService.firebase().currentUser;

            if (currentUser != null) {
              if (currentUser.isEmailVerified) {
                return const NotesView();
              } else {
                return const VerificationView();
              }
            } else {
              return const LoginView();
            }

          default:
            return Scaffold(
                body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  CircularProgressIndicator(),
                  SizedBox(
                    height: 15,
                  )
                ],
              ),
            ));
        }
      },
    );
  }
}
 */

//bloc implementation:

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final TextEditingController _controller;

  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => CounterBloc(),
        child: Scaffold(
          appBar: AppBar(title: const Text('Testing bloc')),
          body: BlocConsumer<CounterBloc, CounterState>(
            listener: (context, state) {
              _controller.clear();
            },
            builder: (context, state) {
              final invalidVal =
                  (state is CounterStateInvalid) ? state.invalidValue : '';

              return Column(
                children: [
                  Text('state value is ${state.value}'),
                  Visibility(
                    visible: state is CounterStateInvalid,
                    child: Text('invalid input $invalidVal'),
                  ),
                  TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Enter a number',
                    ),
                    keyboardType: TextInputType.number,
                  )
                ],
              );
            },
          ),
        ));
  }
}

@immutable
abstract class CounterState {
  final int value;
  const CounterState(this.value);
}

class CounterStateValid extends CounterState {
  const CounterStateValid(int value) : super(value);
}

class CounterStateInvalid extends CounterState {
  final String invalidValue;
  const CounterStateInvalid(
      {required this.invalidValue, required int previousValue})
      : super(previousValue);
}

@immutable
abstract class CounterEvent {
  final String value;
  const CounterEvent(this.value);
}

class IncrementEvent extends CounterEvent {
  const IncrementEvent(String value) : super(value);
}

class DecrementEvent extends CounterEvent {
  const DecrementEvent(String value) : super(value);
}

class CounterBloc extends Bloc<CounterEvent, CounterState> {
  CounterBloc() : super(const CounterStateValid(0)) {
    on<IncrementEvent>(
      (event, emit) {
        final integer = int.tryParse(event.value);
        if (integer == null) {
          emit(CounterStateInvalid(
            invalidValue: event.value,
            previousValue: state.value,
          ));
        } else {
          emit(CounterStateValid(state.value + integer));
        }
      },
    );
    on<DecrementEvent>(
      (event, emit) {
        final integer = int.tryParse(event.value);
        if (integer == null) {
          emit(CounterStateInvalid(
            invalidValue: event.value,
            previousValue: state.value,
          ));
        } else {
          emit(CounterStateValid(state.value - integer));
        }
      },
    );
  }
}
