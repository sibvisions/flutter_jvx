import 'package:flutter/material.dart';

import '../../component/component_widget.dart';
import '../../widgets/custom/custom_icon.dart';

class CustomTabset extends StatelessWidget {
  final List<ComponentWidget> components;
  final List<bool> isEnabled;
  final List<bool> isClosable;
  final Function(int index) onTap;
  final Function(int index) onClose;
  final int index;

  const CustomTabset(
      {Key key,
      @required this.components,
      @required this.onTap,
      @required this.onClose,
      @required this.index,
      @required this.isEnabled,
      @required this.isClosable})
      : super(key: key);

  _onClose(int index) {
    if (this.isClosable[index]) {
      this.onClose(index);
    }
  }

  _onTap(BuildContext context, int index) {
    if (!this.isEnabled[DefaultTabController.of(context).index]) {
      int index = DefaultTabController.of(context).previousIndex;
      DefaultTabController.of(context).index = index;
    } else {
      this.onTap(index);
    }
  }

  List<Tab> _getTabs(List<ComponentWidget> components) {
    List<Tab> tabs = <Tab>[];

    components.forEach((component) {
      List splittedConstr = component.componentModel.constraints?.split(';');
      bool enabled = (splittedConstr[0]?.toLowerCase() == 'true');
      bool closable = (splittedConstr[1]?.toLowerCase() == 'true');
      String text = splittedConstr[2];
      String img = splittedConstr.length >= 4 ? splittedConstr[3] : '';

      if (!(this.isEnabled.length + 1 > this.components.length))
        this.isEnabled.add(enabled);
      if (!(this.isClosable.length + 1 > this.components.length))
        this.isClosable.add(closable);

      double iconSize = 15;

      Tab tab = Tab(
        child: Column(
          children: [
            img != null && img.isNotEmpty
                ? CustomIcon(
                    image: img,
                    size: Size(iconSize, iconSize),
                    color: Colors.grey.shade700,
                  )
                : Container(height: iconSize),
            SizedBox(
              height: 5,
            ),
            !closable
                ? Text(
                    text ?? '',
                    style: !enabled ? TextStyle(color: Colors.grey) : null,
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(text ?? '',
                          style:
                              !enabled ? TextStyle(color: Colors.grey) : null),
                      SizedBox(
                        width: 20,
                      ),
                      GestureDetector(
                        child: Icon(
                          Icons.clear,
                          size: 20,
                        ),
                        onTap: () {
                          _onClose(this.components.indexOf(component));
                        },
                      ),
                    ],
                  ),
          ],
        ),
      );

      tabs.add(tab);
    });

    return tabs;
  }

  List<Widget> _getChildren(List<ComponentWidget> components) {
    List<Widget> children = <Widget>[];

    components.forEach((component) {
      children.add(component);
    });

    return children;
  }

  @override
  Widget build(BuildContext context) {
    if (this.isEnabled.length > DefaultTabController.of(context).index &&
        !this.isEnabled[DefaultTabController.of(context).index]) {
      DefaultTabController.of(context).index = 0;
      DefaultTabController.of(context).animateTo(0);
    } else if (this.index != DefaultTabController.of(context).index &&
        this.isEnabled.length > this.index &&
        this.isEnabled[this.index]) {
      DefaultTabController.of(context).index = this.index;
      DefaultTabController.of(context).animateTo(this.index);
    }

    return Container(
      child: Column(
        children: [
          Flexible(
            flex: 2,
            child: TabBar(
              isScrollable: true,
              indicatorColor: Colors.black,
              tabs: _getTabs(this.components),
              onTap: (index) => this._onTap(context, index),
            ),
          ),
          Flexible(
            flex: 10,
            child: TabBarView(
              children: _getChildren(this.components),
            ),
          )
        ],
      ),
    );
  }
}
