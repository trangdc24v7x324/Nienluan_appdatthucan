import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:ct484tx_project_trangdc24v7x324/models/product_model.dart';
import 'package:ct484tx_project_trangdc24v7x324/features/manager/screens/product_form_page.dart';
import 'package:ct484tx_project_trangdc24v7x324/providers/product_provider.dart';

class ManagerProductsPage extends StatefulWidget {
  const ManagerProductsPage({super.key});

  @override
  State<ManagerProductsPage> createState() => _ManagerProductsPageState();
}

class _ManagerProductsPageState extends State<ManagerProductsPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<ProductProvider>().fetchProducts();
    });
  }

  String formatPrice(double price) {
    final int value = price.round();
    final String text = value.toString();
    final StringBuffer result = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      final int positionFromEnd = text.length - i;
      result.write(text[i]);
      if (positionFromEnd > 1 && positionFromEnd % 3 == 1) {
        result.write('.');
      }
    }

    return '${result.toString()}đ';
  }

  String categoryLabel(String category) {
    switch (category) {
      case 'food':
        return 'Món ăn';
      case 'drink':
        return 'Nước uống';
      case 'combos':
        return 'Combo';
      default:
        return category;
    }
  }

  Future<void> _openCreatePage() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProductFormPage()),
    );
  }

  Future<void> _openEditPage(ProductModel product) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ProductFormPage(product: product)),
    );
  }

  Future<void> _confirmDelete(ProductModel product) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Xóa sản phẩm'),
          content: Text('Bạn có chắc muốn xóa "${product.title}" không?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      await context.read<ProductProvider>().deleteProduct(product.id);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đã xóa sản phẩm')));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Xóa sản phẩm thất bại')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý sản phẩm'),
        centerTitle: true,
        backgroundColor: const Color(0xFFEF2A39),
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFEF2A39),
        onPressed: _openCreatePage,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body:
          provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : provider.products.isEmpty
              ? const Center(child: Text('Chưa có sản phẩm'))
              : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: provider.products.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, index) {
                  final product = provider.products[index];

                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 84,
                          height: 84,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child:
                              product.image.isNotEmpty
                                  ? ClipRRect(
                                    borderRadius: BorderRadius.circular(14),
                                    child: Image.network(
                                      product.image,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                  : const Icon(Icons.fastfood_rounded),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                categoryLabel(product.category),
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                formatPrice(product.price),
                                style: const TextStyle(
                                  color: Color(0xFFEF2A39),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                product.isAvailable ? 'Đang bán' : 'Ngừng bán',
                                style: TextStyle(
                                  fontSize: 12,
                                  color:
                                      product.isAvailable
                                          ? Colors.green
                                          : Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            IconButton(
                              onPressed: () => _openEditPage(product),
                              icon: const Icon(
                                Icons.edit_outlined,
                                color: Colors.indigo,
                              ),
                            ),
                            IconButton(
                              onPressed: () => _confirmDelete(product),
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
    );
  }
}
