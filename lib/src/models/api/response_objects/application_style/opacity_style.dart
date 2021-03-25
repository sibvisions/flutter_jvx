class OpacityStyle {
  final double? controlsOpacity;
  final double? menuOpacity;
  final double? sideMenuOpacity;

  OpacityStyle({this.controlsOpacity, this.menuOpacity, this.sideMenuOpacity});

  OpacityStyle.fromJson(Map<String, dynamic> map)
      : assert(map.isNotEmpty),
        controlsOpacity = double.tryParse(map['controls']),
        menuOpacity = double.tryParse(map['menu']),
        sideMenuOpacity = double.tryParse(map['sidemenu']);

  Map<String, dynamic> toJson() => <String, dynamic>{
        'controls': controlsOpacity?.toString(),
        'menu': menuOpacity?.toString(),
        'sidemenu': sideMenuOpacity?.toString()
      };
}
