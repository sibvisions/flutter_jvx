import 'dart:ui';

import 'package:flutter_jvx/src/services/render/i_render_service.dart';

class RenderService implements IRenderService {

  final Map<String, Map<String, Size>> preferredSizesByParent = {};

  @override
  void registerAsParent(String id, Map<String, Size> children, Function onCompletionCallback) {
    // TODO: implement registerAsParent
  }

  @override
  void registerPreferredSize(String id, Size size, String parentId) {
    // TODO: implement registerPreferredSize
  }

  @override
  void unRegisterParent(String id) {
    // TODO: implement unRegisterParent
  }

  @override
  void unRegisterPreferredSize(String id) {
    // TODO: implement unRegisterPreferredSize
  }


}