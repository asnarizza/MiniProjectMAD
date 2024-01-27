import 'package:flutter/material.dart';

class StarRating extends StatelessWidget {
  final double rating;
  final double size;
  final Color color;
  final IconData filledStar;
  final IconData unfilledStar;

  StarRating({
    required this.rating,
    this.size = 24.0,
    this.color = Colors.yellow,
    this.filledStar = Icons.star,
    this.unfilledStar = Icons.star_border,
  });

  @override
  Widget build(BuildContext context) {
    int numberOfFilledStars = rating.floor();
    double fraction = rating - numberOfFilledStars;

    return Row(
      children: List.generate(5, (index) {
        if (index < numberOfFilledStars) {
          return Icon(
            filledStar,
            size: size,
            color: color,
          );
        } else if (index == numberOfFilledStars && fraction > 0) {
          // If there is a fractional part, display a partially filled star
          return Icon(
            filledStar,
            size: size,
            color: color,
          );
        } else {
          return Icon(
            unfilledStar,
            size: size,
            color: color,
          );
        }
      }),
    );
  }
}
