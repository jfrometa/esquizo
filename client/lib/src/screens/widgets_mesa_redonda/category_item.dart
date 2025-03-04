import 'package:flutter/material.dart';

class CategoryItem extends StatelessWidget {
  final Map cat;

  const CategoryItem({super.key, required this.cat});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Stack(
          children: <Widget>[
            Image.asset(
              cat["img"],
              height: 120,
              width: 120,
              fit: BoxFit.cover,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  // Add one stop for each color. Stops should increase from 0 to 1
                  stops: const [0.2, 0.7],
                  colors: [
                    cat['color1'],
                    cat['color2'],
                  ],
                  // stops: [0.0, 0.1],
                ),
              ),
              height: 120,
              width: 120,
            ),
            Center(
              child: Container(
                height: 120,
                width: 120,
                padding: const EdgeInsets.all(1),
                constraints: const BoxConstraints(
                  minWidth: 60,
                  minHeight:60,
                ),
                child: Center(
                  child: Text(
                    cat["name"],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
