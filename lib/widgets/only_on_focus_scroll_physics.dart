import 'package:flutter/material.dart';

class OnlyOnFocusScrollPhysics extends NeverScrollableScrollPhysics {
  const OnlyOnFocusScrollPhysics({super.parent});

  @override
  bool get allowImplicitScrolling {
    return true;
  }

  @override
  OnlyOnFocusScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return OnlyOnFocusScrollPhysics(parent: buildParent(ancestor));
  }
}
