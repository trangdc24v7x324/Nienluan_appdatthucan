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

  String _selectedCategory = '';
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

    _selectedCategory = product?.category ?? '';
    _isAvailable = product?.isAvailable ?? true;

    Future.microtask(() async {
      await context.read<ProductProvider>().fetchCategories();

      if (!mounted) return;

      final categories = context.read<ProductProvider>().categories;

      if (_selectedCategory.isEmpty && categories.isNotEmpty) {
        setState(() {
          _selectedCategory = categories.first.slug;
        });
      }
    });
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

  Future<void> _submit() async {
    if (_isSubmitting) return;
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
    } catch (_) {
      _showMessage('Lưu sản phẩm thất bại');
    }

    if (mounted) {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  Widget _buildImagePreview() {
    if (_selectedImageFile != null) {
      return _ImageFrame(
        child: Image.file(
          _selectedImageFile!,
          width: double.infinity,
          height: 190,
          fit: BoxFit.cover,
        ),
      );
    }

    if ((widget.product?.image ?? '').isNotEmpty) {
      return _ImageFrame(
        child: Image.network(
          widget.product!.image,
          width: double.infinity,
          height: 190,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) {
            return _emptyImageBox();
          },
        ),
      );
    }

    return _emptyImageBox();
  }

  Widget _emptyImageBox() {
    return Container(
      width: double.infinity,
      height: 190,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_outlined, size: 54, color: Colors.grey),
          SizedBox(height: 8),
          Text(
            'Chưa chọn ảnh sản phẩm',
            style: TextStyle(
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _decoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFEF2A39), width: 1.4),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    );
  }

  Widget _buildForm(ProductProvider productProvider) {
    final categories = productProvider.categories;

    final selectedValue =
        categories.any((cat) => cat.slug == _selectedCategory)
            ? _selectedCategory
            : null;

    if (productProvider.isLoading && categories.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFEF2A39)),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontalPadding = constraints.maxWidth >= 700 ? 24.0 : 16.0;

        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            20,
            horizontalPadding,
            28,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildImagePreview(),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: OutlinedButton.icon(
                        onPressed: _isSubmitting ? null : _pickImage,
                        icon: const Icon(Icons.photo_library_outlined),
                        label: const Text('Chọn ảnh'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFEF2A39),
                          side: const BorderSide(color: Color(0xFFEF2A39)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
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
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return null;
                        }

                        final rating = double.tryParse(value.trim());
                        if (rating == null) {
                          return 'Đánh giá không hợp lệ';
                        }

                        if (rating < 0 || rating > 5) {
                          return 'Đánh giá phải từ 0 đến 5';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedValue,
                      decoration: _decoration('Danh mục'),
                      items:
                          categories.map((cat) {
                            return DropdownMenuItem<String>(
                              value: cat.slug,
                              child: Text(cat.title),
                            );
                          }).toList(),
                      onChanged:
                          _isSubmitting
                              ? null
                              : (value) {
                                if (value == null) return;
                                setState(() {
                                  _selectedCategory = value;
                                });
                              },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng chọn danh mục';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'Đang kinh doanh',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        _isAvailable
                            ? 'Sản phẩm đang hiển thị cho khách'
                            : 'Sản phẩm đang tạm ẩn',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      value: _isAvailable,
                      activeColor: Colors.white,
                      activeTrackColor: Colors.green,
                      inactiveThumbColor: Colors.white,
                      inactiveTrackColor: Colors.grey.shade400,
                      onChanged:
                          _isSubmitting
                              ? null
                              : (value) {
                                setState(() {
                                  _isAvailable = value;
                                });
                              },
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEF2A39),
                          disabledBackgroundColor: Colors.grey.shade400,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child:
                            _isSubmitting
                                ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.4,
                                    color: Colors.white,
                                  ),
                                )
                                : Text(
                                  isEdit ? 'Cập nhật sản phẩm' : 'Lưu sản phẩm',
                                ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFEF2A39),
      body: Column(
        children: [
          _ManagerHeader(title: isEdit ? 'Sửa sản phẩm' : 'Thêm sản phẩm'),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFF7F7F7),
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: _buildForm(productProvider),
            ),
          ),
        ],
      ),
    );
  }
}

class _ManagerHeader extends StatelessWidget {
  final String title;

  const _ManagerHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isSmall = width < 380;

    return SafeArea(
      bottom: false,
      child: Container(
        width: double.infinity,
        color: const Color(0xFFEF2A39),
        padding: EdgeInsets.fromLTRB(
          isSmall ? 12 : 14,
          12,
          isSmall ? 12 : 14,
          16,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Row(
              children: [
                SizedBox(
                  width: 44,
                  height: 44,
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 21,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: isSmall ? 17 : 19,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 44, height: 44),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ImageFrame extends StatelessWidget {
  final Widget child;

  const _ImageFrame({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(borderRadius: BorderRadius.circular(18), child: child);
  }
}
