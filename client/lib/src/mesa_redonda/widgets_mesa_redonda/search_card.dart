
import 'package:flutter/material.dart';
import 'package:starter_architecture_flutter_firebase/src/theme/colors_palette.dart';

class SearchCard extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const SearchCard({super.key, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Card(
      color: ColorsPaletteRedonda.white,
      elevation: 3,
      child:  TextField(
          onChanged: onChanged,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: ColorsPaletteRedonda
                .deepBrown,
               // Apply deep brown to input text color
          ),
          decoration: InputDecoration(
            suffixIconColor: ColorsPaletteRedonda.primary,
            focusColor: ColorsPaletteRedonda.primary,
            hintText: 'Buscar platos...',
            hintStyle: theme.textTheme.bodyMedium
                ?.copyWith(color: Colors.grey[500]), // Lighter brown for hints
            prefixIcon:
                const Icon(Icons.search, color: ColorsPaletteRedonda.primary),
            filled: true, // Optional: turn on filling behavior
            fillColor: theme.inputDecorationTheme
                .fillColor, // Use fill color from the theme if specified
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide
                  .none, // Typically borders are not visible until focused
            ),
            enabledBorder: OutlineInputBorder(
              // Normal state border
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: theme.dividerColor, width: 0.5),
            ),
            focusedBorder: OutlineInputBorder(
              // Border when the TextField is focused
              borderRadius: BorderRadius.circular(12.0),
              borderSide:
                  BorderSide(color: theme.colorScheme.primary, width: 2.0),
            ),
          ),
        ),
      
    );
  }
}
