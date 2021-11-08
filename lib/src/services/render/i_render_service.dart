import 'package:flutter/material.dart';

abstract class IRenderService {

  void registerAsParent(String id, Map<String, Size> children, Function onCompletionCallback);
  void registerPreferredSize(String id, Size size);


  void unRegisterParent(String id);
  void unRegisterPreferredSize(String id);
}