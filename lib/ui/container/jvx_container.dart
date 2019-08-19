import 'package:flutter/material.dart';
import 'i_container.dart';
import '../component/jvx_component.dart';
import '../component/i_component.dart';
import '../layouts/i_layout.dart';

abstract class JVxContainer extends JVxComponent implements IContainer {
  ILayout layout;
  JVxContainer(Key componentId) : super(componentId);

  ///
	/// Checks if it's allowed to add a specific component to this container.
	/// 
	/// @param pComponent the component to be added
  /// @param pConstraints an object expressing layout constraints
	/// @param pIndex the position in the container's list at which to insert the IComponent; -1 means insert at the end component
	///
	void checkAdd(IComponent pComponent, Object pConstraints, int pIndex)
	{
    if (pComponent == null)
    {
        throw new ArgumentError("Component can't be null!");
    }
	    
		if (!(pComponent is JVxComponent))
		{
			throw new ArgumentError("Only JVxComponents may be added to JVxContainer!"); 
		}
	}
}