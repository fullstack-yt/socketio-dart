import 'package:flutter/material.dart';
import 'package:awesome/awesome.dart';

class FilledButton extends StatelessWidget {
  final Function() onTap;
  final String text;
  final Color backgroundColor;
  final Color textColor;
  const FilledButton({
    super.key,
    required this.onTap,
    required this.text,
    this.backgroundColor = const Color(0xFFFF9D00),
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return TapScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: backgroundColor,
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 18,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}
