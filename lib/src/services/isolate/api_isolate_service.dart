import 'dart:isolate';


class ApiIsolateService {

  ///The Api Isolate reference
  final Isolate apiIsolate;

  ///SendPort to send Messages to the receivePort
  final SendPort sendPort;


  void asd(){
    
  }

  ApiIsolateService({required this.sendPort, required this.apiIsolate});
}


