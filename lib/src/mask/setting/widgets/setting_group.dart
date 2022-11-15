import 'package:flutter/material.dart';

import 'setting_item.dart';

class SettingGroup extends StatelessWidget {
  const SettingGroup({
    super.key,
    required this.groupHeader,
    required this.items,
  });

  /// Name of the settings name
  final Widget groupHeader;

  /// All items of this settings group
  final List<SettingItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(10),
          child: groupHeader,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
          child: Card(
            elevation: 5,
            child: Column(children: items),
          ),
        )
      ],
    );
  }
}
