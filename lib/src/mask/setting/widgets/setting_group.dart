import 'package:flutter/material.dart';
import 'package:flutter_client/src/mask/setting/widgets/setting_item.dart';

class SettingGroup extends StatelessWidget {
  const SettingGroup({
    Key? key,
    required this.groupHeader,
    required this.items
  }) : super(key: key);

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
          padding: const EdgeInsets.fromLTRB(5,0,5,0),
          child: Card(
            elevation: 5,
            child: Column(
              children: items
            ),
          ),
        )
      ],
    );
  }
}
