abstract class BaseEvent {

  ///A Description of why this Event was fired
  final String reason;

  ///The origin Object of the event
  final Object origin;

  BaseEvent({
    required this.origin,
    required this.reason
  });
}