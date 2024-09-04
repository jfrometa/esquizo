import 'package:flutter/material.dart';

class SlideOrderItem extends StatefulWidget {
  final String img;
  final String title;
  final String address;
  final String rating;
  final double price;
  final bool isOffer;
  final int quantity;

  const SlideOrderItem({
    required Key key,
    required this.img,
    required this.title,
    required this.address,
    required this.rating,
    required this.price,
    required this.isOffer,
    required this.quantity,
  }) : super(key: key);

  @override
  SlideItemState createState() => SlideItemState();
}

class SlideItemState extends State<SlideOrderItem> {
  late int _quantity;

  @override
  void initState() {
    super.initState();
    _quantity = widget.quantity;
  }

  void _incrementQuantity() {
    setState(() {
      _quantity++;
    });
  }

  void _decrementQuantity() {
    setState(() {
      if (_quantity > 1) {
        _quantity--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final height = constraints.maxHeight;
          final width = constraints.maxWidth;

          return SizedBox(
            height: height / 2.9,
            width: width / 1.2,
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
              elevation: 3.0,
              child: Column(
                children: <Widget>[
                  Stack(
                    children: <Widget>[
                      SizedBox(
                        height: height / 3.7,
                        width: width,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(10.0),
                            topRight: Radius.circular(10.0),
                          ),
                          child: Image.asset(
                            widget.img,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      if (widget.isOffer)
                        Positioned(
                          top: 6.0,
                          left: 6.0,
                          child: Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(3.0)),
                            child: const Padding(
                              padding: EdgeInsets.all(4.0),
                              child: Text(
                                "OFFER",
                                style: TextStyle(
                                  fontSize: 10.0,
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 7.0),
                  Padding(
                    padding: const EdgeInsets.only(left: 15.0),
                    child: SizedBox(
                      width: width,
                      child: Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.w800,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ),
                  const SizedBox(height: 7.0),
                  Padding(
                    padding: const EdgeInsets.only(left: 15.0),
                    child: SizedBox(
                      width: width,
                      child: Text(
                        widget.address,
                        style: const TextStyle(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 7.0),
                  Padding(
                    padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "\$${widget.price.toStringAsFixed(2)}",
                          style: const TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: _decrementQuantity,
                            ),
                            Text(
                              '$_quantity',
                              style: const TextStyle(fontSize: 16.0),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: _incrementQuantity,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10.0),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
