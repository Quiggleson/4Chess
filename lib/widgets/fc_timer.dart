import 'package:flutter/material.dart';
import 'package:fourchess/widgets/fc_button.dart';
import 'dart:async';

class FCTimer extends StatefulWidget {
  const FCTimer(
      {required this.initialTime,
      this.formatMethod,
      this.onTimeout,
      this.style,
      this.enabled = true,
      this.onStop,
      this.onStart,
      this.onTick,
      super.key});

  final double initialTime;
  final ButtonStyle? style;
  final bool enabled;
  final Function(double)? formatMethod;
  final Function(double)? onStart;
  final Function(double)? onStop;
  final Function(double)? onTick;
  final VoidCallback? onTimeout;

  @override
  State<FCTimer> createState() => FCTimerState();
}

class FCTimerState extends State<FCTimer> {
  late bool _timerRunning;
  late double _time;

  @override
  initState() {
    _time = widget.initialTime;
    _timerRunning = false;
    super.initState();
  }

  void _toggle(bool callbacks) {
    _timerRunning = !_timerRunning;

    if (_timerRunning && widget.onStart != null && callbacks) {
      widget.onStart!(_time);
    }
    if (!_timerRunning && widget.onStop != null && callbacks && _time > 0) {
      widget.onStop!(_time);
    }

    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!_timerRunning) {
        timer.cancel();
        return;
      }
      if (_time == 0) {
        if (widget.onTimeout != null) widget.onTimeout!();
        timer.cancel();
        return;
      }

      setState(() {
        _time = (_time - .1 < 0) ? 0 : _time - .1;
        if (widget.onTick != null) widget.onTick!(_time);
      });
    });
  }

  void stop({bool callbacks = true}) {
    //print("TIMER STOP CALLED");
    if (_timerRunning) _toggle(callbacks);
  }

  void start({bool callbacks = true}) {
    if (!_timerRunning) _toggle(callbacks);
  }

  void reset() {
    setState(() => _time = widget.initialTime);
    _timerRunning = false;
  }

  void setTime(double seconds) {
    setState(() => _time = seconds);
  }

  double getTime() {
    return _time;
  }

  bool isRunning() {
    return _timerRunning;
  }

  String convertSecondsToTime(double seconds) {
    int totalSeconds = seconds.toInt();
    int hours = totalSeconds ~/ 3600;
    int minutes = (totalSeconds % 3600) ~/ 60;
    int remainingSeconds = totalSeconds % 60;
    double secondsWithDecimal = seconds - totalSeconds.toDouble();
    int tenthsOfSecond = (secondsWithDecimal * 10).truncate();

    String timeFormat;

    if (hours > 0) {
      timeFormat = '${hours.toString()}:'
          '${minutes.toString().padLeft(2, '0')}:'
          '${remainingSeconds.toString().padLeft(2, '0')}';
    } else if (minutes > 0) {
      timeFormat = '${minutes.toString()}:'
          '${remainingSeconds.toString().padLeft(2, '0')}';
    } else {
      timeFormat = '$remainingSeconds';
      if (remainingSeconds < 60) {
        timeFormat += '.${tenthsOfSecond.toString().padLeft(1, '0')}';
      }
    }

    return timeFormat;
  }

  @override
  Widget build(BuildContext context) {
    return FCButton(
      style: widget.style,
      onPressed: widget.enabled ? () => _toggle(true) : null,
      child: Text(convertSecondsToTime(_time)),
    );
  }
}
