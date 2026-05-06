import 'package:flutter/material.dart';

class Disease {
  final String name;
  final IconData
  icon; // Using IconData for simplicity as per implementation plan
  final Color color;

  Disease({required this.name, required this.icon, required this.color});
}
