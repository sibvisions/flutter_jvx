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
              // we support milliseconds and a fixed string
              ? (json['buildDate'] is String
                  ? json['buildDate']
                  : DateFormat('dd.MM.yyyy')
                      .format(DateTime.fromMillisecondsSinceEpoch(json['buildDate'], isUtc: true)))
              : null,
          version: json['version'],
        );
}
