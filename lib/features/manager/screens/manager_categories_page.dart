import 'package:flutter/material.dart';

import 'package:ct484tx_project_trangdc24v7x324/core/pocketbase_client.dart';
import 'package:ct484tx_project_trangdc24v7x324/models/category_model.dart';

class ManagerCategoriesPage extends StatefulWidget {
  const ManagerCategoriesPage({super.key});

  @override
  State<ManagerCategoriesPage> createState() => _ManagerCategoriesPageState();
}

class _ManagerCategoriesPageState extends State<ManagerCategoriesPage> {
  bool _isLoading = false;
  final List<CategoryModel> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final records = await pb
          .collection('categories')
          .getFullList(sort: 'sortOrder');

      _categories
        ..clear()
        ..addAll(
          records.map((record) {
            final data = record.data;
            return CategoryModel(
              id: record.id,
              title: (data['title'] ?? '').toString(),
              slug: (data['slug'] ?? '').toString(),
              icon: (data['icon'] ?? '').toString(),
              sortOrder: ((data['sortOrder'] ?? 0) as num).toInt(),
              isActive: data['isActive'] ?? true,
            );
          }),
        );
    } catch (e) {
      _showMessage('Không tải được danh mục');
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  IconData _getIcon(String icon) {
    switch (icon) {
      case 'restaurant':
        return Icons.restaurant_rounded;
      case 'local_drink':
        return Icons.local_drink_rounded;
      case 'fastfood':
        return Icons.fastfood_rounded;
      case 'bakery_dining':
        return Icons.bakery_dining_rounded;
      case 'icecream':
        return Icons.icecream_rounded;
      case 'ramen_dining':
        return Icons.ramen_dining_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  String _makeSlug(String value) {
    return value
        .toLowerCase()
        .trim()
        .replaceAll(' ', '-')
        .replaceAll('đ', 'd')
        .replaceAll(RegExp(r'[^a-z0-9-]'), '');
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _openForm({CategoryModel? category}) async {
    final titleController = TextEditingController(text: category?.title ?? '');
    final slugController = TextEditingController(text: category?.slug ?? '');
    final sortController = TextEditingController(
      text: category != null ? category.sortOrder.toString() : '0',
    );

    String selectedIcon = category?.icon ?? 'category';
    bool isActive = category?.isActive ?? true;

    final isEdit = category != null;

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              title: Text(isEdit ? 'Sửa danh mục' : 'Thêm danh mục'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Tên danh mục',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        if (!isEdit) {
                          slugController.text = _makeSlug(value);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: slugController,
                      decoration: const InputDecoration(
                        labelText: 'Slug',
                        hintText: 'vd: food, drink, combos',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: sortController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Thứ tự hiển thị',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedIcon,
                      decoration: const InputDecoration(
                        labelText: 'Icon',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'category',
                          child: Text('Danh mục'),
                        ),
                        DropdownMenuItem(
                          value: 'restaurant',
                          child: Text('Món ăn'),
                        ),
                        DropdownMenuItem(
                          value: 'local_drink',
                          child: Text('Nước uống'),
                        ),
                        DropdownMenuItem(
                          value: 'fastfood',
                          child: Text('Combo / Fastfood'),
                        ),
                        DropdownMenuItem(
                          value: 'bakery_dining',
                          child: Text('Bánh'),
                        ),
                        DropdownMenuItem(
                          value: 'icecream',
                          child: Text('Tráng miệng'),
                        ),
                        DropdownMenuItem(
                          value: 'ramen_dining',
                          child: Text('Mì / bún'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setDialogState(() {
                          selectedIcon = value;
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Đang hoạt động'),
                      value: isActive,
                      activeColor: Colors.white,
                      activeTrackColor: Colors.green,
                      inactiveThumbColor: Colors.white,
                      inactiveTrackColor: Colors.grey,
                      onChanged: (value) {
                        setDialogState(() {
                          isActive = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('Hủy'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF2A39),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    final title = titleController.text.trim();
                    final slug = slugController.text.trim();
                    final sortOrder =
                        int.tryParse(sortController.text.trim()) ?? 0;

                    if (title.isEmpty || slug.isEmpty) {
                      _showMessage('Vui lòng nhập tên và slug');
                      return;
                    }

                    try {
                      final body = {
                        'title': title,
                        'slug': slug,
                        'icon': selectedIcon,
                        'sortOrder': sortOrder,
                        'isActive': isActive,
                      };

                      if (isEdit) {
                        await pb
                            .collection('categories')
                            .update(category.id, body: body);
                      } else {
                        await pb.collection('categories').create(body: body);
                      }

                      if (!mounted) return;
                      Navigator.pop(dialogContext, true);
                    } catch (e) {
                      _showMessage(
                        isEdit
                            ? 'Cập nhật danh mục thất bại'
                            : 'Thêm danh mục thất bại',
                      );
                    }
                  },
                  child: Text(isEdit ? 'Cập nhật' : 'Thêm'),
                ),
              ],
            );
          },
        );
      },
    );

    titleController.dispose();
    slugController.dispose();
    sortController.dispose();

    if (result == true) {
      await _loadCategories();
      _showMessage(isEdit ? 'Đã cập nhật danh mục' : 'Đã thêm danh mục');
    }
  }

  Future<void> _confirmDelete(CategoryModel category) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Text('Xóa danh mục'),
          content: Text(
            'Bạn có chắc muốn xóa "${category.title}" không?\n\nNếu danh mục đang được sản phẩm sử dụng, bạn nên tắt hoạt động thay vì xóa.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      await pb.collection('categories').delete(category.id);
      await _loadCategories();
      _showMessage('Đã xóa danh mục');
    } catch (e) {
      _showMessage(
        'Không thể xóa. Danh mục có thể đang được sản phẩm sử dụng.',
      );
    }
  }

  Future<void> _toggleActive(CategoryModel category, bool value) async {
    final index = _categories.indexWhere((item) => item.id == category.id);
    if (index == -1) return;

    final oldCategory = _categories[index];

    setState(() {
      _categories[index] = CategoryModel(
        id: oldCategory.id,
        title: oldCategory.title,
        slug: oldCategory.slug,
        icon: oldCategory.icon,
        sortOrder: oldCategory.sortOrder,
        isActive: value,
      );
    });

    try {
      await pb
          .collection('categories')
          .update(category.id, body: {'isActive': value});
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _categories[index] = oldCategory;
      });

      _showMessage('Cập nhật trạng thái thất bại');
    }
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFEF2A39)),
      );
    }

    if (_categories.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadCategories,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: const [
            SizedBox(height: 220),
            Center(
              child: Text(
                'Chưa có danh mục',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadCategories,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final horizontalPadding = constraints.maxWidth >= 700 ? 24.0 : 16.0;

          return ListView.separated(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              20,
              horizontalPadding,
              88,
            ),
            itemCount: _categories.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, index) {
              final category = _categories[index];

              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: _CategoryCard(
                    category: category,
                    icon: _getIcon(category.icon),
                    onEdit: () => _openForm(category: category),
                    onDelete: () => _confirmDelete(category),
                    onToggle: (value) => _toggleActive(category, value),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEF2A39),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFEF2A39),
        onPressed: () => _openForm(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          const _ManagerHeader(title: 'Quản lý danh mục'),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFF7F7F7),
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: _buildBody(),
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

class _CategoryCard extends StatelessWidget {
  final CategoryModel category;
  final IconData icon;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ValueChanged<bool> onToggle;

  const _CategoryCard({
    required this.category,
    required this.icon,
    required this.onEdit,
    required this.onDelete,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.sizeOf(context).width < 380;

    return Container(
      padding: EdgeInsets.all(isSmall ? 12 : 14),
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
            width: isSmall ? 46 : 52,
            height: isSmall ? 46 : 52,
            decoration: BoxDecoration(
              color: const Color(0xFFFFEEF0),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: const Color(0xFFEF2A39),
              size: isSmall ? 24 : 27,
            ),
          ),
          SizedBox(width: isSmall ? 10 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: isSmall ? 15 : 16,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF2D2D2D),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Slug: ${category.slug}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: isSmall ? 12 : 12.5,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Thứ tự: ${category.sortOrder}',
                  style: TextStyle(
                    fontSize: isSmall ? 12 : 12.5,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Switch(
            value: category.isActive,
            activeColor: Colors.white,
            activeTrackColor: Colors.green,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.grey.shade400,
            onChanged: onToggle,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') {
                onEdit();
              } else if (value == 'delete') {
                onDelete();
              }
            },
            itemBuilder:
                (_) => const [
                  PopupMenuItem(value: 'edit', child: Text('Sửa')),
                  PopupMenuItem(value: 'delete', child: Text('Xóa')),
                ],
          ),
        ],
      ),
    );
  }
}
