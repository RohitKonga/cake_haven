import 'package:flutter/material.dart';

class CakeHavenLogo extends StatelessWidget {
  const CakeHavenLogo({
    super.key,
    this.size = 32,
    this.showSubtitle = false,
  });
  
  final double size;
  final bool showSubtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [
              Colors.pink.shade400,
              Colors.pink.shade600,
              Colors.purple.shade400,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: Text(
            'CakeHaven',
            style: TextStyle(
              fontSize: size,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
              color: Colors.white,
              shadows: [
                Shadow(
                  offset: const Offset(2, 2),
                  blurRadius: 4,
                  color: Colors.black.withOpacity(0.2),
                ),
              ],
            ),
          ),
        ),
        if (showSubtitle)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Sweet Delights',
              style: TextStyle(
                fontSize: size * 0.35,
                fontWeight: FontWeight.w300,
                letterSpacing: 3,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }
}

