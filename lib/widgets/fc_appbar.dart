import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class FCAppBar extends AppBar {
  FCAppBar(
      {Key? key,
      Widget? leading,
      bool automaticallyImplyLeading = true,
      Widget? title,
      List<Widget>? actions,
      Widget? flexibleSpace,
      PreferredSizeWidget? bottom,
      double? elevation,
      double? scrolledUnderElevation,
      ScrollNotificationPredicate notificationPredicate =
          defaultScrollNotificationPredicate,
      Color? shadowColor,
      Color? surfaceTintColor,
      ShapeBorder? shape,
      Color? backgroundColor,
      Color? foregroundColor,
      IconThemeData? iconTheme,
      IconThemeData? actionsIconTheme,
      bool primary = true,
      bool? centerTitle,
      bool excludeHeaderSemantics = false,
      double? titleSpacing,
      double toolbarOpacity = 1.0,
      double bottomOpacity = 1.0,
      double? toolbarHeight,
      double? leadingWidth,
      TextStyle? toolbarTextStyle,
      TextStyle? titleTextStyle,
      SystemUiOverlayStyle? systemOverlayStyle,
      bool forceMaterialTransparency = false,
      Clip? clipBehavior})
      : super(
            key: key,
            leading: leading ??
                const Padding(
                    padding: EdgeInsets.all(10),
                    child: Text("←",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 56, fontFamily: "Arial"))),
            automaticallyImplyLeading: automaticallyImplyLeading,
            title: title,
            actions: actions,
            flexibleSpace: flexibleSpace,
            bottom: bottom,
            elevation: elevation ?? 0,
            scrolledUnderElevation: scrolledUnderElevation,
            notificationPredicate: notificationPredicate,
            shadowColor: shadowColor,
            surfaceTintColor: surfaceTintColor,
            shape: shape ??
                const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                )),
            backgroundColor:
                backgroundColor ?? const Color.fromRGBO(130, 195, 255, 1),
            foregroundColor: foregroundColor ?? Colors.black,
            iconTheme: iconTheme,
            actionsIconTheme: actionsIconTheme,
            primary: primary,
            centerTitle: centerTitle ?? true,
            excludeHeaderSemantics: excludeHeaderSemantics,
            titleSpacing: titleSpacing,
            toolbarOpacity: toolbarOpacity,
            bottomOpacity: bottomOpacity,
            toolbarHeight: toolbarHeight ?? 90,
            leadingWidth: leadingWidth,
            toolbarTextStyle: toolbarTextStyle,
            titleTextStyle: titleTextStyle ??
                GoogleFonts.abel(fontSize: 56, color: Colors.black),
            systemOverlayStyle: systemOverlayStyle,
            forceMaterialTransparency: forceMaterialTransparency,
            clipBehavior: clipBehavior);
}
