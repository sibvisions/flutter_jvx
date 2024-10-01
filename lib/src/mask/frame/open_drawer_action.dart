import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class OpenDrawerAction extends StatelessWidget {
  const OpenDrawerAction({super.key});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) => IconButton(
        tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
        splashRadius: kToolbarHeight / 2,
        icon: const FaIcon(FontAwesomeIcons.ellipsisVertical),
        onPressed: () => Scaffold.of(context).openEndDrawer(),
      ),
    );
  }
}
