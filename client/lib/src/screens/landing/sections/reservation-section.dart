import 'package:flutter/material.dart';

/// Reservation section for making table reservations
class ReservationSection extends StatefulWidget {
  const ReservationSection({super.key});

  @override
  State<ReservationSection> createState() => _ReservationSectionState();
}

class _ReservationSectionState extends State<ReservationSection> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 19, minute: 0);
  int _guestCount = 2;
  
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }
  
  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }
  
  void _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }
  
  void _submitReservation() {
    // Validation
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Por favor complete todos los campos requeridos'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }
    
    // Submit logic would go here
    
    // Show confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('¡Reserva enviada con éxito! Le contactaremos pronto para confirmar.'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
    
    // Close modal
    Navigator.pop(context);
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.sizeOf(context);
    final isMobile = size.width < 600;
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Reserva de Mesa',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Llena el formulario para reservar tu mesa en Kako',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 32),
          
          // Reservation form
          isMobile
              ? _buildMobileReservationForm()
              : _buildDesktopReservationForm(),
          
          const SizedBox(height: 24),
          
          // Reservation notes
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.secondaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.secondaryContainer,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: colorScheme.secondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Información Importante',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildReservationInfoItem(
                  'Las reservas deben realizarse con al menos 24 horas de anticipación',
                ),
                _buildReservationInfoItem(
                  'Para grupos de más de 8 personas, por favor contáctenos directamente por teléfono',
                ),
                _buildReservationInfoItem(
                  'Se aplica una política de cancelación de 4 horas',
                ),
                _buildReservationInfoItem(
                  'Las mesas se reservan por un máximo de 2 horas',
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Submit button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _submitReservation,
              icon: const Icon(Icons.check_circle),
              label: const Text('Confirmar Reserva'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMobileReservationForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Guest information
        Text(
          'Información del Cliente',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        // Name field
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Nombre completo *',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.person),
          ),
        ),
        const SizedBox(height: 16),
        
        // Email field
        TextField(
          controller: _emailController,
          decoration: const InputDecoration(
            labelText: 'Email *',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.email),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        
        // Phone field
        TextField(
          controller: _phoneController,
          decoration: const InputDecoration(
            labelText: 'Teléfono *',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.phone),
          ),
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 32),
        
        // Reservation details
        Text(
          'Detalles de la Reserva',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        // Date picker
        InkWell(
          onTap: () => _selectDate(context),
          child: InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Fecha',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.calendar_today),
            ),
            child: Text(
              '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Time picker
        InkWell(
          onTap: () => _selectTime(context),
          child: InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Hora',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.access_time),
            ),
            child: Text(
              '${_selectedTime.hour}:${_selectedTime.minute.toString().padLeft(2, '0')}',
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Guest count
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Número de Personas',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    if (_guestCount > 1) {
                      setState(() {
                        _guestCount--;
                      });
                    }
                  },
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                Text(
                  _guestCount.toString(),
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                IconButton(
                  onPressed: () {
                    if (_guestCount < 12) {
                      setState(() {
                        _guestCount++;
                      });
                    }
                  },
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Special requests
        TextField(
          controller: _notesController,
          decoration: const InputDecoration(
            labelText: 'Solicitudes especiales',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.comment),
          ),
          maxLines: 3,
        ),
      ],
    );
  }
  
  Widget _buildDesktopReservationForm() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Guest information
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Información del Cliente',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              // Name field
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre completo *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),
              
              // Email field
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              
              // Phone field
              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Teléfono *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              
              // Special requests
              TextField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Solicitudes especiales',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.comment),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        
        const SizedBox(width: 24),
        
        // Reservation details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Detalles de la Reserva',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              // Date picker
              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Fecha',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Time picker
              InkWell(
                onTap: () => _selectTime(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Hora',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.access_time),
                  ),
                  child: Text(
                    '${_selectedTime.hour}:${_selectedTime.minute.toString().padLeft(2, '0')}',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Guest count
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Número de Personas',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          if (_guestCount > 1) {
                            setState(() {
                              _guestCount--;
                            });
                          }
                        },
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                      Text(
                        _guestCount.toString(),
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      IconButton(
                        onPressed: () {
                          if (_guestCount < 12) {
                            setState(() {
                              _guestCount++;
                            });
                          }
                        },
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Available time slots (for demonstration)
              Text(
                'Horarios Disponibles',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildTimeSlotChip('12:00'),
                  _buildTimeSlotChip('13:00'),
                  _buildTimeSlotChip('19:00', isSelected: true),
                  _buildTimeSlotChip('20:00'),
                  _buildTimeSlotChip('21:00'),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildTimeSlotChip(String time, {bool isSelected = false}) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return ChoiceChip(
      label: Text(time),
      selected: isSelected,
      selectedColor: colorScheme.primary,
      labelStyle: TextStyle(
        color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
      ),
      onSelected: (bool selected) {
        // Handle time selection
      },
    );
  }
  
  Widget _buildReservationInfoItem(String text) {
    return SizedBox(
      width: double.infinity, // Ensure full width
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('• '),
            Expanded(
              child: Text(text),
            ),
          ],
        ),
      )
    );
  }
}
