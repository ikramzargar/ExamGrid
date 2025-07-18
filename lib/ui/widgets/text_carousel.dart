import 'dart:async';

import 'package:flutter/material.dart';

class TextCarousel extends StatefulWidget {
  const TextCarousel({super.key});

  @override
  State<TextCarousel> createState() => _TextCarouselState();
}

class _TextCarouselState extends State<TextCarousel> {
  final List<String> texts = [
    'Get Ready for JE Civil 2025',
    '2500+ Questions with Solutions',
    'Pay Once, Practice Unlimited',
  ];

  int _index = 0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      setState(() {
        _index = (_index + 1) % texts.length;
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 600),
      child: Container(
        height: 150,
        child: Text(
          texts[_index],
          key: ValueKey<String>(texts[_index]),
          style: const TextStyle(fontSize: 30, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}