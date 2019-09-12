import 'package:flutter/material.dart';
import 'package:jvx_mobile_v3/ui/layout/jvx_form_layout.dart';
import '../../model/component_properties.dart';
import '../layout/widgets/jvx_border_layout.dart';
import 'i_container.dart';
import '../component/jvx_component.dart';
import '../component/i_component.dart';
import '../layout/jvx_layout.dart';
import '../layout/jvx_border_layout.dart';

abstract class JVxContainer extends JVxComponent implements IContainer {
  JVxLayout layout;
  List<JVxComponent> components = new List<JVxComponent>();

  JVxContainer(Key componentId, BuildContext context) : super(componentId, context);

  void add(IComponent pComponent) {
    addWithContraintsAndIndex(pComponent, null, -1);
  }

  void addWithConstraints(IComponent pComponent, String pConstraints) {
    addWithContraintsAndIndex(pComponent, pConstraints, -1);
  }

  void addWithIndex(IComponent pComponent, int pIndex) {
    addWithContraintsAndIndex(pComponent, null, pIndex);
  }

  void addWithContraintsAndIndex(IComponent pComponent, String pConstraints, int pIndex) {
      if (pIndex < 0)
			{
				components.add(pComponent);
			}
			else
			{
				components.insert(pIndex, pComponent);
			}

      pComponent.state = JVxComponentState.Added;

      if (layout != null) {
        if (layout is JVxBorderLayout) {
          JVxBorderLayoutConstraints contraints = getJVxBorderLayoutConstraintsFromString(pConstraints);
          layout.addLayoutComponent(pComponent, contraints);
        } else if (layout is JVxFormLayout) {
          layout.addLayoutComponent(pComponent, pConstraints);
        }
      }
    
  }

  void remove(int pIndex) {
      IComponent pComponent = components[pIndex];
      if (layout!=null) {
        layout.removeLayoutComponent(pComponent);
      }
      components.removeAt(pIndex);
  }

  void removeWithComponent(IComponent pComponent) {
    int index = components.indexOf(pComponent); // For compatibility reasons, it has to call remove(int pIndex).
		
		if (index >= 0)
		{
			remove(index);
      pComponent.state = JVxComponentState.Free;
		}
  }

  void removeAll() {
    while (components.length > 0)
		{
			remove(components.length - 1);
		}
  }

  JVxComponent getComponentWithContraint(String constraint) {
    return components?.elementAt(constraints?.indexOf(constraint));
  }

  void updateComponentProperties(Key componentId, ComponentProperties properties) {
    IComponent pComponent = components.firstWhere((c) => c.componentId == componentId);

    pComponent?.updateProperties(properties);

    if (layout != null) {
      if (layout is JVxBorderLayout) {
        JVxBorderLayoutConstraints contraints = layout.getConstraints(pComponent);
        (layout as JVxBorderLayout).addLayoutComponent(pComponent, contraints);
      }
    }
  }
}