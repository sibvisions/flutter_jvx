import '../../../../../model/command/base_command.dart';
import '../../../../isolate/isolate_message.dart';
import '../../../shared/i_repository.dart';

/// Used to send [IRepository] to the APIs isolate to be executed
class ApiIsolateSetRepositoryMessage extends IsolateMessage<List<BaseCommand>> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The request to be executed
  final IRepository repository;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ApiIsolateSetRepositoryMessage({required this.repository});
}
