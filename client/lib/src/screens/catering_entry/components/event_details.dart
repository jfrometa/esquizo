// lib/src/mesa_redonda/catering_entry/widgets/event_details.dart
import 'package:flutter/material.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/catering_entry/components/aditional_input_field.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/catering_entry/widgets/allergies_selector.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/catering_entry/widgets/people_quantity_selector.dart';

class EventDetails extends StatelessWidget {
  final TextEditingController eventTypeController;
  final TextEditingController customPersonasController;
  final TextEditingController adicionalesController;

  const EventDetails({
    super.key,
    required this.eventTypeController,
    required this.customPersonasController,
    required this.adicionalesController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PeopleQuantitySelector( 
           quantities: [25, 50],
          // Provide additional callbacks and properties as needed.
        ),
        const SizedBox(height: 16),
        TextField(
          controller: eventTypeController,
          decoration: const InputDecoration(
            labelText: 'Tipo de Evento',
            hintText: 'Ej. Cumpleaños, Boda',
            border: OutlineInputBorder(),
            filled: true,
          ),
        ),
        const SizedBox(height: 16),
        AllergiesSelector(),
        const SizedBox(height: 16),
        AdditionalNotesInput(controller: adicionalesController),
      ],
    );
  }
}