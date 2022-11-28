import 'package:flutter/material.dart';

import '../custom/custom_header.dart';
import '../util/jvx_colors.dart';

class CustomHeaderExample extends CustomHeader {
  const CustomHeaderExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: JVxColors.LIGHTER_BLACK,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(120);
}
