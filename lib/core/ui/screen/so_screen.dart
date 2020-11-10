import 'package:flutter/material.dart';

import '../../models/api/request.dart';
import '../../models/api/response/response_data.dart';
import 'i_screen.dart';

class SoScreen extends StatelessWidget implements IScreen {
  final String componentId;
  final Widget child;

  const SoScreen({Key key, this.componentId, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(widthFactor: 1, heightFactor: 1, child: child);
  }

  @override
  bool withServer() {
    return true;
  }

  @override
  void update(Request request, ResponseData responseData) {
    
  }
}