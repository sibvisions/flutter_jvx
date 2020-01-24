import 'package:flutter/widgets.dart';
import 'package:jvx_mobile_v3/ui/component/i_component.dart';
import 'package:jvx_mobile_v3/ui/component/jvx_component.dart';

import 'jvx_layout.dart';

class JVxGridLayout extends JVxLayout<String> {

  /// stores all constraints. */
  Map<JVxComponent, String> _constraintMap= <JVxComponent, String>{};

  void addLayoutComponent(IComponent pComponent, String pConstraint)
  {
        
    if (pConstraint == null || pConstraint.isEmpty)
    {
      throw new ArgumentError("Constraint " + pConstraint.toString() + " is not allowed!");
    }
    else
    {
      _constraintMap.putIfAbsent(pComponent, () => pConstraint);
    }
  }

  void removeLayoutComponent(IComponent pComponent) 
  {
    _constraintMap.removeWhere((c, s) => c.componentId.toString() == pComponent.componentId.toString());
  }

  @override
  String getConstraints(IComponent comp) {
    return _constraintMap[comp];
  }


    Widget getWidget() {
      return Container();
    }
}