import '../ui/screen/component_creator.dart';
import '../ui/screen/i_screen.dart';
import 'first_custom_screen.dart';

/// Devs need to return their CustomScreen Instance here
///
/// This Method will be called from the Menu
IScreen getCustomScreen() {
  bool show = false;
  IScreen iScreen = FirstCustomScreen(ComponentCreator());
  if (show) {
    return iScreen;
  }
  return null;
}
