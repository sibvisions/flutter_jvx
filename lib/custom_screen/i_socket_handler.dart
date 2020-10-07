abstract class ISocketHandler {
  /// ---------------------------------------------------------
  /// True when connection is established
  /// ---------------------------------------------------------
  bool isOn;

  /// ----------------------------------------------------------
  /// Initialization the WebSockets connection with the server
  /// ----------------------------------------------------------
  initCommunication();

  /// ----------------------------------------------------------
  /// Closes the WebSocket communication
  /// ----------------------------------------------------------
  reset();

  /// ---------------------------------------------------------
  /// Sends a message to the server
  /// ---------------------------------------------------------
  send(String message);

  /// ---------------------------------------------------------
  /// Adds a callback to be invoked in case of incoming
  /// notification
  /// ---------------------------------------------------------
  ISocketHandler addListener(Function callback);

  ISocketHandler removeListener(Function callback);
}
