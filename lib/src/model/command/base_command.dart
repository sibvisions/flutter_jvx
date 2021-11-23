///
/// Base Class for communication between services, every [BaseCommand] should always be directed at a specific Service.
///
///
abstract class BaseCommand {

  ///Generated ID -> DateTime.now().millisecondsSinceEpoch
  final int id;

  ///Descriptive Reason why this Command was issued.
  final String reason;

  BaseCommand({
    required this.reason
  }) : id = DateTime.now().millisecondsSinceEpoch;


  @override
  String toString() {
    return super.toString() + "  reason: $reason";
  }

}