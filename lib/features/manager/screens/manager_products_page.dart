import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:CT466_project_trangdc24v7x324/features/manager/screens/product_form_page.dart';
import 'package:CT466_project_trangdc24v7x324/models/product_model.dart';
import 'package:CT466_project_trangdc24v7x324/providers/product_provider.dart';
import 'package:CT466_project_trangdc24v7x324/shared/widgets/app_body.dart';
import 'package:CT466_project_trangdc24v7x324/shared/widgets/app_layout.dart';

class ManagerProductsPage extends StatefulWidget {
  const ManagerProductsPage({super.key});

  @override
  State<ManagerProductsPage> createState() => _ManagerProductsPageState();
}

class _ManagerProductsPageState extends State<ManagerProductsPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<ProductProvider>().loadInitialData());
  }

  Future<void> _refreshData() async {
    await context.read<ProductProvider>().loadInitialData();
  }

  String _formatPrice(double price) {
    final value = price.round().toString();
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

  Future<void> _openCreatePage() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const ProductFormPage()),
    );

    if (result == true && mounted) {
      await context.read<ProductProvider>().loadProducts();
    }
  }

  Future<void> _openEditPage(ProductModel product) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => ProductFormPage(product: product)),
    );

    if (result == true && mounted) {
      await context.read<ProductProvider>().loadProducts();
    }
  }

  Future<void> _confirmDelete(ProductModel product) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Text('Xóa sản phẩm'),
          content: Text('Bạn có chắc muốn xóa "${product.title}" không?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
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

    final success = await context.read<ProductProvider>().deleteProduct(
      product.id,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Đã xóa sản phẩm' : 'Xóa sản phẩm thất bại'),
      ),
    );
  }

  Widget _buildBody(ProductProvider provider) {
    if (provider.isLoading && provider.products.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFEF2A39)),
      );
    }

    if (provider.products.isEmpty) {
      return RefreshIndicator(
        onRefresh: _refreshData,
        child: ListView(
          children: const [
            SizedBox(height: 220),
            Center(child: Text('Chưa có sản phẩm')),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
        itemCount: provider.products.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, index) {
          final product = provider.products[index];

          return _ProductCard(
            product: product,
            categoryTitle:
                product.categoryTitle.trim().isEmpty
                    ? 'Khác'
                    : product.categoryTitle,
            priceText: _formatPrice(product.price),
            onEdit: () => _openEditPage(product),
            onDelete: () => _confirmDelete(product),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();

    return AppLayout(
      title: 'Quản lý sản phẩm',
      showBack: true,
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFEF2A39),
        onPressed: _openCreatePage,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      child: AppBody(child: _buildBody(provider)),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final ProductModel product;
  final String categoryTitle;
  final String priceText;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProductCard({
    required this.product,
    required this.categoryTitle,
    required this.priceText,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.sizeOf(context).width < 380;

    return Container(
      padding: EdgeInsets.all(isSmall ? 12 : 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
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
          _ProductImage(imageUrl: product.image, size: isSmall ? 72 : 84),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(categoryTitle, style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 4),
                Text(
                  priceText,
                  style: const TextStyle(
                    color: Color(0xFFEF2A39),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                _StatusChip(isAvailable: product.isAvailable),
              ],
            ),
          ),
          Column(
            children: [
              _CircleIconButton(
                icon: Icons.edit,
                color: Colors.indigo,
                onTap: onEdit,
              ),
              const SizedBox(height: 8),
              _CircleIconButton(
                icon: Icons.delete,
                color: Colors.red,
                onTap: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  final String imageUrl;
  final double size;

  const _ProductImage({required this.imageUrl, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
      ),
      child:
          imageUrl.isNotEmpty
              ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (_, __, ___) => const Icon(Icons.fastfood_rounded),
                ),
              )
              : const Icon(Icons.fastfood_rounded),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final bool isAvailable;

  const _StatusChip({required this.isAvailable});

  @override
  Widget build(BuildContext context) {
    final color = isAvailable ? Colors.green : Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        isAvailable ? 'Đang bán' : 'Ngừng bán',
        style: TextStyle(color: color, fontSize: 12),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _CircleIconButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(99),
      onTap: onTap,
      child: CircleAvatar(
        radius: 18,
        backgroundColor: color.withOpacity(0.1),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }
}
