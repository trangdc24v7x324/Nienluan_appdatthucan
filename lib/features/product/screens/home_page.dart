import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:ct484tx_project_trangdc24v7x324/features/product/widgets/food_list.dart';
import 'package:ct484tx_project_trangdc24v7x324/models/product_model.dart';
import 'package:ct484tx_project_trangdc24v7x324/providers/cart_provider.dart';
import 'package:ct484tx_project_trangdc24v7x324/providers/product_provider.dart';
import 'package:ct484tx_project_trangdc24v7x324/providers/profile_provider.dart';
import 'package:ct484tx_project_trangdc24v7x324/providers/chat_provider.dart';
import 'package:ct484tx_project_trangdc24v7x324/providers/notification_provider.dart';
import 'package:ct484tx_project_trangdc24v7x324/routes/app_routes.dart';
import 'package:ct484tx_project_trangdc24v7x324/shared/widgets/category_selector.dart';
import 'package:ct484tx_project_trangdc24v7x324/shared/widgets/nav_icon.dart';
import 'package:ct484tx_project_trangdc24v7x324/features/chat/screens/chat_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<ProductModel> favoritedItems = [];
  String searchQuery = '';
  String selectedCategory = 'all';
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      final productProvider = context.read<ProductProvider>();

      if (!productProvider.isLoading) {
        await productProvider.fetchInitialData();
      }

      if (!mounted) return;

      await context.read<ProfileProvider>().loadProfile();

      if (!mounted) return;

      context.read<ChatProvider>().listenChatRooms();

      try {
        await context.read<NotificationProvider>().loadCustomerNotifications();
      } catch (_) {}
    });
  }

  void toggleFavorite(ProductModel item) {
    setState(() {
      final exists = favoritedItems.any((product) => product.id == item.id);

      if (exists) {
        favoritedItems.removeWhere((product) => product.id == item.id);
      } else {
        favoritedItems.add(item);
      }
    });
  }

  Future<void> _handleTap(int index) async {
    setState(() {
      selectedIndex = index;
    });

    switch (index) {
      case 1:
        await Navigator.pushNamed(context, AppRoutes.cart);
        break;

      case 2:
        final profile = context.read<ProfileProvider>().profile;

        if (profile == null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Vui lòng đăng nhập')));
          break;
        }

        await Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (_) => ChatPage(
                  userId: profile.username,
                  userName: profile.fullName,
                  userAvatar: profile.avatarUrl,
                  currentUserId: profile.username,
                  currentUserRole: 'user',
                ),
          ),
        );
        break;

      case 3:
        await Navigator.pushNamed(context, AppRoutes.notifications);

        if (!mounted) return;

        try {
          await context
              .read<NotificationProvider>()
              .loadCustomerNotifications();
        } catch (_) {}
        break;

      default:
        break;
    }

    if (!mounted) return;

    setState(() {
      selectedIndex = 0;
    });
  }

  Future<void> _refreshData() async {
    await context.read<ProductProvider>().fetchCategories();
    await context.read<ProductProvider>().fetchProducts();
    await context.read<ProfileProvider>().loadProfile();

    try {
      await context.read<NotificationProvider>().loadCustomerNotifications();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final productProvider = context.watch<ProductProvider>();
    final profileProvider = context.watch<ProfileProvider>();
    final chatProvider = context.watch<ChatProvider>();
    final notificationProvider = context.watch<NotificationProvider>();

    final avatarUrl = profileProvider.profile?.avatarUrl;

    final cartCount = cart.items.fold<int>(
      0,
      (sum, item) => sum + item.quantity,
    );

    final chatCount = chatProvider.unreadCount;
    final notificationCount = notificationProvider.unreadCount;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
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
                badgeCount: chatCount,
              ),
              NavIcon(
                index: 3,
                selectedIndex: selectedIndex,
                onTap: _handleTap,
                badgeCount: notificationCount,
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshData,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                const SizedBox(height: 10),
                _HeaderSection(avatarUrl: avatarUrl),
                const SizedBox(height: 18),
                _SearchAndFavoriteSection(
                  onSearchChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                  favoritedItems: favoritedItems,
                ),
                const SizedBox(height: 18),
                CategorySelector(
                  categories: productProvider.categories,
                  selectedCategory: selectedCategory,
                  onCategorySelected: (value) {
                    setState(() {
                      selectedCategory = value;
                    });
                  },
                ),
                const SizedBox(height: 14),
                Expanded(
                  child:
                      productProvider.isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : productProvider.error != null
                          ? Center(child: Text(productProvider.error!))
                          : FoodAvailable(
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
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  final String? avatarUrl;

  const _HeaderSection({required this.avatarUrl});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'YourFood',
                style: GoogleFonts.lobster(
                  fontSize: 34,
                  color: const Color.fromARGB(255, 223, 8, 8),
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Ăn uống theo cách của bạn!',
                style: TextStyle(
                  fontSize: 14,
                  color: Color.fromARGB(255, 79, 76, 76),
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 6),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child:
                  avatarUrl != null && avatarUrl!.isNotEmpty
                      ? Image.network(
                        avatarUrl!,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (_, __, ___) => const Icon(
                              Icons.person_outline,
                              color: Colors.grey,
                            ),
                      )
                      : const Icon(Icons.person_outline, color: Colors.grey),
            ),
          ),
        ),
      ],
    );
  }
}

class _SearchAndFavoriteSection extends StatelessWidget {
  final ValueChanged<String> onSearchChanged;
  final List<ProductModel> favoritedItems;

  const _SearchAndFavoriteSection({
    required this.onSearchChanged,
    required this.favoritedItems,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
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
                      onChanged: onSearchChanged,
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
            icon: const Icon(Icons.favorite_border, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
