import 'dart:math' as math;

import 'package:flutter/material.dart';

class BusMarker extends StatelessWidget {
  const BusMarker({required this.bearing, required this.isRunning, super.key});

  final double bearing;
  final bool isRunning;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Transform.rotate(
      angle: bearing * math.pi / 180,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withValues(alpha: 0.35),
              blurRadius: 18,
              spreadRadius: 4,
            ),
          ],
          border: Border.all(color: Colors.white, width: 3),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Icon(
              Icons.directions_bus_filled_rounded,
              color: Colors.white,
              size: 28,
            ),
            Positioned(
              top: 7,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: isRunning ? 8 : 5,
                height: isRunning ? 8 : 5,
                decoration: BoxDecoration(
                  color: isRunning
                      ? const Color(0xFF30D158)
                      : const Color(0xFFFF9F0A),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
