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
    try {
      final theme = Theme.of(context);
      final colorScheme = theme.colorScheme;
      
      final DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 30)),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              useMaterial3: true,
              colorScheme: colorScheme,
            ),
            child: child!,
          );
        },
      );

      if (!context.mounted) return;
      if (pickedDate == null) return;

      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              useMaterial3: true,
              colorScheme: colorScheme,
              timePickerTheme: TimePickerThemeData(
                backgroundColor: colorScheme.surface,
                hourMinuteTextColor: colorScheme.onSurface,
                dayPeriodTextColor: colorScheme.onSurface,
                dialHandColor: colorScheme.primary,
                dialBackgroundColor: colorScheme.surfaceVariant,
              ),
            ),
            child: child!,
          );
        },
      );

      if (!context.mounted) return;
      if (pickedTime == null) return;

      final DateTime selectedDateTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );

      final formattedDate = DateFormat('dd MMM yyyy').format(selectedDateTime);
      final formattedTime = DateFormat('HH:mm').format(selectedDateTime);
      
      dateController.text = formattedDate;
      timeController.text = formattedTime;

      onValidationUpdate('date');
      onValidationUpdate('time');
    } catch (e) {
      debugPrint('Error in DateTimePicker: $e');
      // Show error snackbar
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Error al seleccionar fecha y hora'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}