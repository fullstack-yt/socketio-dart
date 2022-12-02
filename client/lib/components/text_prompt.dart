import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'filled_button.dart';

showTextPrompt(
  BuildContext context, {
  required String title,
  String placeholder = '',
  String error = '',
  Function(String value)? onSubmit,
}) {
  showGeneralDialog(
    context: context,
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 150),
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return AnimatedBuilder(
        animation: CurvedAnimation(
          parent: animation,
          curve: Curves.easeInExpo,
        ),
        builder: (context, c) {
          return BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: animation.value * 10,
              sigmaY: animation.value * 10,
            ),
            child: Stack(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    color: Colors.black.withOpacity(animation.value * 0.15),
                  ),
                ),
                Opacity(
                  opacity: animation.value,
                  child: Transform.translate(
                    offset: Offset(
                      0,
                      (1 - animation.value) * 30,
                    ),
                    child: child,
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
    pageBuilder: (context, animation, secondaryAnimation) {
      return TextPrompt(
        title: title,
        placeholder: placeholder,
        error: error,
        onSubmit: onSubmit,
      );
    },
  );
}

class TextPrompt extends StatefulWidget {
  final String title;
  final String placeholder;
  final String error;
  final Function(String onSubmit)? onSubmit;
  const TextPrompt({
    super.key,
    required this.title,
    required this.placeholder,
    required this.error,
    this.onSubmit,
  });

  @override
  State<TextPrompt> createState() => _TextPromptState();
}

class _TextPromptState extends State<TextPrompt> {
  TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: max(0, MediaQuery.of(context).viewInsets.bottom - 32),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.all(8),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        decoration: TextDecoration.none,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _controller,
                      autocorrect: false,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: widget.placeholder,
                        hintStyle: TextStyle(
                          fontSize: 18,
                        ),
                        fillColor: const Color(0xFFEEEEEE),
                        filled: true,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            width: 0,
                            color: Colors.transparent,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            width: 0,
                            color: Colors.transparent,
                          ),
                        ),
                      ),
                    ),
                    ...(widget.error.isNotEmpty
                        ? [
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 4),
                                  child: Text(widget.error),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                          ]
                        : [
                            const SizedBox(height: 12),
                          ]),
                    FilledButton(
                      onTap: () {
                        if (_controller.text.isEmpty) return;
                        widget.onSubmit?.call(_controller.text);
                        Navigator.of(context).pop();
                      },
                      text: 'Connect',
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
