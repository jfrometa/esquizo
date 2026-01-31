// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/providers/catering_order_provider.dart';
// import 'package:starter_architecture_flutter_firebase/src/theme/colors_palette.dart';

// class CateringForm extends ConsumerStatefulWidget {
//   const CateringForm({
//     super.key,
//     required this.onSubmit,
//   });

//   final Function(bool hasChef, String alergias, String eventType, 
//     String preferencia, String adicionales, int cantidadPersonas) onSubmit;

//   @override
//   ConsumerState<CateringForm> createState() => _CateringFormState();
// }

// class _CateringFormState extends ConsumerState<CateringForm> {
//   final TextEditingController customPersonasController = TextEditingController();
//   final TextEditingController eventTypeController = TextEditingController();
//   final FocusNode customPersonasFocusNode = FocusNode();
  
//   bool isCustomSelected = false;
//   List<String> alergiasList = [];
//   String? allergyInput = '';
//   bool hasChef = false;
//   String preferencia = 'salado';
//   String adicionales = '';
//   int? cantidadPersonasRead;

//   final peopleQuantity = [10, 20, 30, 40, 50, 100, 200, 300, 400, 500, 1000, 2000, 5000, 10000];

//   @override
//   void initState() {
//     super.initState();
//     _initializeFormData();
//   }

//   void _initializeFormData() {
//     final cateringOrder = ref.read(cateringOrderNotifierProvider);
    
//     preferencia = (cateringOrder?.preferencia?.isNotEmpty == true)
//         ? cateringOrder!.preferencia
//         : 'salado';
    
//     eventTypeController.text = cateringOrder?.eventType ?? '';
//     adicionales = cateringOrder?.adicionales ?? '';
//     cantidadPersonasRead = cateringOrder?.peopleCount;
//     hasChef = cateringOrder?.hasChef ?? false;
//     alergiasList = cateringOrder?.alergias.split(',').where((e) => e.isNotEmpty).toList() ?? [];
    
//     if (cantidadPersonasRead != null && !peopleQuantity.contains(cantidadPersonasRead)) {
//       isCustomSelected = true;
//       customPersonasController.text = cantidadPersonasRead.toString();
//     }
//   }

//   void _handleSubmit() {
//     widget.onSubmit(
//       hasChef,
//       alergiasList.join(','),
//       eventTypeController.text,
//       preferencia,
//       adicionales,
//       cantidadPersonasRead ?? 0,
//     );
//   }

//   @override
//   void dispose() {
//     customPersonasController.dispose();
//     eventTypeController.dispose();
//     customPersonasFocusNode.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       child: Padding(
//         padding: EdgeInsets.only(
//           bottom: MediaQuery.sizeOf(context).viewInsets.bottom,
//           left: 20.0,
//           right: 20.0,
//           top: 20.0,
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _buildHeader(context),
//             const Divider(),
//             const SizedBox(height: 16),
//             _buildPeopleQuantitySection(),
//             const SizedBox(height: 16),
//             _buildAllergiesSection(),
//             const SizedBox(height: 16),
//             _buildEventTypeSection(),
//             const SizedBox(height: 16),
//             _buildChefSection(),
//             const SizedBox(height: 24),
//             _buildAdditionalNotesSection(),
//             const SizedBox(height: 16),
//             _buildSubmitButton(),
//             const SizedBox(height: 24),
//           ],
//         ),
//       ),
//     );
//   }

//   // Add all the build methods for each section...
//   // I'll provide a few examples:

//   Widget _buildHeader(BuildContext context) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(
//           'Detalles de la orden',
//           style: Theme.of(context).textTheme.headlineSmall,
//         ),
//         IconButton(
//           icon: Icon(Icons.close, color: ColorsPaletteRedonda.deepBrown1),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ],
//     );
//   }

//   Widget _buildPeopleQuantitySection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text('Cantidad de Personas',
//             style: TextStyle(fontWeight: FontWeight.bold)),
//         const SizedBox(height: 8),
//         DropdownButtonFormField<int>(
//           value: !isCustomSelected ? cantidadPersonasRead : null,
//           dropdownColor: Colors.white,
//           decoration: InputDecoration(
//             labelText: isCustomSelected ? 'Cantidad Personalizada' : 'Cantidad de Personas',
//             border: const OutlineInputBorder(),
//             filled: true,
//             fillColor: ColorsPaletteRedonda.white,
//           ),
//           items: [
//             ...peopleQuantity.map((number) => DropdownMenuItem<int>(
//               value: number,
//               child: Text('$number'),
//             )),
//             const DropdownMenuItem<int>(
//               value: -1,
//               child: Text('Customizado'),
//             ),
//           ],
//           onChanged: _handlePeopleQuantityChange,
//         ),
//         if (isCustomSelected) ...[
//           const SizedBox(height: 16),
//           TextField(
//             controller: customPersonasController,
//             focusNode: customPersonasFocusNode,
//             decoration: InputDecoration(
//               labelText: '${cantidadPersonasRead ?? 0} Personas',
//               border: const OutlineInputBorder(),
//               filled: true,
//               fillColor: ColorsPaletteRedonda.white,
//             ),
//             keyboardType: TextInputType.number,
//             onChanged: (value) {
//               final customValue = int.tryParse(value);
//               if (customValue != null) {
//                 setState(() => cantidadPersonasRead = customValue);
//               }
//             },
//           ),
//         ],
//       ],
//     );
//   }

//   void _handlePeopleQuantityChange(int? value) {
//     setState(() {
//       if (value == -1) {
//         isCustomSelected = true;
//         cantidadPersonasRead = null;
//         Future.delayed(const Duration(milliseconds: 200), () {
//           customPersonasFocusNode.requestFocus();
//         });
//       } else {
//         isCustomSelected = false;
//         cantidadPersonasRead = value;
//       }
//     });
//   }
//   Widget _buildAllergiesSection() {
//       return Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text('Alergias', style: TextStyle(fontWeight: FontWeight.bold)),
//           const SizedBox(height: 8),
//           Wrap(
//             spacing: 8.0,
//             children: [
//               ...alergiasList.map((allergy) => Chip(
//                 backgroundColor: ColorsPaletteRedonda.primary,
//                 label: Text(
//                   allergy,
//                   style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                     color: Colors.white,
//                   ),
//                 ),
//                 deleteIconColor: Colors.white,
//                 onDeleted: () => setState(() => alergiasList.remove(allergy)),
//               )),
//               if (alergiasList.length < 10)
//                 ActionChip(
//                   backgroundColor: Colors.white,
//                   avatar: Icon(Icons.add, color: ColorsPaletteRedonda.primary),
//                   label: const Text('Agregar Alergia'),
//                   labelStyle: TextStyle(color: ColorsPaletteRedonda.primary),
//                   onPressed: _showAllergyDialog,
//                 ),
//             ],
//           ),
//         ],
//       );
//     }
  
//   Widget _buildEventTypeSection() {
//       return Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text('Tipo de Evento', style: TextStyle(fontWeight: FontWeight.bold)),
//           const SizedBox(height: 8),
//           TextField(
//             controller: eventTypeController,
//             decoration: InputDecoration(
//               labelText: 'Ej. Cumpleaños, Boda',
//               labelStyle: Theme.of(context).textTheme.bodySmall,
//               border: const OutlineInputBorder(),
//               filled: true,
//               fillColor: ColorsPaletteRedonda.white,
//             ),
//           ),
//         ],
//       );
//     }
  
//   Widget _buildChefSection() {
//       return Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             'Agregar cheffing',
//             style: Theme.of(context).textTheme.titleMedium,
//           ),
//           Switch(
//             value: hasChef,
//             inactiveTrackColor: ColorsPaletteRedonda.deepBrown,
//             activeColor: ColorsPaletteRedonda.primary,
//             onChanged: (value) => setState(() => hasChef = value),
//           ),
//         ],
//       );
//     }
  
//   Widget _buildAdditionalNotesSection() {
//       return ExpansionTile(
//         title: Text(
//           'Notas Adicionales',
//           style: Theme.of(context).textTheme.titleMedium?.copyWith(color:  ColorsPaletteRedonda.primary),
//         ),
//         children: [
//           TextFormField(
//             initialValue: adicionales,
//             style: Theme.of(context).textTheme.labelLarge,
//             maxLines: 3,
//             decoration: InputDecoration(
//               hintText: '',
//               filled: true,
//               fillColor: ColorsPaletteRedonda.white,
//               enabledBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(8.0),
//                 borderSide: const BorderSide(
//                   color: ColorsPaletteRedonda.deepBrown1,
//                   width: 1.0,
//                 ),
//               ),
//               focusedBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(8.0),
//                 borderSide: const BorderSide(
//                   color: ColorsPaletteRedonda.primary,
//                   width: 2.0,
//                 ),
//               ),
//             ),
//             onChanged: (value) => setState(() => adicionales = value),
//           ),
//         ],
//       );
//     }
  
//   Widget _buildSubmitButton() {
//       return Center(
//         child: SizedBox(
//           height: 42,
//           child: ElevatedButton(
//             style: ButtonStyle(
//               backgroundColor: WidgetStateProperty.all(ColorsPaletteRedonda.orange),
//               foregroundColor: WidgetStateProperty.all(Colors.white),
//               side: WidgetStateProperty.all(BorderSide.none),
//             ),
//             onPressed: _handleSubmit,
//             child: const Text('Confirmar Detalles'),
//           ),
//         ),
//       );
//     }
  
//   Future<void> _showAllergyDialog() async {
//       String? allergyInput;
//       final newAllergy = await showDialog<String>(
//         context: context,
//         builder: (context) => AlertDialog(
//           title: const Text('Nueva Alergia'),
//           content: TextField(
//             onChanged: (value) => allergyInput = value,
//             decoration: const InputDecoration(
//               hintText: 'Ingresa una alergia',
//               border: OutlineInputBorder(),
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text('Cancelar'),
//             ),
//             TextButton(
//               onPressed: () {
//                 if (allergyInput?.isNotEmpty == true) {
//                   Navigator.pop(context, allergyInput);
//                 }
//               },
//               child: const Text('Aceptar'),
//             ),
//           ],
//         ),
//       );
  
//       if (newAllergy?.isNotEmpty == true && !alergiasList.contains(newAllergy)) {
//         setState(() => alergiasList.add(newAllergy!));
//       }
//   }
// }