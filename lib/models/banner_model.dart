import 'package:flutter/material.dart';

class BannerModel {
  final String title;
  final String subtitle;
  final String buttonText;
  final String imageUrl; // Or IconData if keeping it simple like existing code
  final List<Color> gradientColors;
  final Color buttonColor;
  final Color buttonTextColor;

  BannerModel({
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.imageUrl,
    required this.gradientColors,
    required this.buttonColor,
    required this.buttonTextColor,
  });
}
