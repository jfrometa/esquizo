import 'package:flutter/material.dart';

/// Utility class to safely convert string icon codes to constant IconData objects
class IconMapper {
  /// Map of icon code strings to their corresponding IconData constants
  static final Map<String, IconData> _iconMap = {
    // Material icons
    '0xe318': Icons.restaurant,
    '0xe5d2': Icons.menu_book,
    '0xe25a': Icons.fastfood,
    '0xe57f': Icons.local_bar,
    '0xe544': Icons.icecream,
    '0xe532': Icons.cake,
    '0xe533': Icons.breakfast_dining,
    '0xe574': Icons.lunch_dining,
    '0xe575': Icons.dinner_dining,
    '0xe3f8': Icons.category_outlined,
    '0xe3f7': Icons.category,
    '0xe8f8': Icons.shopping_cart,
    '0xe8f9': Icons.shopping_cart_outlined,
    '0xe8b6': Icons.settings,
    '0xe8b7': Icons.settings_outlined,
    '0xe0b0': Icons.add_circle,
    '0xe0b1': Icons.add_circle_outline,
    '0xe156': Icons.delete,
    '0xe157': Icons.delete_outline,
    '0xe3c9': Icons.edit,
    '0xe3ca': Icons.edit_outlined,
    '0xe8e5': Icons.save,
    '0xe8e6': Icons.save_outlined,
    '0xe5cd': Icons.close,
    '0xe5ce': Icons.close_outlined,
    '0xe876': Icons.check,
    '0xe877': Icons.check_outlined,
    '0xe8b8': Icons.star,
    '0xe8b9': Icons.star_outline,
    '0xe8f4': Icons.favorite,
    '0xe8f5': Icons.favorite_outline,
    // Add more mappings as needed
  };

  /// Get IconData from string code
  /// Returns a default icon if the code is not found
  static IconData getIconData(String? iconCode) {
    if (iconCode == null || iconCode.isEmpty) {
      return Icons.category_outlined;
    }
    
    return _iconMap[iconCode] ?? Icons.category_outlined;
  }
  
  /// Get IconData from int code
  /// This is a convenience method for when you have the code as an int
  static IconData getIconDataFromInt(int? iconCode) {
    if (iconCode == null) {
      return Icons.category_outlined;
    }
    
    return getIconData('0x${iconCode.toRadixString(16)}');
  }
}