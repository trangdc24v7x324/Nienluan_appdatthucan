import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:ct484tx_project_trangdc24v7x324/providers/cart_provider.dart';
import 'package:ct484tx_project_trangdc24v7x324/routes/app_routes.dart';
import 'package:ct484tx_project_trangdc24v7x324/widgets/category_selector.dart';
import 'package:ct484tx_project_trangdc24v7x324/widgets/food_list.dart';
import 'package:ct484tx_project_trangdc24v7x324/widgets/nav_icon.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> favoritedItems = [];
  String searchQuery = '';
  String selectedCategory = 'all';
  int selectedIndex = 0;

  void toggleFavorite(Map<String, dynamic> item) {
    setState(() {
      if (favoritedItems.contains(item)) {
        favoritedItems.remove(item);
      } else {
        favoritedItems.add(item);
      }
    });
  }

  void _handleTap(int index) async {
    setState(() {
      selectedIndex = index;
    });

    switch (index) {
      case 1:
        await Navigator.pushNamed(context, AppRoutes.cart);
        break;
      case 2:
        await Navigator.pushNamed(context, AppRoutes.chat);
        break;
      case 3:
        await Navigator.pushNamed(context, AppRoutes.notifications);
        break;
    }

    if (!mounted) return;

    setState(() {
      selectedIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final cartCount = cart.items.fold<int>(
      0,
      (sum, item) => sum + item.quantity,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),

      // ===== BOTTOM BAR =====
      bottomNavigationBar: Container(
        height: 76,
        decoration: const BoxDecoration(
          color: Color(0xFFEF2A39),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(22),
            topRight: Radius.circular(22),
          ),
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              NavIcon(
                index: 0,
                selectedIndex: selectedIndex,
                onTap: _handleTap,
              ),
              NavIcon(
                index: 1,
                selectedIndex: selectedIndex,
                onTap: _handleTap,
                badgeCount: cartCount,
              ),
              NavIcon(
                index: 2,
                selectedIndex: selectedIndex,
                onTap: _handleTap,
              ),
              NavIcon(
                index: 3,
                selectedIndex: selectedIndex,
                onTap: _handleTap,
              ),
            ],
          ),
        ),
      ),

      // ===== BODY =====
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 10),

              // ===== HEADER =====
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'YourFood',
                          style: GoogleFonts.lobster(
                            fontSize: 34,
                            color: const Color(0xff3C2F2F),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Ăn uống theo cách của bạn!',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: const Color(0xff6A6A6A),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 6),
                      ],
                    ),
                    child: IconButton(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.profile);
                      },
                      icon: const Icon(Icons.person_outline),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // ===== SEARCH =====
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: const [
                          BoxShadow(color: Colors.black12, blurRadius: 6),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Row(
                          children: [
                            const Icon(CupertinoIcons.search),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                onChanged: (value) {
                                  setState(() {
                                    searchQuery = value;
                                  });
                                },
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Tìm món ăn...',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    height: 52,
                    width: 52,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF2A39),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: IconButton(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.favourite,
                          arguments: favoritedItems,
                        );
                      },
                      icon: const Icon(
                        Icons.favorite_border,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // ===== CATEGORY =====
              CategorySelector(
                selectedCategory: selectedCategory,
                onCategorySelected: (value) {
                  setState(() {
                    selectedCategory = value;
                  });
                },
              ),

              const SizedBox(height: 14),

              // ===== FOOD LIST =====
              Expanded(
                child: FoodAvailable(
                  favoritedItems: favoritedItems,
                  onFavoriteToggle: toggleFavorite,
                  searchQuery: searchQuery,
                  selectedCategory: selectedCategory,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
