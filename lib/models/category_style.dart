import 'package:flutter/material.dart';

/// Icon + color for each expense category.
class CategoryStyle {
  final IconData icon;
  final Color color;
  const CategoryStyle(this.icon, this.color);

  static const Map<String, CategoryStyle> _map = {
    'Food': CategoryStyle(Icons.restaurant, Color(0xFFFF7043)),
    'Travel': CategoryStyle(Icons.directions_car, Color(0xFF42A5F5)),
    'Bills': CategoryStyle(Icons.receipt_long, Color(0xFFAB47BC)),
    'Shopping': CategoryStyle(Icons.shopping_bag, Color(0xFFEC407A)),
    'Health': CategoryStyle(Icons.favorite, Color(0xFF26A69A)),
    'Entertainment': CategoryStyle(Icons.movie, Color(0xFFFFB300)),
    'Other': CategoryStyle(Icons.category, Color(0xFF78909C)),
  };

  static CategoryStyle of(String category) => _map[category] ?? _map['Other']!;
}
