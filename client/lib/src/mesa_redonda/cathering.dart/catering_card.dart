import 'package:flutter/material.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/cathering.dart/catering_item.dart';

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
  int quantity = 1;

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
              widget.item.img,
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
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
                  widget.item.title,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(widget.item.description),
                const SizedBox(height: 8),
                Text(
                    '\$${widget.item.pricePerPerson.toStringAsFixed(2)} por persona'),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Row(
                    //   children: [
                    //     IconButton(
                    //       icon: const Icon(Icons.remove),
                    //       onPressed: () {
                    //         if (quantity > 1) {
                    //           setState(() {
                    //             quantity--;
                    //           });
                    //         }
                    //       },
                    //     ),
                    //     Text('$quantity'),
                    //     IconButton(
                    //       icon: const Icon(Icons.add),
                    //       onPressed: () {
                    //         setState(() {
                    //           quantity++;
                    //         });
                    //       },
                    //     ),
                    //   ],
                    // ),

                    ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Se agregó ${widget.item.title}  al carrito'),
                          ),
                        );
                        widget.onAddToCart(quantity);
                      },
                      child: const Text('Agregar al carrito'),
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
  static double calculateMaxTabWidth(
      BuildContext context, List<String> tabTitles) {
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
    return maxWidth + 8.0; // Add padding if necessary
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
    final double maxTabWidth = 120.0; // Example of a pre-calculated max width

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
