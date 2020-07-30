// ToDo: Change Verison and Buld number on every release buid,
//       implement a prebuild task to replace version and build number or
//       implement getting app version for web builds in the future.

class AppVersionWeb {
  static const String version = '1.0.0';
  static const int build = 1;

  static String get versionAndBuild {
    return '$version.$build';
  }
}
