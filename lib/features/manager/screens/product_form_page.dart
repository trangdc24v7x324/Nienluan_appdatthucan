import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:CT466_project_trangdc24v7x324/models/category_model.dart';
import 'package:CT466_project_trangdc24v7x324/models/product_model.dart';
import 'package:CT466_project_trangdc24v7x324/providers/product_provider.dart';
import 'package:CT466_project_trangdc24v7x324/shared/widgets/app_body.dart';
import 'package:CT466_project_trangdc24v7x324/shared/widgets/app_layout.dart';

class ProductFormPage extends StatefulWidget {
  final ProductModel? product;

  const ProductFormPage({super.key, this.product});

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  late final TextEditingController _titleController;
  late final TextEditingController _subtitleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _deliveryTimeController;
  late final TextEditingController _priceController;
  late final TextEditingController _ratingController;

  String? _selectedCategoryId;
  bool _isAvailable = true;
  bool _isSubmitting = false;
  File? _selectedImageFile;

  bool get isEdit => widget.product != null;

  @override
  void initState() {
    super.initState();

    final product = widget.product;

    _titleController = TextEditingController(text: product?.title ?? '');
    _subtitleController = TextEditingController(text: product?.subtitle ?? '');
    _descriptionController = TextEditingController(
      text: product?.description ?? '',
    );
    _deliveryTimeController = TextEditingController(
      text: product?.deliveryTime ?? '20-30 phút',
    );
    _priceController = TextEditingController(
      text: product != null ? product.price.toStringAsFixed(0) : '',
    );
    _ratingController = TextEditingController(
      text: product != null ? product.rating.toString() : '4.5',
    );

    _selectedCategoryId =
        product?.categoryId.isNotEmpty == true ? product!.categoryId : null;
    _isAvailable = product?.isAvailable ?? true;

    Future.microtask(() async {
      final provider = context.read<ProductProvider>();
      await provider.loadCategories();

      if (!mounted) return;

      if (_selectedCategoryId == null && provider.categories.isNotEmpty) {
        setState(() {
          _selectedCategoryId = provider.categories.first.id;
        });
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _descriptionController.dispose();
    _deliveryTimeController.dispose();
    _priceController.dispose();
    _ratingController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _pickImage() async {
    if (_isSubmitting) return;

    final result = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1200,
    );

    if (result == null) return;

    setState(() {
      _selectedImageFile = File(result.path);
    });
  }

  CategoryModel? _selectedCategory(ProductProvider provider) {
    if (_selectedCategoryId == null) return null;

    try {
      return provider.categories.firstWhere(
        (category) => category.id == _selectedCategoryId,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<ProductProvider>();
    final category = _selectedCategory(provider);

    if (category == null) {
      _showMessage('Vui lòng chọn danh mục');
      return;
    }

    final price = double.tryParse(_priceController.text.trim());
    if (price == null || price <= 0) {
      _showMessage('Giá sản phẩm không hợp lệ');
      return;
    }

    if (!isEdit && _selectedImageFile == null) {
      _showMessage('Vui lòng chọn ảnh sản phẩm');
      return;
    }

    setState(() => _isSubmitting = true);

    final product = ProductModel(
      id: widget.product?.id ?? '',
      title: _titleController.text.trim(),
      subtitle: _subtitleController.text.trim(),
      rating: double.tryParse(_ratingController.text.trim()) ?? 0,
      image: widget.product?.image ?? '',
      description: _descriptionController.text.trim(),
      deliveryTime: _deliveryTimeController.text.trim(),
      price: price,
      categoryId: category.id,
      categoryTitle: category.title,
      categorySlug: category.slug,
      isAvailable: _isAvailable,
    );

    final success =
        isEdit
            ? await provider.updateProduct(
              widget.product!.id,
              product,
              imageFile: _selectedImageFile,
            )
            : await provider.addProduct(product, imageFile: _selectedImageFile);

    if (!mounted) return;

    setState(() => _isSubmitting = false);

    if (success) {
      Navigator.pop(context, true);
      _showMessage(isEdit ? 'Đã cập nhật sản phẩm' : 'Đã thêm sản phẩm');
    } else {
      _showMessage(provider.errorMessage ?? 'Lưu sản phẩm thất bại');
    }
  }

  Widget _buildImagePreview() {
    if (_selectedImageFile != null) {
      return _imageBox(Image.file(_selectedImageFile!, fit: BoxFit.cover));
    }

    if ((widget.product?.image ?? '').isNotEmpty) {
      return _imageBox(
        Image.network(
          widget.product!.image,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Icon(Icons.fastfood_rounded),
        ),
      );
    }

    return _emptyImageBox();
  }

  Widget _imageBox(Widget child) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(height: 190, width: double.infinity, child: child),
    );
  }

  Widget _emptyImageBox() {
    return Container(
      height: 190,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: const Center(child: Text('Chưa chọn ảnh')),
    );
  }

  InputDecoration _decoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
    );
  }

  Widget _buildForm(ProductProvider provider) {
    final categories = provider.categories;

    if (provider.isLoading && categories.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFEF2A39)),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildImagePreview(),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          onPressed: _isSubmitting ? null : _pickImage,
          icon: const Icon(Icons.image_rounded),
          label: const Text('Chọn ảnh'),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _titleController,
          decoration: _decoration('Tên sản phẩm'),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Nhập tên sản phẩm';
            }
            return null;
          },
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: _subtitleController,
          decoration: _decoration('Mô tả ngắn'),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: _priceController,
          keyboardType: TextInputType.number,
          decoration: _decoration('Giá'),
          validator: (value) {
            final price = double.tryParse(value?.trim() ?? '');
            if (price == null || price <= 0) return 'Giá không hợp lệ';
            return null;
          },
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: _ratingController,
          keyboardType: TextInputType.number,
          decoration: _decoration('Đánh giá'),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: _deliveryTimeController,
          decoration: _decoration('Thời gian giao'),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: _descriptionController,
          maxLines: 4,
          decoration: _decoration('Mô tả chi tiết'),
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          value: _selectedCategoryId,
          decoration: _decoration('Danh mục'),
          items:
              categories.map((category) {
                return DropdownMenuItem(
                  value: category.id,
                  child: Text(category.title),
                );
              }).toList(),
          onChanged:
              _isSubmitting
                  ? null
                  : (value) => setState(() => _selectedCategoryId = value),
          validator:
              (value) =>
                  value == null || value.isEmpty ? 'Chọn danh mục' : null,
        ),
        const SizedBox(height: 10),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Đang bán'),
          value: _isAvailable,
          onChanged:
              _isSubmitting
                  ? null
                  : (value) => setState(() => _isAvailable = value),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFEF2A39),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 48),
          ),
          onPressed: _isSubmitting ? null : _submit,
          child:
              _isSubmitting
                  ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                  : Text(isEdit ? 'Cập nhật' : 'Thêm sản phẩm'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();

    return AppLayout(
      title: isEdit ? 'Sửa sản phẩm' : 'Thêm sản phẩm',
      showBack: true,
      child: AppBody(child: Form(key: _formKey, child: _buildForm(provider))),
    );
  }
}
