import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:starter_architecture_flutter_firebase/src/theme/colors_palette.dart';

class DateTimePicker2 {
  static Future<void> show({
    required BuildContext context,
    required TextEditingController dateController,
    required TextEditingController timeController,
    required Function(String) onValidationUpdate,
  }) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: _buildTheme,
    );

    if (pickedDate == null) {
      debugPrint('Selección de fecha cancelada');
      return;
    }

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
      builder: _buildTheme,
    );

    if (pickedTime == null) {
      debugPrint('Selección de hora cancelada');
      return;
    }

    final DateTime selectedDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDateTime);
    final formattedTime = DateFormat('HH:mm').format(selectedDateTime);
    dateController.text = '$formattedDate - $formattedTime';
    timeController.text = formattedTime;

    onValidationUpdate('date');
    onValidationUpdate('time');
  }

  static Widget _buildTheme(BuildContext context, Widget? child) {
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: ColorScheme.light(
          primary: ColorsPaletteRedonda.primary,
          onPrimary: ColorsPaletteRedonda.white,
          onSurface: ColorsPaletteRedonda.deepBrown1,
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: ColorsPaletteRedonda.primary,
          ),
        ),
      ),
      child: child!,
    );
  }
}