import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class FCLoadingAnimation extends StatefulWidget {
  const FCLoadingAnimation({super.key});

  @override
  State<FCLoadingAnimation> createState() => _FCLoadingAnimationState();
}

class _FCLoadingAnimationState extends State<FCLoadingAnimation> {
  @override
  Widget build(BuildContext context) {
    return LoadingAnimationWidget.fourRotatingDots(
        color: Colors.black, size: 60);
  }
}
