import 'package:flutter/material.dart';

IconData habitIconData(String iconName) {
  switch (iconName) {
    case 'mosque':
      return Icons.mosque;
    case 'book':
      return Icons.menu_book;
    case 'stars':
      return Icons.stars;
    case 'volunteer_activism':
      return Icons.volunteer_activism;
    case 'nightlight':
      return Icons.nightlight;
    default:
      return Icons.check_circle_outline;
  }
}
