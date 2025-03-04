import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

// Reservation Screen
class ReservationScreen extends StatelessWidget {
  const ReservationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Table Reservation'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner
            Card(
              elevation: 0,
              color: theme.colorScheme.primaryContainer.withOpacity(0.7),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reserve Your Table',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Book in advance to ensure your spot at Kako',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Date selection
            Text(
              'Select Date',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Date picker placeholder
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(
                  color: theme.colorScheme.outline.withOpacity(0.5),
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Friday, March 1, 2025',
                    style: theme.textTheme.bodyLarge,
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_drop_down,
                    color: theme.colorScheme.onSurface,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Time selection
            Text(
              'Select Time',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Time slots
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildTimeSlot(context, '6:00 PM', true),
                _buildTimeSlot(context, '6:30 PM', true),
                _buildTimeSlot(context, '7:00 PM', false),
                _buildTimeSlot(context, '7:30 PM', true),
                _buildTimeSlot(context, '8:00 PM', true),
                _buildTimeSlot(context, '8:30 PM', true),
                _buildTimeSlot(context, '9:00 PM', false),
                _buildTimeSlot(context, '9:30 PM', true),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Party size
            Text(
              'Number of Guests',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Guest counter
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(
                  color: theme.colorScheme.outline.withOpacity(0.5),
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.people,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    '4 Guests',
                    style: TextStyle(fontSize: 16),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () {},
                    iconSize: 20,
                  ),
                  const SizedBox(
                    width: 40,
                    child: Center(
                      child: Text(
                        '4',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {},
                    iconSize: 20,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Special requests
            Text(
              'Special Requests (Optional)',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Text field
            TextField(
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Any special requirements or preferences...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: theme.colorScheme.outline.withOpacity(0.5),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: theme.colorScheme.outline.withOpacity(0.5),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Reserve button
            ElevatedButton.icon(
              onPressed: () {
                _showReservationConfirmation(context);
              },
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Reserve Table'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTimeSlot(BuildContext context, String time, bool isAvailable) {
    final theme = Theme.of(context);
    
    return ChoiceChip(
      label: Text(time),
      selected: time == '7:30 PM',
      onSelected: isAvailable
          ? (selected) {
              // In a real app, this would update the selected time
            }
          : null,
      backgroundColor: theme.colorScheme.surfaceVariant,
      selectedColor: theme.colorScheme.primaryContainer,
      disabledColor: theme.colorScheme.surfaceVariant.withOpacity(0.5),
      labelStyle: TextStyle(
        color: isAvailable
            ? time == '7:30 PM'
                ? theme.colorScheme.onPrimaryContainer
                : theme.colorScheme.onSurfaceVariant
            : theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
      ),
    );
  }
  
  void _showReservationConfirmation(BuildContext context) {
    final theme = Theme.of(context);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle,
              size: 64,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Reservation Confirmed!',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your table has been reserved for 4 guests on Friday, March 1, 2025 at 7:30 PM.',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Reservation code: RED24031',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Close dialog and return to menu
              Navigator.of(context).pop(); // Close dialog
              // Navigator.of(context).pop(); // Return to menu
              GoRouter.of(context).pop();
              // Add haptic feedback for confirmation
              HapticFeedback.mediumImpact();
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}
