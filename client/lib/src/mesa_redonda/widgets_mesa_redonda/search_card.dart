import 'package:flutter/material.dart';

class SearchCard extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const SearchCard({super.key, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Buscar platos...',
        hintStyle: Theme.of(context)
            .textTheme
            .bodyMedium
            ?.copyWith(color: Colors.grey),
        prefixIcon:
            Icon(Icons.search, color: Theme.of(context).iconTheme.color),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
    );
  }
}
