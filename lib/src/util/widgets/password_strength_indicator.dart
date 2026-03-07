/*
 * Copyright 2026 SIB Visions GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy of
 * the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 */

import 'package:flutter/material.dart';

import '../../flutter_ui.dart';
import '../jvx_colors.dart';

class PasswordStrengthIndicator extends StatelessWidget {
  final String password;

  final bool hideLabel;

  final bool coloring;

  const PasswordStrengthIndicator({
    super.key,
    required this.password,
    this.hideLabel = false,
    this.coloring = true
  });

  @override
  Widget build(BuildContext context) {
    final _PasswordStrength result = _evaluatePassword(context, password);

    //Don't use LayoutBuilder or AnimatedFractionallySizedBox
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Container(
            height: 6,
            color: JVxColors.isLightTheme(context) ? Colors.grey[300] : Colors.grey[700],
            child: !coloring || result.value == 0 ? null :
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: result.value),
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                builder: (context, value, child) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Transform.scale(
                      alignment: Alignment.centerLeft,
                      scaleX: value,
                      child: Container(
                        decoration: BoxDecoration(
                          color: result.color,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                  );
                },
              ),
          ),
        ),
        const SizedBox(height: 4),
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 300),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: result.color,
          ),
          child: Text(hideLabel ? "" : FlutterUI.translate(result.label)),
        ),
      ],
    );
  }

  _PasswordStrength _evaluatePassword(BuildContext context, String password) {
    bool isLight = JVxColors.isLightTheme(context);

    double score = 0;

    if (password.length >= 6) score += 0.2;

    if (password.length >= 10) {
      score += 0.2;
    }

    if (password.contains(RegExp(r'[A-Z]'))) {
      score += 0.2;
    }

    if (password.contains(RegExp(r'[0-9]'))) {
      score += 0.2;
    }

    if (password.contains(RegExp(r'[^A-Za-z0-9]'))) {
      score += 0.2;
    }

    //avoid floating point problems
    score = double.parse(score.toStringAsFixed(2));

    if (score <= 0.2) {
      return _PasswordStrength(score, "Very weak", isLight ? Colors.grey : Colors.grey[500] ?? Colors.grey);
    } else if (score <= 0.4) {
      return _PasswordStrength(score, "Weak", isLight ? Colors.deepOrange : Colors.deepOrange[400] ?? Colors.deepOrange);
    } else if (score <= 0.6) {
      return _PasswordStrength(score, "Fair", isLight ? Colors.orangeAccent : Colors.orangeAccent[200] ?? Colors.orangeAccent);
    } else if (score <= 0.8) {
      return _PasswordStrength(score, "Good", isLight ? Colors.lightGreen : Colors.lightGreen[800] ?? Colors.lightGreen);
    } else {
      return _PasswordStrength(score, "Strong", isLight ? Colors.green : Colors.green[800] ?? Colors.green);
    }
  }
}

class _PasswordStrength {
  final double value;
  final String label;
  final Color color;

  _PasswordStrength(
    this.value,
    this.label,
    this.color
  );
}
