import 'package:flutter/material.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/util_mesa_redonda/categories.dart';

class Categories extends StatefulWidget {
  const Categories({super.key});

  @override
  CategoriesState createState() => CategoriesState();
}

class CategoriesState extends State<Categories> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categorias'),
        centerTitle: true,
        forceMaterialTransparency: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(
          5.0,
        ),
        child: GridView.count(
          crossAxisCount: 2,
          children: List.generate(
            categories.length,
            (index) {
              var cat = categories[index];
              return Container(
                padding: const EdgeInsets.all(8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Stack(
                    children: <Widget>[
                      Image.asset(
                        cat["img"],
                        height: MediaQuery.sizeOf(context).height,
                        width: MediaQuery.sizeOf(context).height,
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
                        height: MediaQuery.sizeOf(context).height,
                        width: MediaQuery.sizeOf(context).height,
                      ),
                      Center(
                        child: Container(
                          height: MediaQuery.sizeOf(context).height,
                          width: MediaQuery.sizeOf(context).height,
                          padding: const EdgeInsets.all(1),
                          // constraints: BoxConstraints(
                          //   minWidth: 20,
                          //   minHeight: 20,
                          // ),
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
            },
          ),
        ),
      ),
    );
  }
}
