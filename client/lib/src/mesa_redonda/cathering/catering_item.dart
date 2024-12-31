import 'package:flutter_riverpod/flutter_riverpod.dart';

class CateringItem {
  final String category;
  final String title;
  final String description;
  final double pricePerUnit;
  double pricing;
  final String img;
  final List<String> ingredients;
  int peopleCount; // Number of people the catering is for
  int quantity; // Number of catering items
  final bool hasUnitSelection; // New field

  CateringItem({
    required this.category,
    required this.title,
    required this.description,
    required this.pricePerUnit,
    required this.pricing,
    required this.img,
    required this.ingredients,
    this.peopleCount = 10, // Default to 10 people
    this.quantity = 25, // Default quantity to 1
    this.hasUnitSelection = false, // Default to false
  });

  CateringItem copyWith(
      {int? peopleCount, int? quantity, double? pricePerUnit}) {
    return CateringItem(
      title: title,
      description: description,
      pricePerUnit: pricePerUnit ?? this.pricePerUnit,
      pricing: pricing,
      img: img,
      ingredients: ingredients,
      peopleCount: peopleCount ?? this.peopleCount,
      quantity: quantity ?? this.quantity,
      category: category,
      hasUnitSelection: hasUnitSelection,
    );
  }
}

final cateringProvider = Provider<List<CateringItem>>((ref) {
  return [
    // Matched Items
    CateringItem(
      category: 'Arroces',
      title: 'Arroz con Tocineta, Plátano Maduro y Puerro',
      description: 'Arroz con plátano maduro, tocineta y puerro .',
      pricePerUnit: 250.00,
      pricing: 0.0,
      img: 'assets/catering/arroz_maduro_tocineta.jpg',
      ingredients: ['Arroz', 'Plátano maduro', 'Tocineta', 'Puerro'],
      hasUnitSelection: false,
    ),
    CateringItem(
      category: 'Para Picar',
      title: 'Croquetas de Pollo',
      description: 'Caja de 25 croquetas de pollo.',
      pricePerUnit: 60.00,
      pricing: 0.0,
      img: 'assets/catering/croquetas_2.jpg',
      ingredients: ['Pollo', 'Harina', 'Pan rallado'],
      hasUnitSelection: true,
    ),
    CateringItem(
      category: 'Para Picar',
      title: 'Quipes',
      description: 'Caja de 25 quipes tradicionales.',
      pricePerUnit: 50.00,
      pricing: 0.0,
      img: 'assets/catering/kipes.jpg',
      ingredients: ['Carne', 'Trigo', 'Especias'],
      hasUnitSelection: true,
    ),
    CateringItem(
      category: 'Pastas',
      title: 'Lasagna de Res o Pollo',
      description: 'Lasagna clásica de res o pollo',
      pricePerUnit: 3500.00,
      pricing: 0.0,
      img: 'assets/catering/lasagna_blanca.jpg',
      ingredients: ['Pasta', 'Carne de res o pollo', 'Queso', 'Tomate'],
      hasUnitSelection: false,
    ),
    CateringItem(
      category: 'Guarniciones',
      title: 'Papines a las Hierbas',
      description: 'Papines asados con hierbas, por persona.',
      pricePerUnit: 175.00,
      pricing: 0.0,
      img: 'assets/catering/papas_salteadas.jpg',
      ingredients: ['Papines', 'Hierbas'],
      hasUnitSelection: false,
    ),
    CateringItem(
      category: 'Para Picar',
      title: 'Pastelitos de Pollo y Queso',
      description: 'Caja de 25 pastelitos de pollo y queso.',
      pricePerUnit: 40.00,
      pricing: 0.0,
      img: 'assets/catering/pastelitos.jpg',
      ingredients: ['Pollo', 'Queso', 'Masa de hojaldre'],
      hasUnitSelection: true,
    ),
    CateringItem(
      category: 'Proteínas',
      title: 'Pierna de Cerdo en su Mojo',
      description: 'Pierna de cerdo en su mojo (unidad).',
      pricePerUnit: 8500.00,
      pricing: 0.0,
      img: 'assets/catering/pierna.jpg',
      ingredients: ['Pierna de cerdo', 'Mojo criollo'],
      hasUnitSelection: false,
    ),
    CateringItem(
      category: 'Proteínas',
      title: 'Pechuga de Pollo Rellena de Manchego y Prosciutto',
      description: 'Pechuga de pollo rellena de queso manchego y prosciutto.',
      pricePerUnit: 575.00,
      pricing: 0.0,
      img: 'assets/catering/pollo_cordonblue.jpg',
      ingredients: ['Pechuga de pollo', 'Queso manchego', 'Prosciutto'],
      hasUnitSelection: false,
    ),

    // Unmatched Items (with default image)
    CateringItem(
      category: 'Salsas',
      title: 'Salsa Bolognese',
      description: 'Salsa Bolognese en presentación de 1/2 litro o 1 litro.',
      pricePerUnit: 750.00,
      pricing: 0,
      img: 'assets/food5.jpeg',
      ingredients: ['Carne de res', 'Tomate', 'Cebolla', 'Especias'],
    ),
    CateringItem(
      category: 'Salsas',
      title: 'Salsa Pomodoro',
      description: 'Salsa Pomodoro en presentación de 1/2 litro o 1 litro.',
      pricePerUnit: 650.00,
      pricing: 0,
      img: 'assets/food5.jpeg',
      ingredients: ['Tomate', 'Ajo', 'Albahaca'],
    ),
    CateringItem(
      category: 'Salsas',
      title: 'Salsa Bolognese',
      description: 'Salsa Bolognese en presentación de 1/2 litro o 1 litro.',
      pricePerUnit: 750.00,
      pricing: 0,
      img: 'assets/food5.jpeg',
      ingredients: ['Carne de res', 'Tomate', 'Cebolla', 'Especias'],
    ),
    CateringItem(
      category: 'Salsas',
      title: 'Salsa Pomodoro',
      description: 'Salsa Pomodoro en presentación de 1/2 litro o 1 litro.',
      pricePerUnit: 650.00,
      pricing: 0,
      img: 'assets/food5.jpeg',
      ingredients: ['Tomate', 'Ajo', 'Albahaca'],
    ),
    CateringItem(
      category: 'Salsas',
      title: 'Salsa 3 Quesos',
      description:
          'Salsa de tres quesos en presentación de 1/2 litro o 1 litro.',
      pricePerUnit: 850.00,
      pricing: 0,
      img: 'assets/food5.jpeg',
      ingredients: ['Queso parmesano', 'Queso ricotta', 'Queso mozzarella'],
    ),
    CateringItem(
      category: 'Salsas',
      title: 'Salsa Alfredo',
      description: 'Salsa Alfredo en presentación de 1/2 litro o 1 litro.',
      pricePerUnit: 650.00,
      pricing: 0,
      img: 'assets/food5.jpeg',
      ingredients: ['Crema', 'Queso parmesano', 'Ajo'],
    ),
    CateringItem(
      category: 'Salsas',
      title: 'Salsa Pesto',
      description: 'Salsa Pesto en presentación de 1/2 litro o 1 litro.',
      pricePerUnit: 800.00,
      pricing: 0.0,
      img: 'assets/food5.jpeg',
      ingredients: ['Albahaca', 'Ajo', 'Aceite de oliva', 'Queso parmesano'],
      hasUnitSelection: false,
    ),
    CateringItem(
      category: 'Arroces',
      title: 'Moro (negro, rojo, guandules)',
      description: 'Moro tradicional en diferentes presentaciones.',
      pricePerUnit: 220.00,
      pricing: 0.0,
      img: 'assets/food5.jpeg',
      ingredients: ['Arroz', 'Frijoles', 'Especias'],
      hasUnitSelection: false,
    ),
    CateringItem(
      category: 'Arroces',
      title: 'Arroz con Hongos Salvajes',
      description: 'Arroz con hongos salvajes.',
      pricePerUnit: 275.00,
      pricing: 0.0,
      img: 'assets/food5.jpeg',
      ingredients: ['Arroz', 'Hongos salvajes', 'Ajo', 'Cebolla'],
      hasUnitSelection: false,
    ),
    CateringItem(
      category: 'Proteínas',
      title: 'Filete de Res en Salsa de Hongos y Vino Tinto',
      description: 'Filete de res en salsa de hongos y vino tinto.',
      pricePerUnit: 675.00,
      pricing: 0.0,
      img: 'assets/food5.jpeg',
      ingredients: ['Filete de res', 'Hongos', 'Vino tinto'],
      hasUnitSelection: false,
    ),
    CateringItem(
      category: 'Proteínas',
      title: 'Filete de Cerdo en Salsa Mostaza',
      description: 'Filete de cerdo con salsa de mostaza.',
      pricePerUnit: 555.00,
      pricing: 0.0,
      img: 'assets/food5.jpeg',
      ingredients: ['Filete de cerdo', 'Mostaza', 'Especias'],
      hasUnitSelection: false,
    ),
    CateringItem(
      category: 'Proteínas',
      title: 'Filete de Cerdo Relleno de Dátiles y Cranberries',
      description: 'Filete de cerdo relleno de dátiles y cranberries.',
      pricePerUnit: 600.00,
      pricing: 0.0,
      img: 'assets/food5.jpeg',
      ingredients: ['Filete de cerdo', 'Dátiles', 'Cranberries'],
      hasUnitSelection: false,
    ),
    CateringItem(
      category: 'Proteínas',
      title: 'Pechuga de Pollo Rellena de Ricotta y Espinaca',
      description: 'Pechuga de pollo rellena de ricotta y espinaca.',
      pricePerUnit: 550.00,
      pricing: 0.0,
      img: 'assets/food5.jpeg',
      ingredients: ['Pechuga de pollo', 'Ricotta', 'Espinaca'],
      hasUnitSelection: false,
    ),
    CateringItem(
      category: 'Proteínas',
      title: 'Pechuga de Pavo a las Finas Hierbas',
      description: 'Pechuga de pavo a las finas hierbas.',
      pricePerUnit: 675.00,
      pricing: 0.0,
      img: 'assets/food5.jpeg',
      ingredients: ['Pechuga de pavo', 'Finas hierbas', 'Ajo', 'Cebolla'],
      hasUnitSelection: false,
    ),
    CateringItem(
      category: 'Guarniciones',
      title: 'Ensalada de Rúcula, Queso Feta y Almendras',
      description:
          'Ensalada de rúcula con queso feta y almendras, por persona.',
      pricePerUnit: 200.00,
      pricing: 0.0,
      img: 'assets/food5.jpeg',
      ingredients: ['Rúcula', 'Queso feta', 'Almendras'],
      hasUnitSelection: false,
    ),
    CateringItem(
      category: 'Guarniciones',
      title: 'Ensalada Rusa Tradicional',
      description: 'Ensalada rusa tradicional, por persona.',
      pricePerUnit: 250.00,
      pricing: 0.0,
      img: 'assets/food5.jpeg',
      ingredients: ['Papas', 'Zanahoria', 'Mayonesa'],
      hasUnitSelection: false,
    ),
    CateringItem(
      category: 'Guarniciones',
      title: 'Ensalada de Orzo',
      description: 'Ensalada de pasta orzo, por persona.',
      pricePerUnit: 225.00,
      pricing: 0.0,
      img: 'assets/food5.jpeg',
      ingredients: ['Orzo', 'Tomate', 'Pepino'],
      hasUnitSelection: false,
    ),
    CateringItem(
      category: 'Guarniciones',
      title: 'Mezclum de Lechugas, Nueces y Prosciutto',
      description:
          'Ensalada de mezclum de lechugas con nueces y prosciutto, por persona.',
      pricePerUnit: 275.00,
      pricing: 0.0,
      img: 'assets/food5.jpeg',
      ingredients: ['Lechuga', 'Nueces', 'Prosciutto'],
      hasUnitSelection: false,
    ),
    CateringItem(
      category: 'Para Picar',
      title: 'Canapés de Salmón Ahumado',
      description: 'Canapés individuales de salmón ahumado.',
      pricePerUnit: 55.00,
      pricing: 0.0,
      img: 'assets/food5.jpeg',
      ingredients: ['Salmón ahumado', 'Pan', 'Queso crema'],
      hasUnitSelection: true,
    ),
    CateringItem(
      category: 'Para Picar',
      title: 'Sandwichitos de Queso Crema y Tocineta',
      description: 'Sandwichitos de queso crema y tocineta.',
      pricePerUnit: 40.00,
      pricing: 0.0,
      img: 'assets/food5.jpeg',
      ingredients: ['Queso crema', 'Tocineta', 'Pan'],
      hasUnitSelection: true,
    )
  ];
});
