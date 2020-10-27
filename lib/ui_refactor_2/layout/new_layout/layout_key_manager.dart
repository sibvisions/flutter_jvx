import 'package:flutter/material.dart';

class LayoutKeyManager {
  Map<String, Key> keys = <String, Key>{};

  Key getKeyByComponentId(String componentId) {
    return keys[componentId];
  }

  Key createKey(String componentId) {
    keys[componentId] = GlobalKey(debugLabel: componentId);
    return keys[componentId];
  }
}
