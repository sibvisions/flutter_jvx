class OfflineConfig {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  final bool? checkConstraints;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const OfflineConfig({
    this.checkConstraints,
  });

  const OfflineConfig.empty()
      : this(
          checkConstraints: true,
        );

  OfflineConfig.fromJson(Map<String, dynamic> json)
      : this(
          checkConstraints: json['checkConstraints'],
        );

  OfflineConfig merge(OfflineConfig? other) {
    if (other == null) return this;

    return OfflineConfig(
      checkConstraints: other.checkConstraints ?? checkConstraints,
    );
  }
}
