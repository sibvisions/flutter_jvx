import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SettingsVersionCard extends StatelessWidget {
  final String versionString;
  final String buildDate;
  final String commit;

  const SettingsVersionCard(
      {Key? key,
      required this.versionString,
      required this.buildDate,
      required this.commit})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
        margin: const EdgeInsets.only(left: 8, right: 8),
        color: Colors.white,
        elevation: 2.0,
        child: Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 8),
          child: Column(children: <Widget>[
            ListTile(
              leading: FaIcon(
                FontAwesomeIcons.codeBranch,
              ),
              title: Text(
                versionString,
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
            ListTile(
              leading: FaIcon(FontAwesomeIcons.calendar),
              title: Text(
                buildDate,
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
            ListTile(
              leading: FaIcon(FontAwesomeIcons.github),
              title: Text(
                commit,
                style: TextStyle(color: Colors.grey.shade600),
              ),
            )
          ]),
        ));
  }
}
