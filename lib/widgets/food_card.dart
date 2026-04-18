import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ct484tx_project_trangdc24v7x324/routes/app_routes.dart';

class FoodCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final double rating;
  final String image;
  final String description;
  final String deliveryTime;
  final double price;
  final bool isFavorited;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onAddToCart;

  const FoodCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.rating,
    required this.image,
    required this.description,
    required this.deliveryTime,
    required this.price,
    required this.isFavorited,
    required this.onFavoriteToggle,
    required this.onAddToCart,
  });

  @override
  State<FoodCard> createState() => _FoodCardState();
}

class _FoodCardState extends State<FoodCard> {
  bool _isCartAnimating = false;

  Future<void> _handleAddToCart() async {
    setState(() {
      _isCartAnimating = true;
    });

    widget.onAddToCart();

    await Future.delayed(const Duration(milliseconds: 180));

    if (!mounted) return;

    setState(() {
      _isCartAnimating = false;
    });
  }

  String formatPrice(double price) {
    final value = price.toInt().toString();
    final buffer = StringBuffer();

    for (int i = 0; i < value.length; i++) {
      buffer.write(value[i]);
      final remaining = value.length - i - 1;
      if (remaining > 0 && remaining % 3 == 0) {
        buffer.write('.');
      }
    }

    return '${buffer.toString()}đ';
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(15),
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.product,
          arguments: {
            'title': widget.title,
            'subtitle': widget.subtitle,
            'rating': widget.rating,
            'image': widget.image,
            'description': widget.description,
            'deliveryTime': widget.deliveryTime,
            'price': widget.price,
          },
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 6,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
                child: Center(
                  child: Image.asset(
                    widget.image,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.fastfood,
                        size: 40,
                        color: Colors.grey,
                      );
                    },
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 2, 10, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      widget.subtitle,
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatPrice(widget.price),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.orange, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          widget.rating.toStringAsFixed(1),
                          style: const TextStyle(fontSize: 12.5),
                        ),
                        const Spacer(),
                        AnimatedScale(
                          scale: _isCartAnimating ? 1.15 : 1.0,
                          duration: const Duration(milliseconds: 150),
                          child: InkWell(
                            onTap: _handleAddToCart,
                            borderRadius: BorderRadius.circular(20),
                            child: const Padding(
                              padding: EdgeInsets.all(2),
                              child: Icon(
                                CupertinoIcons.cart_badge_plus,
                                color: Colors.red,
                                size: 21,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        InkWell(
                          onTap: widget.onFavoriteToggle,
                          borderRadius: BorderRadius.circular(20),
                          child: Padding(
                            padding: const EdgeInsets.all(2),
                            child: Icon(
                              widget.isFavorited
                                  ? CupertinoIcons.heart_fill
                                  : CupertinoIcons.heart,
                              color: widget.isFavorited
                                  ? Colors.red
                                  : Colors.grey,
                              size: 21,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
