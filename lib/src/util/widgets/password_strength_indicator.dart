import 'package:flutter/material.dart';

class PasswordStrengthIndicator extends StatelessWidget {
    final String password;

    const PasswordStrengthIndicator({
      super.key,
      required this.password
    });

    @override
    Widget build(BuildContext context) {
        final _PasswordStrength result = _evaluatePassword(password);

        //Don't use LayoutBuilder or AnimatedFractionallySizedBox
        return Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
                ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                        height: 6,
                        color: Colors.grey[300],
                        child: TweenAnimationBuilder<double>(
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
                    child: Text(result.label),
                ),
            ],
        );
    }

  _PasswordStrength _evaluatePassword(String password) {
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
      return _PasswordStrength(score, "Very weak", Colors.grey);
    }
    else if (score <= 0.4) {
      return _PasswordStrength(score, "Weak", Colors.deepOrange);
    }
    else if (score <= 0.6) {
      return _PasswordStrength(score, "Fair", Colors.orangeAccent);
    }
    else if (score <= 0.8) {
      return _PasswordStrength(score, "Good", Colors.lightGreen);
    }
    else {
      return _PasswordStrength(score, "Strong", Colors.green);
    }
  }
}

class _PasswordStrength {
  final double value;
  final String label;
  final Color color;

  _PasswordStrength(this.value, this.label, this.color);
}
