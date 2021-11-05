import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_jvx/src/util/mixin/events/meta/on_client_id_event.dart';
import 'package:flutter_jvx/src/util/mixin/service/api_service_mixin.dart';
import 'package:http/http.dart';

class TestWidget extends StatefulWidget{
  const TestWidget({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _TestWidgetState();

}

class _TestWidgetState extends State with OnClientIdEvent, ApiServiceMixin {

  StreamSubscription? sub;

  _TestWidgetState(){
    sub = authenticationEventStream.listen((event) {
      setState(() {
        String? temp = event.clientId;
        if(temp != null) {
          clientId = temp;
        }
      });
    });
  }


  String clientId = "NO ID FOUND";

  @override
  void dispose() {
    StreamSubscription? tempSub = sub;
    if(tempSub != null) {
      tempSub.cancel();
    }
    super.dispose();
  }

  void btnPressed(){
    Future<Response> a = apiRepository.startUp();
    apiController.determineResponse(a);
  }

  @override
  Widget build(BuildContext context) {
    return (
      Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(clientId),
            ElevatedButton(onPressed: btnPressed, child: const Text("START_UP"))
          ],
        ),
      )
    );
  }

}