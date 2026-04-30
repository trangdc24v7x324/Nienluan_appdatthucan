import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:ct484tx_project_trangdc24v7x324/models/cart_item_model.dart';
import 'package:ct484tx_project_trangdc24v7x324/models/product_model.dart';
import 'package:ct484tx_project_trangdc24v7x324/providers/cart_provider.dart';
import 'package:ct484tx_project_trangdc24v7x324/features/product/widgets/food_card.dart';

class FavouritePage extends StatelessWidget {
  const FavouritePage({super.key});

  @override
  Widget build(BuildContext context) {
    final favorites =
        (ModalRoute.of(context)?.settings.arguments as List<ProductModel>?) ??
        [];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Yêu thích',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFEF2A39),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body:
          favorites.isEmpty
              ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Chưa có món yêu thích nào!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.roboto(
                      fontSize: 19,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
              )
              : LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;

                  final crossAxisCount = width < 500 ? 2 : 3;

                  final ratio =
                      width < 380
                          ? 0.75
                          : width < 500
                          ? 0.72
                          : 0.80;

                  return GridView.builder(
                    padding: const EdgeInsets.fromLTRB(14, 16, 14, 20),
                    itemCount: favorites.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount:
                          favorites.length == 1 ? 1 : crossAxisCount,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 16,
                      childAspectRatio: favorites.length == 1 ? 0.9 : ratio,
                    ),
                    itemBuilder: (context, index) {
                      final item = favorites[index];

                      return FoodCard(
                        product: item,
                        isFavorited: true,
                        onFavoriteToggle: () {},
                        onAddToCart: () {
                          final cart = Provider.of<CartProvider>(
                            context,
                            listen: false,
                          );

                          cart.addItem(
                            CartItem(
                              productId: item.id,
                              title: item.title,
                              image: item.image,
                              price: item.price,
                              quantity: 1,
                            ),
                          );

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${item.title} đã thêm vào giỏ hàng',
                              ),
                              duration: const Duration(milliseconds: 900),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              )
    );
  }
}
