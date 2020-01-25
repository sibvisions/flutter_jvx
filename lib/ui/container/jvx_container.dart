import 'package:flutter/material.dart';
import 'package:jvx_mobile_v3/model/changed_component.dart';
import 'package:jvx_mobile_v3/model/properties/component_properties.dart';
import 'package:jvx_mobile_v3/ui/component/i_component.dart';
import 'package:jvx_mobile_v3/ui/component/jvx_component.dart';
import 'package:jvx_mobile_v3/ui/container/i_container.dart';
import 'package:jvx_mobile_v3/ui/layout/jvx_border_layout.dart';
import 'package:jvx_mobile_v3/ui/layout/jvx_flow_layout_old.dart';
import 'package:jvx_mobile_v3/ui/layout/jvx_form_layout.dart';
import 'package:jvx_mobile_v3/ui/layout/jvx_grid_layout.dart';
import 'package:jvx_mobile_v3/ui/layout/jvx_layout.dart';
import 'package:jvx_mobile_v3/ui/layout/widgets/jvx_border_layout_constraint.dart';

abstract class JVxContainer extends JVxComponent implements IContainer {
  JVxLayout layout;
  List<IComponent> components = new List<IComponent>();

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
        } else if (layout is JVxFlowLayoutOld) {
          layout.addLayoutComponent(pComponent, pConstraints);
        } else if (layout is JVxGridLayout) {
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
    int index = components.indexWhere((c) => c.componentId.toString() == pComponent.componentId.toString());
    
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
    return components?.firstWhere((component) => component.constraints==constraint);
  }

  void updateComponentProperties(Key componentId, ChangedComponent changedComponent) {
    IComponent pComponent = components.firstWhere((c) => c.componentId == componentId);

    pComponent?.updateProperties(changedComponent);

    preferredSize = changedComponent.getProperty<Size>(ComponentProperty.PREFERRED_SIZE, null);
    maximumSize = changedComponent.getProperty<Size>(ComponentProperty.MAXIMUM_SIZE, null);

    if (layout != null) {
      if (layout is JVxBorderLayout) {
        JVxBorderLayoutConstraints contraints = layout.getConstraints(pComponent);
        (layout as JVxBorderLayout).addLayoutComponent(pComponent, contraints);
      }
    }
  }
}