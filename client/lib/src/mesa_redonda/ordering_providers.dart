import 'package:flutter_riverpod/flutter_riverpod.dart';

// Dish List (immutable)
final dishProvider = Provider<List<Map<String, dynamic>>>((ref) {
  return [
    {
      "img": "assets/dishes/flap_meat_arroz_box.jpg",
      "title": "Flap Meat Bowl",
      "description":
          "Tiras de flap meat a la plancha, sobre arroz estilo asiático con vegetales y aguacate.",
      "pricing": "700.00",
      "ingredients": [
        "Flap meat",
        "Arroz asiático con vegetales",
        "Aguacate",
        "Cebollín",
        "Semillas de sésamo"
      ],
      "isSpicy": false,
      "foodType": "Meat"
    },
    {
      "img": "assets/dishes/mechada_maduro_arroz_box.jpg",
      "title": "Ropa Vieja Clásica con Plátanos",
      "description":
          "Carne mechada guisada con pimientos y cebolla, acompañada de arroz blanco y plátanos maduros.",
      "pricing": "600.00",
      "ingredients": [
        "Carne mechada",
        "Pimientos",
        "Cebolla",
        "Plátanos maduros",
        "Arroz blanco"
      ],
      "isSpicy": false,
      "foodType": "Meat"
    },
    {
      "img": "assets/dishes/mechada_nuez_box.jpg",
      "title": "Ropa Vieja con Toque Asiático",
      "description":
          "Carne mechada con un toque de nuez, sobre arroz con vegetales, repollo morado y aguacate.",
      "pricing": "650.00",
      "ingredients": [
        "Carne mechada",
        "Repollo morado",
        "Aguacate",
        "Nueces",
        "Cebollín",
        "Arroz con vegetales"
      ],
      "isSpicy": false,
      "foodType": "Meat"
    },
    {
      "img": "assets/dishes/molida_hongos_maduro_box.jpg",
      "title": "Bowl con Carne Molida y Champiñones",
      "description":
          "Carne molida, champiñones salteados, trozos de plátano, arroz mixto y aguacate.",
      "pricing": "650.00",
      "ingredients": [
        "Carne molida",
        "Champiñones",
        "Plátano",
        "Arroz",
        "Aguacate",
        "Cilantro"
      ],
      "isSpicy": false,
      "foodType": "Meat"
    },
    {
      "img": "assets/dishes/molida_tacos.jpg",
      "title": "Tacos de Carne Molida",
      "description":
          "Carne molida sazonada, servida en tortillas suaves con vegetales frescos y salsa.",
      "pricing": "580.00",
      "ingredients": [
        "Carne molida",
        "Tortillas",
        "Lechuga",
        "Tomate",
        "Salsa"
      ],
      "isSpicy": false,
      "foodType": "Meat"
    },
    {
      "img": "assets/dishes/oglio_hongos_pasta_box.jpg",
      "title": "Pasta Aglio e Olio con Hongos",
      "description":
          "Pasta salteada con ajo, aceite de oliva, hongos y un toque de chile flakes.",
      "pricing": "620.00",
      "ingredients": [
        "Pasta",
        "Ajo",
        "Aceite de oliva",
        "Hongos",
        "Chile flakes"
      ],
      "isSpicy": false,
      "foodType": "Vegetarian"
    },
    {
      "img": "assets/dishes/pollo_arroz_ensalada_box.jpg",
      "title": "Bowl de Pollo Desmenuzado",
      "description":
          "Pollo desmenuzado, arroz blanco, lechuga, tomate, aguacate y aderezos ligeros.",
      "pricing": "600.00",
      "ingredients": [
        "Pollo desmenuzado",
        "Arroz blanco",
        "Lechuga",
        "Tomate",
        "Aguacate"
      ],
      "isSpicy": false,
      "foodType": "Meat"
    },
    {
      "img": "assets/dishes/pollo_camaron_arroz_box.jpg",
      "title": "Ensalada Mixta con Pollo y Camarones",
      "description":
          "Trozos de pechuga de pollo, camarones a la plancha, lechuga, tocineta, queso y aderezo.",
      "pricing": "750.00",
      "ingredients": [
        "Pollo a la plancha",
        "Camarones",
        "Lechuga",
        "Tocineta",
        "Queso rallado",
        "Aderezo"
      ],
      "isSpicy": false,
      "foodType": "Mixed"
    },
    {
      "img": "assets/dishes/pollo_papas_ensalada_box.jpg",
      "title": "Pollo Desmenuzado con Papas Rostizadas",
      "description":
          "Pollo desmenuzado, pimientos, papas rostizadas, lechuga y tomate en un bowl nutritivo.",
      "pricing": "650.00",
      "ingredients": [
        "Pollo desmenuzado",
        "Pimientos",
        "Papas rostizadas",
        "Lechuga",
        "Tomate"
      ],
      "isSpicy": false,
      "foodType": "Meat"
    }

    // {
    //   "img": 'assets/food1.jpeg',
    //   "title": 'La Bonita',
    //   "description": 'Sandwich de queso de hoja, tocino, y spicy honey.',
    //   "pricing": '400.00',
    //   "ingredients": ['Queso de hoja', 'Tocino', 'Spicy honey'],
    //   "isSpicy": true,
    //   "foodType": 'Meat',
    // },
    // {
    //   "img": 'assets/food2.jpeg',
    //   "title": 'Bosque Encantado',
    //   "description":
    //       'Sandwich de filete de res, crema de hongos, cebolla caramelizada, y queso provolone.',
    //   "pricing": '555.00',
    //   "ingredients": [
    //     'Filete de res',
    //     'Crema de hongos',
    //     'Cebolla caramelizada',
    //     'Queso provolone'
    //   ],
    //   "isSpicy": false,
    //   "foodType": 'Meat',
    // },
    // {
    //   "img": 'assets/food3.jpeg',
    //   "title": 'El Granjero',
    //   "description": 'Sandwich de pulled pork y coleslaw.',
    //   "pricing": '475.00',
    //   "ingredients": ['Pulled pork', 'Coleslaw'],
    //   "isSpicy": false,
    //   "foodType": 'Meat',
    // },
    // {
    //   "img": 'assets/food4.jpeg',
    //   "title": 'El Americano',
    //   "description":
    //       'Sandwich de pechuga empanizada, spicy honey, y queso americano.',
    //   "pricing": '500.00',
    //   "ingredients": ['Pechuga empanizada', 'Spicy honey', 'Queso americano'],
    //   "isSpicy": true,
    //   "foodType": 'Meat',
    // },
    // {
    //   "img": 'assets/food5.jpeg',
    //   "title": 'Kapow',
    //   "description": 'Sandwich de pechuga desmenuzada, crema de hongos y tocino.',
    //   "pricing": '555.00',
    //   "ingredients": ['Pechuga desmenuzada', 'Crema de hongos', 'Tocino'],
    //   "isSpicy": false,
    //   "foodType": 'Meat',
    // },

    // {
    //   "img": 'assets/food6.jpeg',
    //   "title": 'Verde',
    //   "description": 'Arroz al pesto con pechuga a la plancha.',
    //   "pricing": '575.00',
    //   "ingredients": ['Arroz al pesto', 'Pechuga a la plancha'],
    //   "isSpicy": false,
    //   "foodType": 'Meat',
    // },
    // {
    //   "img": 'assets/food7.jpeg',
    //   "title": 'Asiatica',
    //   "description": 'Arroz asiatico y flap meat.',
    //   "pricing": '600.00',
    //   "ingredients": ['Arroz asiatico', 'Flap meat'],
    //   "isSpicy": false,
    //   "foodType": 'Meat',
    // },
    // {
    //   "img": 'assets/food1.jpeg',
    //   "title": 'Clasica',
    //   "description": 'Pechuga desmenuzada, arroz blanco, ensalada y aguacate.',
    //   "pricing": '500.00',
    //   "ingredients": [
    //     'Pechuga desmenuzada',
    //     'Arroz blanco',
    //     'Ensalada',
    //     'Aguacate'
    //   ],
    //   "isSpicy": false,
    //   "foodType": 'Meat',
    // },
    // {
    //   "img": 'assets/food2.jpeg',
    //   "title": 'Mar y Tierra',
    //   "description": 'Ensalada, pechuga, y camarones.',
    //   "pricing": '600.00',
    //   "ingredients": ['Ensalada', 'Pechuga', 'Camarones'],
    //   "isSpicy": false,
    //   "foodType": 'Meat',
    // },
    // {
    //   "img": 'assets/food3.jpeg',
    //   "title": 'Quisqueya',
    //   "description":
    //       'Res mechada al estilo dominicano, plátano maduro, arroz blanco y ensalada.',
    //   "pricing": '575.00',
    //   "ingredients": [
    //     'Res mechada',
    //     'Plátano maduro',
    //     'Arroz blanco',
    //     'Ensalada'
    //   ],
    //   "isSpicy": false,
    //   "foodType": 'Meat',
    // },
    // {
    //   "img": 'assets/food4.jpeg',
    //   "title": 'Ensalada Camille',
    //   "description":
    //       'Mix de lechugas, flap meat, sweet potato, y queso parmesano.',
    //   "pricing": '600.00',
    //   "ingredients": [
    //     'Lechugas',
    //     'Flap meat',
    //     'Sweet potato',
    //     'Queso parmesano'
    //   ],
    //   "isSpicy": false,
    //   "foodType": 'Meat',
    // },
  ];
});

// Meal Plan Options
enum MealPlan { twelveLunch, tenLunch, eightLunch }
