import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:ct484tx_project_trangdc24v7x324/models/cart_item_model.dart';
import 'package:ct484tx_project_trangdc24v7x324/providers/cart_provider.dart';
import 'package:ct484tx_project_trangdc24v7x324/widgets/food_card.dart';

class FavouritePage extends StatelessWidget {
  const FavouritePage({super.key});

  @override
  Widget build(BuildContext context) {
    final favorites =
        (ModalRoute.of(context)?.settings.arguments
            as List<Map<String, dynamic>>?) ??
        [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        elevation: 1,
      ),
      body:
          favorites.isEmpty
              ? Center(
                child: Text(
                  'No favorites yet!',
                  style: GoogleFonts.roboto(
                    fontSize: 20,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              )
              : GridView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: favorites.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: favorites.length == 1 ? 1 : 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.6,
                ),
                itemBuilder: (context, index) {
                  final item = favorites[index];

                  return FoodCard(
                    title: item['title'],
                    subtitle: item['subtitle'],
                    rating: item['rating'],
                    image: item['image'],
                    description: item['description'],
                    deliveryTime: item['deliveryTime'],
                    price: item['price'],
                    isFavorited: true,
                    onFavoriteToggle: () {},
                    onAddToCart: () {
                      final cart = Provider.of<CartProvider>(
                        context,
                        listen: false,
                      );

                      cart.addItem(
                        CartItem(
                          title: item['title'],
                          image: item['image'],
                          price: item['price'],
                          quantity: 1,
                        ),
                      );

                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${item['title']} added to cart'),
                          duration: const Duration(milliseconds: 900),
                        ),
                      );
                    },
                  );
                },
              ),
    );
  }
}
