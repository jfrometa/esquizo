import 'package:flutter_riverpod/flutter_riverpod.dart';

class CateringItem {
  final String category;
  final String title;
  final String description;
  final double pricePerPerson;
  final String pricing;
  final String img;
  final List<String> ingredients;
  int peopleCount; // Number of people the catering is for
  int quantity; // Number of catering items

  CateringItem({
    required this.category,
    required this.title,
    required this.description,
    required this.pricePerPerson,
    required this.pricing,
    required this.img,
    required this.ingredients,
    this.peopleCount = 10, // Default to 10 people
    this.quantity = 1, // Default quantity to 1
  });

  CateringItem copyWith({
    int? peopleCount,
    int? quantity,
  }) {
    return CateringItem(
      title: title,
      description: description,
      pricePerPerson: pricePerPerson,
      pricing: pricing,
      img: img,
      ingredients: ingredients,
      peopleCount: peopleCount ?? this.peopleCount,
      quantity: quantity ?? this.quantity,
      category: category,
    );
  }
}

final cateringProvider = Provider<List<CateringItem>>((ref) {
  return [
    // Pastas
    // CateringItem(
    //   category: 'Pastas',
    //   title: 'Salsa Bolognese',
    //   description: 'Salsa Bolognese en presentación de 1/2 litro o 1 litro.',
    //   pricePerPerson: 750.00,
    //   img: 'assets/food5.jpeg',
    //   ingredients: ['Carne de res', 'Tomate', 'Cebolla', 'Especias'],
    // // ),
    // CateringItem(
    //   category: 'Pastas',
    //   title: 'Salsa Pomodoro',
    //   description: 'Salsa Pomodoro en presentación de 1/2 litro o 1 litro.',
    //   pricePerPerson: 650.00,
    //   img: 'assets/food5.jpeg',
    //   ingredients: ['Tomate', 'Ajo', 'Albahaca'],
    // ),
    // CateringItem(
    //   category: 'Pastas',
    //   title: 'Salsa 3 Quesos',
    //   description:
    //       'Salsa de tres quesos en presentación de 1/2 litro o 1 litro.',
    //   pricePerPerson: 850.00,
    //   img: 'assets/food5.jpeg',
    //   ingredients: ['Queso parmesano', 'Queso ricotta', 'Queso mozzarella'],
    // ),
    // CateringItem(
    //   category: 'Pastas',
    //   title: 'Salsa Alfredo',
    //   description: 'Salsa Alfredo en presentación de 1/2 litro o 1 litro.',
    //   pricePerPerson: 650.00,
    //   img: 'assets/food5.jpeg',
    //   ingredients: ['Crema', 'Queso parmesano', 'Ajo'],
    // ),
    CateringItem(
      category: 'Pastas',
      title: 'Salsa Pesto',
      description: 'Salsa Pesto en presentación de 1/2 litro o 1 litro.',
      pricePerPerson: 800.00,
      pricing: '800.00',
      img: 'assets/food5.jpeg',
      ingredients: ['Albahaca', 'Ajo', 'Aceite de oliva', 'Queso parmesano'],
    ),

    // Lasagna
    CateringItem(
      category: 'Pastas',
      title: 'Lasagna de Res o Pollo',
      description: 'Lasagna clásica de res o pollo para 6/8 personas.',
      pricePerPerson: 3500.00,
      pricing: '3500.00',
      img: 'assets/food5.jpeg',
      ingredients: ['Pasta', 'Carne de res o pollo', 'Queso', 'Tomate'],
    ),
    CateringItem(
      category: 'Pastas',
      title: 'Lasagna 4 Quesos Trufada',
      description: 'Lasagna de cuatro quesos con trufa, para 6/8 personas.',
      pricePerPerson: 3800.00,
      pricing: '3800.00',
      img: 'assets/food5.jpeg',
      ingredients: ['Queso trufado', 'Queso mozzarella', 'Trufa', 'Pasta'],
    ),
    CateringItem(
      category: 'Pastas',
      title: 'Lasagna Ropa Vieja',
      description: 'Lasagna con carne de res mechada, para 6/8 personas.',
      pricePerPerson: 3500.00,
      pricing: '3500.00',
      img: 'assets/food5.jpeg',
      ingredients: ['Carne de res', 'Pasta', 'Queso'],
    ),

    // Arroces
    CateringItem(
      category: 'Arroces',
      title: 'Arroz Salvaje con Hongos y Tocineta',
      description:
          'Arroz salvaje con hongos, tocineta, nueces y cranberries para 8/10 personas.',
      pricePerPerson: 280.00,
      pricing: '280.00',
      img: 'assets/food5.jpeg',
      ingredients: [
        'Arroz salvaje',
        'Hongos',
        'Tocineta',
        'Nueces',
        'Cranberries'
      ],
    ),
    CateringItem(
      category: 'Arroces',
      title: 'Moro (negro, rojo, guandules)',
      description:
          'Moro tradicional en diferentes presentaciones, para 8/10 personas.',
      pricePerPerson: 220.00,
      pricing: '220.00',
      img: 'assets/food5.jpeg',
      ingredients: ['Arroz', 'Frijoles', 'Especias'],
    ),
    CateringItem(
      category: 'Arroces',
      title: 'Arroz con Tocineta, Plátano Maduro y Puerro',
      description:
          'Arroz con plátano maduro, tocineta y puerro para 8/10 personas.',
      pricePerPerson: 250.00,
      pricing: '250.00',
      img: 'assets/food5.jpeg',
      ingredients: ['Arroz', 'Plátano maduro', 'Tocineta', 'Puerro'],
    ),
    CateringItem(
      category: 'Arroces',
      title: 'Arroz con Hongos Salvajes',
      description: 'Arroz con hongos salvajes para 8/10 personas.',
      pricePerPerson: 275.00,
      pricing: '275.00',
      img: 'assets/food5.jpeg',
      ingredients: ['Arroz', 'Hongos salvajes', 'Ajo', 'Cebolla'],
    ),

    // Proteínas
    CateringItem(
      category: 'Proteínas',
      title: 'Filete de Res en Salsa de Hongos y Vino Tinto',
      description:
          'Filete de res en salsa de hongos y vino tinto para 8/10 personas.',
      pricePerPerson: 675.00,
      pricing: '675.00',
      img: 'assets/food5.jpeg',
      ingredients: ['Filete de res', 'Hongos', 'Vino tinto'],
    ),
    CateringItem(
      category: 'Proteínas',
      title: 'Filete de Cerdo en Salsa Mostaza',
      description: 'Filete de cerdo con salsa de mostaza para 8/10 personas.',
      pricePerPerson: 555.00,
      pricing: '555.00',
      img: 'assets/food5.jpeg',
      ingredients: ['Filete de cerdo', 'Mostaza', 'Especias'],
    ),
    CateringItem(
      category: 'Proteínas',
      title: 'Filete de Cerdo Relleno de Dátiles y Cranberries',
      description:
          'Filete de cerdo relleno de dátiles y cranberries para 8/10 personas.',
      pricePerPerson: 600.00,
      pricing: '600.00',
      img: 'assets/food5.jpeg',
      ingredients: ['Filete de cerdo', 'Dátiles', 'Cranberries'],
    ),
    CateringItem(
      category: 'Proteínas',
      title: 'Pechuga de Pollo Rellena de Ricotta y Espinaca',
      description:
          'Pechuga de pollo rellena de ricotta y espinaca para 8/10 personas.',
      pricePerPerson: 550.00,
      pricing: '550.00',
      img: 'assets/food5.jpeg',
      ingredients: ['Pechuga de pollo', 'Ricotta', 'Espinaca'],
    ),
    CateringItem(
      category: 'Proteínas',
      title: 'Pechuga de Pollo Rellena de Manchego y Prosciutto',
      description:
          'Pechuga de pollo rellena de queso manchego y prosciutto para 8/10 personas.',
      pricePerPerson: 575.00,
      pricing: '575.00',
      img: 'assets/food5.jpeg',
      ingredients: ['Pechuga de pollo', 'Queso manchego', 'Prosciutto'],
    ),
    CateringItem(
      category: 'Proteínas',
      title: 'Pierna de Cerdo Rellena de Moro Negro',
      description: 'Pierna de cerdo rellena de moro negro (unidad).',
      pricePerPerson: 10500.00,
      pricing: '10500.00',
      img: 'assets/food5.jpeg',
      ingredients: ['Pierna de cerdo', 'Arroz moro negro'],
    ),
    CateringItem(
      category: 'Proteínas',
      title: 'Pierna de Cerdo en su Mojo',
      description: 'Pierna de cerdo en su mojo (unidad).',
      pricePerPerson: 8500.00,
      pricing: '8500.00',
      img: 'assets/food5.jpeg',
      ingredients: ['Pierna de cerdo', 'Mojo criollo'],
    ),
    CateringItem(
      category: 'Proteínas',
      title: 'Pechuga de Pavo a las Finas Hierbas',
      description: 'Pechuga de pavo a las finas hierbas para 8/10 personas.',
      pricePerPerson: 675.00,
      pricing: '675.00',
      img: 'assets/food5.jpeg',
      ingredients: ['Pechuga de pavo', 'Finas hierbas', 'Ajo', 'Cebolla'],
    ),

    // Guarniciones
    CateringItem(
      category: 'Guarniciones',
      title: 'Pastelón de Plátano Maduro',
      description: 'Pastelón de plátano maduro como guarnición, por persona.',
      pricePerPerson: 250.00,
      pricing: '250.00',
      img: 'assets/food5.jpeg',
      ingredients: ['Plátano maduro', 'Carne', 'Queso'],
    ),
    CateringItem(
      category: 'Guarniciones',
      title: 'Papines a las Hierbas',
      description: 'Papines asados con hierbas, por persona.',
      pricePerPerson: 175.00,
      pricing: '175.00',
      img: 'assets/food5.jpeg',
      ingredients: ['Papines', 'Hierbas'],
    ),
    CateringItem(
      category: 'Guarniciones',
      title: 'Ensalada de Rúcula, Queso Feta y Almendras',
      description:
          'Ensalada de rúcula con queso feta y almendras, por persona.',
      pricePerPerson: 200.00,
      pricing: '200.00',
      img: 'assets/food5.jpeg',
      ingredients: ['Rúcula', 'Queso feta', 'Almendras'],
    ),
    CateringItem(
      category: 'Guarniciones',
      title: 'Ensalada Rusa Tradicional',
      description: 'Ensalada rusa tradicional, por persona.',
      pricePerPerson: 250.00,
      pricing: '250.00',
      img: 'assets/food5.jpeg',
      ingredients: ['Papas', 'Zanahoria', 'Mayonesa'],
    ),
    CateringItem(
      category: 'Guarniciones',
      title: 'Ensalada de Orzo',
      description: 'Ensalada de pasta orzo, por persona.',
      pricePerPerson: 225.00,
      pricing: '225.00',
      img: 'assets/food5.jpeg',
      ingredients: ['Orzo', 'Tomate', 'Pepino'],
    ),
    CateringItem(
      category: 'Guarniciones',
      title: 'Mezclum de Lechugas, Nueces y Prosciutto',
      description:
          'Ensalada de mezclum de lechugas con nueces y prosciutto, por persona.',
      pricePerPerson: 275.00,
      pricing: '275.00',
      img: 'assets/food5.jpeg',
      ingredients: ['Lechuga', 'Nueces', 'Prosciutto'],
    ),

    // Para Picar
    CateringItem(
      category: 'Para Picar',
      title: 'Pastelitos de Pollo y Queso',
      description: 'Caja de 25 pastelitos de pollo y queso.',
      pricePerPerson: 1000.00,
      pricing: '1000.00',
      img: 'assets/food5.jpeg',
      ingredients: ['Pollo', 'Queso', 'Masa de hojaldre'],
    ),
    CateringItem(
      category: 'Para Picar',
      title: 'Croquetas de Pollo',
      description: 'Caja de 25 croquetas de pollo.',
      pricePerPerson: 1000.00,
      pricing: '1000.00',
      img: 'assets/food5.jpeg',
      ingredients: ['Pollo', 'Harina', 'Pan rallado'],
    ),
    CateringItem(
      category: 'Para Picar',
      title: 'Quipes',
      description: 'Caja de 25 quipes tradicionales.',
      pricePerPerson: 1000.00,
      pricing: '1000.00',
      img: 'assets/food5.jpeg',
      ingredients: ['Carne', 'Trigo', 'Especias'],
    ),
    CateringItem(
      category: 'Para Picar',
      title: 'Canapés de Salmón Ahumado',
      description: 'Canapés individuales de salmón ahumado.',
      pricePerPerson: 55.00,
      pricing: '55.00',
      img: 'assets/food5.jpeg',
      ingredients: ['Salmón ahumado', 'Pan', 'Queso crema'],
    ),
    CateringItem(
      category: 'Para Picar',
      title: 'Sandwichitos de Queso Crema y Tocineta',
      description: 'Sandwichitos de queso crema y tocineta.',
      pricePerPerson: 40.00,
      pricing: '40.00',
      img: 'assets/food5.jpeg',
      ingredients: ['Queso crema', 'Tocineta', 'Pan'],
    ),
  ];
});
