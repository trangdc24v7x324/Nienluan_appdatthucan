import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:CT466_project_trangdc24v7x324/models/cart_item_model.dart';
import 'package:CT466_project_trangdc24v7x324/models/product_model.dart';
import 'package:CT466_project_trangdc24v7x324/providers/cart_provider.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  int quantity = 1;
  final TextEditingController noteController = TextEditingController();

  @override
  void dispose() {
    noteController.dispose();
    super.dispose();
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

    return '${buffer}đ';
  }

  Widget _buildProductImage(String image) {
    if (image.isEmpty) {
      return const Center(
        child: Icon(Icons.fastfood, size: 60, color: Colors.grey),
      );
    }

    final isNetworkImage =
        image.startsWith('http://') || image.startsWith('https://');

    if (isNetworkImage) {
      return Image.network(
        image,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return const Center(
            child: Icon(Icons.fastfood, size: 60, color: Colors.grey),
          );
        },
      );
    }

    return Image.asset(
      image,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return const Center(
          child: Icon(Icons.fastfood, size: 60, color: Colors.grey),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;

    if (args == null || args is! ProductModel) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Không có dữ liệu sản phẩm')),
      );
    }

    final product = args;
    final totalPrice = product.price * quantity;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F4F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F4F6),
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: Color(0xff3C2F2F)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        height: 280,
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: _buildProductImage(product.image),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      product.title,
                      style: GoogleFonts.roboto(
                        textStyle: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Color(0xff3C2F2F),
                        ),
                      ),
                    ),
                    if (product.subtitle.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        product.subtitle,
                        style: GoogleFonts.roboto(
                          textStyle: const TextStyle(
                            fontSize: 16,
                            color: Color(0xff808080),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          product.rating.toStringAsFixed(1),
                          style: GoogleFonts.roboto(
                            textStyle: const TextStyle(
                              fontSize: 16,
                              color: Color(0xff808080),
                            ),
                          ),
                        ),
                        if (product.deliveryTime.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Text(
                            '• ${product.deliveryTime}',
                            style: GoogleFonts.roboto(
                              textStyle: const TextStyle(
                                fontSize: 16,
                                color: Color(0xff808080),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      product.description.isEmpty
                          ? 'Chưa có mô tả cho sản phẩm này.'
                          : product.description,
                      style: GoogleFonts.roboto(
                        textStyle: const TextStyle(
                          fontSize: 16,
                          color: Color(0xff6A6A6A),
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Ghi chú',
                      style: GoogleFonts.roboto(
                        textStyle: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: Color(0xff3C2F2F),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: noteController,
                      maxLines: 3,
                      style: GoogleFonts.roboto(
                        textStyle: const TextStyle(
                          fontSize: 15,
                          color: Color(0xff3C2F2F),
                        ),
                      ),
                      decoration: InputDecoration(
                        hintText: 'Ví dụ: ít đá, không hành, thêm tương...',
                        hintStyle: GoogleFonts.roboto(
                          textStyle: const TextStyle(
                            color: Color(0xff9A9A9A),
                            fontSize: 14,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.all(14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Row(
                      children: [
                        Text(
                          'Số lượng',
                          style: GoogleFonts.roboto(
                            textStyle: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Color(0xff3C2F2F),
                            ),
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {
                            if (quantity > 1) {
                              setState(() => quantity--);
                            }
                          },
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              CupertinoIcons.minus,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Container(
                          width: 48,
                          alignment: Alignment.center,
                          child: Text(
                            quantity.toString(),
                            style: GoogleFonts.roboto(
                              textStyle: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: Color(0xff3C2F2F),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        GestureDetector(
                          onTap: () => setState(() => quantity++),
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              CupertinoIcons.add,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  ),
                ],
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(22),
                  topRight: Radius.circular(22),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Container(
                      height: 58,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Text(
                          formatPrice(totalPrice),
                          style: GoogleFonts.roboto(
                            textStyle: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    flex: 4,
                    child: SizedBox(
                      height: 58,
                      child: ElevatedButton(
                        onPressed: () {
                          final cart = context.read<CartProvider>();

                          cart.addItem(
                            CartItemModel(
                              productId: product.id,
                              title: product.title,
                              image: product.image,
                              price: product.price,
                              quantity: quantity,
                              categoryId: product.categoryId,
                              categoryTitle: product.categoryTitle,
                              categorySlug: product.categorySlug,
                            ),
                          );

                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                noteController.text.trim().isEmpty
                                    ? 'Đã thêm ${product.title} vào giỏ hàng'
                                    : 'Đã thêm ${product.title} - Ghi chú: ${noteController.text.trim()}',
                              ),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );

                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff3C2F2F),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          'Thêm vào giỏ',
                          style: GoogleFonts.roboto(
                            textStyle: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
