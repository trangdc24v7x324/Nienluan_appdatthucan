import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:ct484tx_project_trangdc24v7x324/models/product_model.dart';
import 'package:ct484tx_project_trangdc24v7x324/providers/product_provider.dart';

class ProductFormPage extends StatefulWidget {
  final ProductModel? product;

  const ProductFormPage({super.key, this.product});

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _subtitleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _deliveryTimeController;
  late final TextEditingController _priceController;
  late final TextEditingController _ratingController;

  final ImagePicker _picker = ImagePicker();

  String _selectedCategory = 'food';
  bool _isAvailable = true;
  bool _isSubmitting = false;
  File? _selectedImageFile;

  bool get isEdit => widget.product != null;

  @override
  void initState() {
    super.initState();

    final product = widget.product;

    _nameController = TextEditingController(text: product?.title ?? '');
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

    _selectedCategory = product?.category ?? 'food';
    _isAvailable = product?.isAvailable ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _subtitleController.dispose();
    _descriptionController.dispose();
    _deliveryTimeController.dispose();
    _priceController.dispose();
    _ratingController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final result = await _picker.pickImage(source: ImageSource.gallery);
    if (result == null) return;

    setState(() {
      _selectedImageFile = File(result.path);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    final product = ProductModel(
      id: widget.product?.id ?? '',
      title: _nameController.text.trim(),
      subtitle: _subtitleController.text.trim(),
      rating: double.tryParse(_ratingController.text.trim()) ?? 0,
      image: widget.product?.image ?? '',
      description: _descriptionController.text.trim(),
      deliveryTime: _deliveryTimeController.text.trim(),
      price: double.parse(_priceController.text.trim()),
      category: _selectedCategory,
      isAvailable: _isAvailable,
    );

    try {
      final provider = context.read<ProductProvider>();

      if (isEdit) {
        await provider.updateProduct(
          widget.product!.id,
          product,
          imageFile: _selectedImageFile,
        );
      } else {
        await provider.addProduct(product, imageFile: _selectedImageFile);
      }

      if (!mounted) return;
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEdit ? 'Đã cập nhật sản phẩm' : 'Đã thêm sản phẩm'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Lưu sản phẩm thất bại')));
    }

    if (mounted) {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  Widget _buildImagePreview() {
    if (_selectedImageFile != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.file(
          _selectedImageFile!,
          width: double.infinity,
          height: 180,
          fit: BoxFit.cover,
        ),
      );
    }

    if ((widget.product?.image ?? '').isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.network(
          widget.product!.image,
          width: double.infinity,
          height: 180,
          fit: BoxFit.cover,
        ),
      );
    }

    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Icon(Icons.image_outlined, size: 54, color: Colors.grey),
    );
  }

  InputDecoration _decoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Sửa sản phẩm' : 'Thêm sản phẩm'),
        centerTitle: true,
        backgroundColor: const Color(0xFFEF2A39),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildImagePreview(),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('Chọn ảnh'),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: _decoration('Tên sản phẩm'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập tên sản phẩm';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _subtitleController,
                decoration: _decoration('Phụ đề'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: _decoration('Mô tả'),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _deliveryTimeController,
                decoration: _decoration('Thời gian giao'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: _decoration('Giá'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập giá';
                  }
                  if (double.tryParse(value.trim()) == null) {
                    return 'Giá không hợp lệ';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _ratingController,
                keyboardType: TextInputType.number,
                decoration: _decoration('Đánh giá'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: _decoration('Danh mục'),
                items: const [
                  DropdownMenuItem(value: 'food', child: Text('Món ăn')),
                  DropdownMenuItem(value: 'drink', child: Text('Nước uống')),
                  DropdownMenuItem(value: 'combos', child: Text('Combo')),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _selectedCategory = value;
                  });
                },
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Đang kinh doanh'),
                value: _isAvailable,
                onChanged: (value) {
                  setState(() {
                    _isAvailable = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF2A39),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(_isSubmitting ? 'Đang lưu...' : 'Lưu sản phẩm'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
