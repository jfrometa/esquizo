import 'package:flutter/material.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/widgets_mesa_redonda/search_card.dart';

class HomeSearchSection extends StatelessWidget {
  final Function(String) onChanged;

  const HomeSearchSection({super.key, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
      child: SearchCard(onChanged: onChanged),
    );
  }
}