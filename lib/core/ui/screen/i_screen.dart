import '../../models/api/request.dart';
import '../../models/api/response/response_data.dart';
import 'so_screen.dart';

abstract class IScreen {
  /// Context for making various requests

  /// Constructor for returning the default Implementation of this interface.
  factory IScreen() =>
      SoScreen();

  /// Gets called when new components, metaData or data is comming from the server.
  void update(Request request, ResponseData responseData);

  /// Returns `true` when the server should be called when the user opens a screen.
  ///
  /// When `false` the server will not be called.
  bool withServer();
}
