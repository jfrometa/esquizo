// It contains all our demo data that we used
final List<String> demoRestaurantNames = [
  "Fried Chicken - Big Beach Famous Recipe",
  "Korean Chicken House - Tastier than Bonchon",
  "Uncle Phon & Aunt Tan's Fried Chicken",
  "This Fried Chicken Will Make You Rich and Beautiful",
  "Street Fried Chicken - Support the Auntie",
  "Explicit Content" // Inappropriate content that should be reviewed and changed.
  // Add more restaurant names here as needed
];

final Map<String, String> restaurantImages = {
  "Fried Chicken - Big Beach Famous Recipe": "assets/food2.jpeg",
  "Korean Chicken House - Tastier than Bonchon": "assets/food3.jpeg",
  "Uncle Phon & Aunt Tan's Fried Chicken": "assets/food4.jpeg",
  "This Fried Chicken Will Make You Rich and Beautiful": "assets/food5.jpeg",
  "Explicit Content":
      "assets/food6.jpeg", // Inappropriate content that should be reviewed and changed.
  // Add more restaurant names and images here as needed
};

List<String> demoBigImages = [
  "assets/food2.jpeg",
  "assets/food3.jpeg",
  "assets/food4.jpeg",
  "assets/food5.jpeg",
  "assets/food6.jpeg",
  "assets/food7.jpeg",
  "assets/food8.jpeg",
  "assets/food9.jpeg",
  "assets/food1.jpeg",
];

List<Map<String, dynamic>> demoMediumCardData = [
  {
    "name": "Korean Chicken House - Tastier than Bonchon",
    "image": "assets/food6.jpeg",
    "location": "Asoke, Bangkok",
    "rating": 8.6,
    "deliveryTime": 20,
  },
  {
    "name": "Fried Chicken - Big Beach Famous Recipe",
    "image": "assets/food1.jpeg",
    "location": "Nana, Bangkok",
    "rating": 9.1,
    "deliveryTime": 35,
  },
  {
    "name": "Uncle Phon & Aunt Tan's Fried Chicken",
    "image": "assets/food4.jpeg",
    "location": "Chidlom, Bangkok",
    "rating": 7.3,
    "deliveryTime": 25,
  },
  {
    "name": "This Fried Chicken Will Make You Rich and Beautiful",
    "image": "assets/food9.jpeg",
    "location": "Thonglor, Bangkok",
    "rating": 8.4,
    "deliveryTime": 30,
  },
  {
    "name": "Street Fried Chicken - Support the Auntie",
    "image": "assets/food2.jpeg",
    "location": "Srinakharinwirot University, Bangkok",
    "rating": 9.5,
    "deliveryTime": 15,
  }
];

final Map<String, List<Map<String, dynamic>>> restaurantMenu = {
  "Korean Chicken House - Tastier than Bonchon": [
    {
      "name": "Korean Style Fried Chicken",
      "location": "Asoke, Bangkok",
      "image": "assets/food5.jpeg",
      "foodType": "Fried Chicken",
      "price": 0,
      "priceRange": "\$ \$",
    },
    {
      "name": "Hainanese Chicken Rice",
      "location": "Asoke, Bangkok",
      "image": "assets/food2.jpeg",
      "foodType": "Hainanese Chicken Rice",
      "price": 0,
      "priceRange": "\$ \$",
    },
    // Add more food items for "Korean Chicken House - Tastier than Bonchon" here
  ],
  "Fried Chicken - Big Beach Famous Recipe": [
    {
      "name": "Hat Yai Fried Chicken",
      "location": "Nana, Bangkok",
      "image": "assets/food4.jpeg",
      "foodType": "Fried Chicken",
      "price": 0,
      "priceRange": "\$ \$",
    },
    {
      "name": "Hainanese Chicken Rice",
      "location": "Nana, Bangkok",
      "image": "assets/food3.jpeg",
      "foodType": "Hainanese Chicken Rice",
      "price": 0,
      "priceRange": "\$ \$",
    },
    // Add more food items for "Fried Chicken - Big Beach Famous Recipe" here
  ],
  // Add more restaurants and their menus here as needed
};

final cartItems = [
  {
    "img": 'assets/food1.jpeg',
    "title": 'La Bonita',
    "description": 'Sandwich de queso de hoja, tocino, y spicy honey.',
    "pricing": '400.00',
    "ingredients": ['Queso de hoja', 'Tocino', 'Spicy honey'],
    "isSpicy": true,
    "foodType": 'Meat',
    "quantity": 1,
    "price": 19.99,
    "isOffer": true,
  },
  {
    "img": 'assets/food2.jpeg',
    "title": 'Bosque Encantado',
    "description":
        'Sandwich de filete de res, crema de hongos, cebolla caramelizada, y queso provolone.',
    "pricing": '555.00',
    "ingredients": [
      'Filete de res',
      'Crema de hongos',
      'Cebolla caramelizada',
      'Queso provolone'
    ],
    "isSpicy": false,
    "foodType": 'Meat',
    "quantity": 1,
    "price": 19.99,
    "isOffer": true,
  },
];
