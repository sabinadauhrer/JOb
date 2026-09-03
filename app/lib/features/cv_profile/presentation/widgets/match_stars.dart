import 'package:flutter/material.dart';

/// Renders a job's CV-match score (0..1) as a row of five star icons.
class MatchStars extends StatelessWidget {
  const MatchStars({super.key, required this.score, this.size = 18});

  final double score;
  final double size;

  @override
  Widget build(BuildContext context) {
    final filledStars = (score * 5).round().clamp(0, 5);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < 5; i++)
          Image.asset(
            'assets/icons/icon_star_match.png',
            width: size,
            height: size,
            // Caps decoded bitmap size regardless of the source file's
            // resolution - this icon renders up to 5x per list row, so an
            // undersized cache here previously caused an OOM crash on device.
            cacheWidth: (size * 3).round(),
            color: i < filledStars ? null : Colors.grey.withValues(alpha: 0.3),
            colorBlendMode: i < filledStars ? null : BlendMode.saturation,
            errorBuilder: (context, error, stackTrace) => Icon(
              Icons.star,
              size: size,
              color: i < filledStars ? Colors.amber : Colors.grey.withValues(alpha: 0.3),
            ),
          ),
      ],
    );
  }
}
