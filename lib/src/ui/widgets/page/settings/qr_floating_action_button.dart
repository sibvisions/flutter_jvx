import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class QrFloatingActionButton extends StatelessWidget {
  final FaIcon icon;
  final VoidCallback onPressed;
  final bool isMini;

  const QrFloatingActionButton({
    Key? key,
    required this.icon,
    required this.onPressed,
    this.isMini = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      clipBehavior: Clip.antiAlias,
      mini: isMini,
      onPressed: onPressed,
      backgroundColor: Theme.of(context).primaryColor,
      child: icon,
    );
  }
}
