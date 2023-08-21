import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fourchess/theme/fc_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class FCNumberedItem extends StatelessWidget {
  const FCNumberedItem(
      {Key? key,
      required this.content,
      required this.number,
      this.numberTextStyle,
      this.contentTextStyle,
      this.height = 40,
      this.maxHeight = 120,
      this.minHeight = 40,
      this.numberWidth = 80,
      this.numberBackColor = FCColors.accentBlue,
      this.numberColor,
      this.contentBackColor = FCColors.primaryBlue,
      this.textColor})
      : super(key: key);

  final String content;
  final int number;
  final double height;
  final double maxHeight;
  final double minHeight;
  final double numberWidth;
  final Color numberBackColor;
  final Color? numberColor;
  final Color? contentBackColor;
  final Color? textColor;
  final TextStyle? numberTextStyle;
  final TextStyle? contentTextStyle;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)),
      child: Row(children: [
        Container(
            alignment: Alignment.center,
            constraints: BoxConstraints(
              maxHeight: _calcHeight(height, maxHeight, minHeight),
              maxWidth: numberWidth,
            ),
            color: numberBackColor,
            child: Text(
              "$number",
              style: numberTextStyle ??
                  GoogleFonts.abel(
                    color: Colors.black,
                    fontSize: 24,
                  ),
            )),
        Expanded(
            child: Container(
                alignment: Alignment.center,
                constraints: BoxConstraints(
                    maxHeight: _calcHeight(height, maxHeight, minHeight)),
                color: contentBackColor,
                child: Text(
                  content,
                  style: contentTextStyle ??
                      GoogleFonts.abel(
                        color: Colors.black,
                        fontSize: 24,
                      ),
                ))),
      ]),
    );
  }

  double _calcHeight(double height, double maxHeight, double minHeight) {
    if (minHeight < height && height < maxHeight) {
      return height;
    }

    if (height < minHeight) {
      return minHeight;
    }

    return maxHeight;
  }
}
