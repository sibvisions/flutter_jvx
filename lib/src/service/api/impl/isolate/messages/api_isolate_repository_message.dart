import 'dart:isolate';

import '../../../shared/i_repository.dart';
import 'api_isolate_message.dart';

class ApiIsolateRepositoryMessage extends ApiIsolateMessage {
  IRepository repository;

  ApiIsolateRepositoryMessage({
    required this.repository,
  });

}
