import 'package:intl/intl.dart';

class VersionConfig {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  final String? commit;
  final String? buildDate;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const VersionConfig({
    this.commit,
    this.buildDate,
  });

  const VersionConfig.empty() : this();

  VersionConfig.fromJson(Map<String, dynamic> json)
      : this(
          commit: json['commit'],
          buildDate: json['buildDate'] != null
              // we support milliseconds and a fixed string
              ? (json['buildDate'] is String
                  ? json['buildDate']
                  : DateFormat('dd.MM.yyyy')
                      .format(DateTime.fromMillisecondsSinceEpoch(json['buildDate'], isUtc: true)))
              : null,
        );

  VersionConfig merge(VersionConfig? other) {
    if (other == null) return this;

    return VersionConfig(
      commit: other.commit ?? commit,
      buildDate: other.buildDate ?? buildDate,
    );
  }
}
