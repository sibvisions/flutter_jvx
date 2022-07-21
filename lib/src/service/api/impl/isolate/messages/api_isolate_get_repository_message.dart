import '../../../../isolate/isolate_message.dart';
import '../../../shared/i_repository.dart';

/// Used to send [IRepository] to the APIs isolate to be executed
class ApiIsolateGetRepositoryMessage extends IsolateMessage<IRepository> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ApiIsolateGetRepositoryMessage();
}
