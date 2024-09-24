import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/components/cards/iteam_card.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/constants.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/demoData.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/app_router.dart';

class DetailsScreen extends StatelessWidget {
  const DetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // final detailItemId = context.extra as String;
    return Scaffold(
      appBar: AppBar(
        actions: const [],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: restaurantMenu.keys.map((restaurantName) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Decorated restaurant name
                  Container(
                    margin: const EdgeInsets.symmetric(
                      vertical: defaultPadding,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: defaultPadding,
                      vertical: defaultPadding / 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.restaurant,
                          color: Colors.pink[200],
                        ),
                        const SizedBox(width: 18.0),
                        Expanded(
                          child: Text(
                            restaurantName,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20.0,
                                ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.arrow_forward,
                            color: Theme.of(context).primaryColor,
                          ),
                          onPressed: () {
                            // Handle navigation or any other logic when clicking the icon
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 8.0,
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: restaurantMenu[restaurantName]!.length,
                    itemBuilder: (context, index) {
                      final item = restaurantMenu[restaurantName]![index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: defaultPadding,
                          vertical: defaultPadding / 2,
                        ),
                        child: ItemCard(
                          title: item["name"] ?? "No Title",
                          description: item["location"] ?? "No Location",
                          image: item["image"] ?? "No Image",
                          foodType: item["foodType"] ?? "No Food Type",
                          price: 20, // Custom price handling here if needed
                          priceRange:
                              "\$ \$", // Custom price range handling here
                          press: () {
                            context.goNamed(
                              AppRoute.detailScreen.name,
                              pathParameters: {
                                "detailItemId": index.toString(),
                              },
                            );
                          }, // Add empty function to press
                        ),
                      );
                    },
                  ),
                  // Divider(
                  //   thickness: 1.5,
                  //   color: Colors.grey.shade300,
                  //   indent: defaultPadding,
                  //   endIndent: defaultPadding,
                  // ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
