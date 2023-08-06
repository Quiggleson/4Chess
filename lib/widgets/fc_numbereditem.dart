import 'package:flutter/material.dart';
import 'package:fourchess/theme/fc_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class FCNumberedItem extends StatelessWidget {
  FCNumberedItem(
      {Key? key,
      required this.content,
      required this.number,
      this.numberTextStyle,
      this.contentTextStyle,
      this.height = 90,
      this.numberWidth = 80,
      this.numberBackColor = FCColors.accentBlue,
      this.numberColor,
      this.contentBackColor = FCColors.primaryBlue,
      this.textColor})
      : super(key: key);

  final String content;
  final int number;
  final double height;
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
            height: height,
            width: numberWidth,
            color: numberBackColor,
            child: Text(
              "$number",
              style: numberTextStyle ??
                  GoogleFonts.abel(
                    color: Colors.black,
                    fontSize: 56,
                  ),
            )),
        Expanded(
            child: Container(
                alignment: Alignment.center,
                height: height,
                color: contentBackColor,
                child: Text(
                  content,
                  style: contentTextStyle ??
                      GoogleFonts.abel(
                        color: Colors.black,
                        fontSize: 56,
                      ),
                ))),
      ]),
    );
  }
}
