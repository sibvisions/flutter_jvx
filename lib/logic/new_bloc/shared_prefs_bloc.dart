import 'package:bloc/bloc.dart';

import 'shared_prefs_state.dart';

enum SharedPrefsEvent { GET, SET }

class SharedPrefsBloc extends Bloc<SharedPrefsEvent, SharedPrefsState> {
  @override
  get initialState => SharedPrefsState();

  @override
  Stream<SharedPrefsState> mapEventToState(SharedPrefsEvent event) {
    return null;
  }
}