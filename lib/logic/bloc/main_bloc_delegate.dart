import 'package:bloc/bloc.dart';

class MainBlocDelegate extends BlocDelegate {
  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    print('**********************************************');
    print('Transition: { currentState: ${transition.currentState}, event: ${transition.event}, nextState: ${transition.nextState} }');
    print('ERROR: ${transition.nextState.error}');
    if (transition.nextState.error) {
      print(transition.nextState.message);
    }
    print('**********************************************');
  }
}