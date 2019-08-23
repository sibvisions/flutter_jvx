import 'package:flutter/material.dart';
import 'i_container.dart';
import '../component/jvx_component.dart';
import '../component/i_component.dart';
import '../layout/jvx_layout.dart';

abstract class JVxContainer extends JVxComponent implements IContainer {
  JVxLayout layout;
  List<JVxComponent> components = new List<JVxComponent>();

  JVxContainer(Key componentId) : super(componentId);

  void add(IComponent pComponent) {
    addWithContraintsAndIndex(pComponent, null, -1);
  }

  void addWithConstraints(IComponent pComponent, Object pConstraints) {
    addWithContraintsAndIndex(pComponent, pConstraints, -1);
  }

  void addWithIndex(IComponent pComponent, int pIndex) {
    addWithContraintsAndIndex(pComponent, null, pIndex);
  }

  void addWithContraintsAndIndex(IComponent pComponent, Object pConstraints, int pIndex) {
      if (pIndex < 0)
			{
				components.add(pComponent);
			}
			else
			{
				components.insert(pIndex, pComponent);
			}

      if (layout != null) {
        layout.addLayoutComponent(pComponent, pConstraints);
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
		}
  }

  void removeAll() {
    while (components.length > 0)
		{
			remove(components.length - 1);
		}
  }
}