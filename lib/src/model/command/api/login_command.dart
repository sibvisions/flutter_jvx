import 'api_command.dart';

class LoginCommand extends ApiCommand {
  final String userName;
  final String password;

  LoginCommand({
    required this.userName,
    required this.password,
    required String reason,
  }) : super(reason: reason);
}