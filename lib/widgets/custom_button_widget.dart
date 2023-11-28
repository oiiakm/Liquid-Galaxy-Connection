import 'package:flutter/material.dart';
import 'package:liquid_galaxy_connection/utils/responsive.dart';

class CustomButtonWidget extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final VoidCallback onPressed;

  const CustomButtonWidget({
    super.key,
    required this.text,
    required this.backgroundColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    double buttonWidth = ResponsiveUtils.calculateButtonWidth();
    double buttonHeight = ResponsiveUtils.calculateButtonHeight();
    return SizedBox(
      width: buttonWidth,
      height: buttonHeight,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
        ),
        child: Text(
          text,
          style: TextStyle(fontSize: ResponsiveUtils.calculateTextSize()),
        ),
      ),
    );
  }
}
