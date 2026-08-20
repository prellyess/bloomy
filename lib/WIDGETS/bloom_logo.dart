import 'package:flutter/material.dart';

class BloomLogo extends StatelessWidget {
  final double size;
  const BloomLogo({super.key, this.size = 80});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/logoBloomy.png',
      width: size,
      height: size,
    );
  }
}