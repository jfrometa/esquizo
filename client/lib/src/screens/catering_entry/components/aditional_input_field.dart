// lib/src/mesa_redonda/catering_entry/widgets/additional_notes_input.dart
import 'package:flutter/material.dart';

class AdditionalNotesInput extends StatelessWidget {
  final TextEditingController controller;
  const AdditionalNotesInput({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: 3,
      decoration: const InputDecoration(
        labelText: 'Notas Adicionales',
        hintText: 'Escribe cualquier nota adicional',
        border: OutlineInputBorder(),
        filled: true,
      ),
    );
  }
}