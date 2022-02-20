import 'dart:async';

import 'package:flutter/material.dart';

class CountDownText extends StatefulWidget {
  const CountDownText({Key? key, required this.duration}) : super(key: key);

  final Duration duration;

  @override
  _CountDownTextState createState() => _CountDownTextState();
}

class _CountDownTextState extends State<CountDownText> {
  late int seconds;
  late int leftSeconds;

  @override
  void initState() {
    super.initState();
    seconds = widget.duration.inSeconds;
    leftSeconds = seconds;
    Timer.periodic(const Duration(seconds: 1), (time) {
      if (time.tick == seconds) time.cancel();
      if (mounted) {
        setState(() {
          leftSeconds--;
        });
      }
    });
  }

  String get _dots => '...'.substring(leftSeconds % 3);

  @override
  Widget build(BuildContext context) {
    //TODO: Improve view
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          'Koniec podróży, ekran zamknie się za: $leftSeconds$_dots',
          style: const TextStyle(
            fontSize: 20,
          ),
        ),
      ),
    );
  }
}
