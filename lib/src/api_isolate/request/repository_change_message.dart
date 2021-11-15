import 'dart:isolate';

import 'package:flutter_jvx/src/services/api/i_repository.dart';

import '../i_api_isolate_message.dart';

///
/// Tells the ApiIsolate to use this [IRepository] and throw away its current one
///
class RepositoryChangeMessage extends ApiIsolateMessage {

  ///New Repository
  IRepository newRepository;

  RepositoryChangeMessage({required this.newRepository, required SendPort sendPort}) : super(sendPort: sendPort);
}