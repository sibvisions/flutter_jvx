import 'package:intl/intl.dart';

class VersionConfig {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  final String? commit;
  final String? buildDate;
  final String? version;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const VersionConfig({
    this.commit,
    this.buildDate,
    this.version,
  });

  const VersionConfig.empty() : this();

  VersionConfig.fromJson({required Map<String, dynamic> json})
      : this(
          commit: json['commit'],
          buildDate: json['buildDate'] != null
              ? DateFormat('dd.MM.yyyy').format(DateTime.fromMillisecondsSinceEpoch(json['buildDate']))
              : null,
          version: json['version'],
        );
}
