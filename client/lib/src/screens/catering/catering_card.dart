import 'package:flutter/material.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/catering_management/models/catering_item_model.dart';

class CateringItemCard extends StatefulWidget {
  final CateringItem item;
  final TextEditingController sideRequestController;
  final void Function(int quantity) onAddToCart;

  const CateringItemCard({
    required this.item,
    required this.onAddToCart,
    required this.sideRequestController,
    super.key,
  });

  @override
  CateringItemCardState createState() => CateringItemCardState();
}

class CateringItemCardState extends State<CateringItemCard> {
  int quantity = 25;
  bool isCustomUnitsSelected = false;
  final unitQuantity = [25, 50, 75, 100, 150, 200, 300, 400, 500, 1000];
  int? selectedUnits;
  final TextEditingController customUnitsController = TextEditingController();
  final FocusNode customUnitsFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    selectedUnits = widget.item.quantity;
    customUnitsController.text = selectedUnits.toString();
    isCustomUnitsSelected = !unitQuantity.contains(selectedUnits);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8.0), topRight: Radius.circular(8.0)),
            child: Image.asset(
              widget.item.imageUrl,
              height: 150,
              width: double.infinity,
              fit: BoxFit.fitWidth,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 150,
                  width: double.infinity,
                  color: Colors.grey[200],
                  child: const Icon(Icons.broken_image, size: 50),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                Text(
                  widget.item.name,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(widget.item.description),
                const SizedBox(height: 8),
                // if(widget.item.pricePerPerson < 1) Text( '\$${widget.item.pricePerPerson.toStringAsFixed(2)} por persona'),
                const SizedBox(height: 8),
                if (widget.item.hasUnitSelection) ...[
                  const SizedBox(height: 16),
                  const Text('Cantidad de Unidades',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    initialValue: isCustomUnitsSelected ? null : selectedUnits,
                    dropdownColor: Colors.white,
                    decoration: InputDecoration(
                      labelText: isCustomUnitsSelected
                          ? 'Cantidad Personalizada'
                          : 'Cantidad de Unidades',
                      border: const OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    items: [
                      for (var number in unitQuantity)
                        DropdownMenuItem<int>(
                          value: number,
                          child: Text('$number'),
                        ),
                      const DropdownMenuItem<int>(
                        value: -1,
                        child: Text('Personalizado'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        if (value == -1) {
                          isCustomUnitsSelected = true;
                          selectedUnits = null;
                          Future.delayed(const Duration(milliseconds: 200), () {
                            customUnitsFocusNode.requestFocus();
                          });
                        } else {
                          isCustomUnitsSelected = false;
                          selectedUnits = value;
                        }
                        // Save the selected units back to the CateringItem model
                        // widget.item.quantity = selectedUnits ?? 25;
                      });
                    },
                  ),
                  if (isCustomUnitsSelected) ...[
                    const SizedBox(height: 16),
                    TextField(
                      controller: customUnitsController,
                      focusNode: customUnitsFocusNode,
                      decoration: InputDecoration(
                        labelText: '${selectedUnits ?? 'Selecciona'} nidades',
                        border: const OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        final customValue = int.tryParse(value);
                        if (customValue != null && customValue >= 25) {
                          setState(() => selectedUnits = customValue);
                        }
                      },
                    ),
                  ],
                ],

                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Add price display
                    Text(
                      widget.item.hasUnitSelection
                          ? '${widget.item.hasUnitSelection ? 'Unidad' : ''}: \$${widget.item.pricePerUnit}'
                          : '',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(
                      height: 32,
                      child: ElevatedButton(
                        onPressed: () {
                          final units = widget.item.hasUnitSelection
                              ? (isCustomUnitsSelected
                                  ? int.tryParse(customUnitsController.text) ??
                                      25
                                  : selectedUnits ?? 25)
                              : widget.item
                                  .peopleCount; // For non-unit items, quantity is always 1

                          if (widget.item.hasUnitSelection && units < 25) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('La cantidad mínima es 25 unidades'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          // For unit items: price * units
                          // For non-unit items: price * 1 (peopleCount will be applied later)
                          // final basePrice = widget.item.pricePerUnit * units;

                          // Save the selected units and base price to the CateringItem model
                          // widget.item.quantity = units;
                          // widget.item.price = basePrice;

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Se agregó ${widget.item.name} al carrito${widget.item.hasUnitSelection ? ' ($units unidades)' : ''}',
                                style: TextStyle(color: Colors.white),
                              ),
                              backgroundColor: Colors.black,
                              duration: const Duration(milliseconds: 500),
                            ),
                          );
                          widget.onAddToCart(units);
                        },
                        child: const Text('Agregar al carrito'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TabUtils {
  // A static method to calculate the maximum tab width
  static double calculateMaxTabWidth({
    required BuildContext context,
    required List<String> tabTitles,
    double extraWidth = 0.0,
  }) {
    double maxWidth = 0.0;
    for (var title in tabTitles) {
      final TextPainter textPainter = TextPainter(
        text: TextSpan(
            text: title, style: Theme.of(context).textTheme.bodyMedium),
        maxLines: 1,
        textDirection: TextDirection.ltr,
      )..layout();

      maxWidth = maxWidth < textPainter.width ? textPainter.width : maxWidth;
    }
    return maxWidth + 8.0 + extraWidth; // Add padding if necessary
  }
}

class TabIndicator extends Decoration {
  final BoxPainter _painter;

  TabIndicator({required Color color, required double radius})
      : _painter = _TabIndicatorPainter(color, radius);

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) => _painter;
}

class _TabIndicatorPainter extends BoxPainter {
  final Paint _paint;
  final double radius;

  _TabIndicatorPainter(Color color, this.radius)
      : _paint = Paint()
          ..color = color
          ..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration cfg) {
    final Rect rect = _indicatorRectFor(cfg, offset);
    final RRect rRect = RRect.fromRectAndRadius(rect, Radius.circular(radius));
    canvas.drawRRect(rRect, _paint);
  }

  Rect _indicatorRectFor(ImageConfiguration cfg, Offset offset) {
    final double height = cfg.size?.height ?? 0.0;

    // Calculate maximum tab width based on the largest tab
    final double maxTabWidth = 140.0; // Example of a pre-calculated max width

    // Define the desired height of the indicator
    const double indicatorHeight = 38.0; // Adjust as needed
    // Define horizontal padding
    // const double horizontalPadding = 16.0; // Adjust as needed

    // Calculate top position to center the indicator vertically
    final double top = offset.dy + (height - indicatorHeight) / 2;

    // Create the rectangle for the indicator with fixed width (maxTabWidth)
    return Rect.fromLTWH(
      offset.dx + (cfg.size!.width - maxTabWidth) / 2, // Center the indicator
      top,
      maxTabWidth,
      indicatorHeight,
    );
  }
}
