import '../../models/state/app_state.dart';

String getPackageString(AppState appState, String image) {
  if (appState.appConfig!.package) {
    return 'packages/flutterclient/$image';
  } else {
    return '$image';
  }
}
