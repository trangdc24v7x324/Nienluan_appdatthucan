import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:ct484tx_project_trangdc24v7x324/providers/order_provider.dart';

enum RevenueFilterType { today, week, month, custom }

class ManagerRevenuePage extends StatefulWidget {
  const ManagerRevenuePage({super.key});

  @override
  State<ManagerRevenuePage> createState() => _ManagerRevenuePageState();
}

class _ManagerRevenuePageState extends State<ManagerRevenuePage> {
  RevenueFilterType selectedFilter = RevenueFilterType.today;

  late DateTime startDate;
  late DateTime endDate;

  bool _showCatalogProducts = false;

  @override
  void initState() {
    super.initState();
    _setDefaultToday();

    Future.microtask(() {
      context.read<OrderProvider>().loadAllOrders();
    });
  }

  void _setDefaultToday() {
    final now = DateTime.now();
    startDate = DateTime(now.year, now.month, now.day);
    endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
  }

  void _updateRangeByFilter(RevenueFilterType type) {
    final now = DateTime.now();

    switch (type) {
      case RevenueFilterType.today:
        startDate = DateTime(now.year, now.month, now.day);
        endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;
      case RevenueFilterType.week:
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        startDate = DateTime(
          startOfWeek.year,
          startOfWeek.month,
          startOfWeek.day,
        );
        endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;
      case RevenueFilterType.month:
        startDate = DateTime(now.year, now.month, 1);
        endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;
      case RevenueFilterType.custom:
        break;
    }
  }

  Future<void> _selectCustomRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: startDate, end: endDate),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF22C55E),
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked == null) return;

    setState(() {
      selectedFilter = RevenueFilterType.custom;
      startDate = DateTime(
        picked.start.year,
        picked.start.month,
        picked.start.day,
      );
      endDate = DateTime(
        picked.end.year,
        picked.end.month,
        picked.end.day,
        23,
        59,
        59,
      );
    });
  }

  String formatPrice(double price) {
    final text = price.round().toString();
    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      final remaining = text.length - i - 1;
      if (remaining > 0 && remaining % 3 == 0) {
        buffer.write('.');
      }
    }

    return '${buffer}đ';
  }

  String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  bool _isCompleted(dynamic order) {
    final status = order.status.toString().toLowerCase();

    return status.contains('completed') ||
        status.contains('complete') ||
        status.contains('done') ||
        status.contains('success') ||
        status.contains('delivered') ||
        status.contains('hoàn thành') ||
        status.contains('thanh cong') ||
        status.contains('thành công');
  }

  DateTime _getOrderDate(dynamic order) {
    final value = order.orderDate;

    if (value is DateTime) return value;

    try {
      return DateTime.parse(value.toString());
    } catch (_) {
      return DateTime.now();
    }
  }

  double _getOrderTotal(dynamic order) {
    try {
      return (order.totalAmount as num).toDouble();
    } catch (_) {
      return 0;
    }
  }

  List<dynamic> _getFilteredCompletedOrders(List<dynamic> orders) {
    return orders.where((order) {
      final date = _getOrderDate(order);

      return _isCompleted(order) &&
          !date.isBefore(startDate) &&
          !date.isAfter(endDate);
    }).toList();
  }

  Map<String, Map<String, int>> _getProductsByCategory(List<dynamic> orders) {
    final Map<String, Map<String, int>> result = {};

    for (final order in orders) {
      for (final item in order.items) {
        final categoryName =
            item.categoryTitle.toString().trim().isEmpty
                ? 'Khác'
                : item.categoryTitle.toString().trim();

        final productName =
            item.title.toString().trim().isEmpty
                ? 'Sản phẩm'
                : item.title.toString().trim();

        final quantity =
            item.quantity is int
                ? item.quantity as int
                : int.tryParse(item.quantity.toString()) ?? 1;

        result.putIfAbsent(categoryName, () => {});
        result[categoryName]![productName] =
            (result[categoryName]![productName] ?? 0) + quantity;
      }
    }

    for (final category in result.keys) {
      result[category] = Map.fromEntries(
        result[category]!.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value)),
      );
    }

    return Map.fromEntries(
      result.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
  }

  int _getSoldItemCount(Map<String, Map<String, int>> productsByCategory) {
    return productsByCategory.values.fold<int>(
      0,
      (sum, products) => sum + products.values.fold<int>(0, (s, q) => s + q),
    );
  }

  int _getCategoryCount(Map<String, Map<String, int>> productsByCategory) {
    return productsByCategory.length;
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<OrderProvider>();
    final orders = orderProvider.orders;

    final completedOrders = _getFilteredCompletedOrders(orders);

    final totalRevenue = completedOrders.fold<double>(
      0,
      (sum, order) => sum + _getOrderTotal(order),
    );

    final productsByCategory = _getProductsByCategory(completedOrders);
    final soldItemCount = _getSoldItemCount(productsByCategory);
    final categoryCount = _getCategoryCount(productsByCategory);

    return Scaffold(
      backgroundColor: const Color(0xFFEF2A39),
      body: Column(
        children: [
          const _ManagerHeader(title: 'Doanh thu'),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: RefreshIndicator(
                onRefresh: () => context.read<OrderProvider>().loadAllOrders(),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final horizontalPadding =
                        constraints.maxWidth >= 700 ? 24.0 : 16.0;

                    return ListView(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        20,
                        horizontalPadding,
                        28,
                      ),
                      children: [
                        Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 760),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _FilterSection(
                                  selectedFilter: selectedFilter,
                                  onSelect: (type) async {
                                    if (type == RevenueFilterType.custom) {
                                      await _selectCustomRange();
                                      return;
                                    }

                                    setState(() {
                                      selectedFilter = type;
                                      _updateRangeByFilter(type);
                                    });
                                  },
                                ),
                                const SizedBox(height: 12),
                                _DateRangeLabel(
                                  startDate: formatDate(startDate),
                                  endDate: formatDate(endDate),
                                ),
                                const SizedBox(height: 16),
                                _RevenueSummaryCard(
                                  totalRevenue: formatPrice(totalRevenue),
                                  completedOrders: completedOrders.length,
                                  soldItems: soldItemCount,
                                  categoryCount: categoryCount,
                                  showCatalogProducts: _showCatalogProducts,
                                  onCatalogTap: () {
                                    setState(() {
                                      _showCatalogProducts =
                                          !_showCatalogProducts;
                                    });
                                  },
                                ),
                                if (_showCatalogProducts) ...[
                                  const SizedBox(height: 14),
                                  _CatalogDropdownTable(
                                    productsByCategory: productsByCategory,
                                  ),
                                ],
                                const SizedBox(height: 22),
                                const Text(
                                  'Thống kê món được đặt',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF1F2937),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Bấm vào từng danh mục để xem sản phẩm bên trong',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                if (productsByCategory.isEmpty)
                                  const _EmptyState()
                                else
                                  ...productsByCategory.entries.map(
                                    (entry) => _CategoryProductGroup(
                                      categoryName: entry.key,
                                      products: entry.value,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
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
    final isSmall = MediaQuery.sizeOf(context).width < 380;

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

class _DateRangeLabel extends StatelessWidget {
  final String startDate;
  final String endDate;

  const _DateRangeLabel({required this.startDate, required this.endDate});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.date_range_rounded,
            size: 18,
            color: Color(0xFF2563EB),
          ),
          const SizedBox(width: 7),
          Flexible(
            child: Text(
              '$startDate - $endDate',
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF1E40AF),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterSection extends StatelessWidget {
  final RevenueFilterType selectedFilter;
  final Future<void> Function(RevenueFilterType type) onSelect;

  const _FilterSection({required this.selectedFilter, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _FilterChipItem(
            label: 'Hôm nay',
            icon: Icons.today_rounded,
            type: RevenueFilterType.today,
            selectedFilter: selectedFilter,
            onSelect: onSelect,
          ),
          _FilterChipItem(
            label: 'Tuần này',
            icon: Icons.calendar_view_week_rounded,
            type: RevenueFilterType.week,
            selectedFilter: selectedFilter,
            onSelect: onSelect,
          ),
          _FilterChipItem(
            label: 'Tháng này',
            icon: Icons.calendar_month_rounded,
            type: RevenueFilterType.month,
            selectedFilter: selectedFilter,
            onSelect: onSelect,
          ),
          _FilterChipItem(
            label: 'Tùy chọn',
            icon: Icons.tune_rounded,
            type: RevenueFilterType.custom,
            selectedFilter: selectedFilter,
            onSelect: onSelect,
          ),
        ],
      ),
    );
  }
}

class _FilterChipItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final RevenueFilterType type;
  final RevenueFilterType selectedFilter;
  final Future<void> Function(RevenueFilterType type) onSelect;

  const _FilterChipItem({
    required this.label,
    required this.icon,
    required this.type,
    required this.selectedFilter,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selectedFilter == type;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        avatar: Icon(
          icon,
          size: 18,
          color: isSelected ? Colors.white : const Color(0xFF64748B),
        ),
        label: Text(label),
        selected: isSelected,
        selectedColor: const Color(0xFF22C55E),
        backgroundColor: Colors.white,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : const Color(0xFF334155),
          fontWeight: FontWeight.w800,
        ),
        side: BorderSide(
          color: isSelected ? const Color(0xFF22C55E) : const Color(0xFFE2E8F0),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)),
        onSelected: (_) => onSelect(type),
      ),
    );
  }
}

class _RevenueSummaryCard extends StatelessWidget {
  final String totalRevenue;
  final int completedOrders;
  final int soldItems;
  final int categoryCount;
  final bool showCatalogProducts;
  final VoidCallback onCatalogTap;

  const _RevenueSummaryCard({
    required this.totalRevenue,
    required this.completedOrders,
    required this.soldItems,
    required this.categoryCount,
    required this.showCatalogProducts,
    required this.onCatalogTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE0F2FE), Color(0xFFDCFCE7)],
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.045),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tổng doanh thu',
            style: TextStyle(
              color: Color(0xFF475569),
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              totalRevenue,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 33,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final itemWidth = (constraints.maxWidth - 20) / 3;

              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  SizedBox(
                    width: itemWidth,
                    child: _MiniSummary(
                      title: 'Đơn thành công',
                      value: completedOrders.toString(),
                      icon: Icons.receipt_long_rounded,
                      backgroundColor: const Color(0xFFFFF7ED),
                      iconColor: const Color(0xFFF97316),
                      onTap: null,
                    ),
                  ),
                  SizedBox(
                    width: itemWidth,
                    child: _MiniSummary(
                      title: 'Món đã bán',
                      value: soldItems.toString(),
                      icon: Icons.fastfood_rounded,
                      backgroundColor: const Color(0xFFF0FDF4),
                      iconColor: const Color(0xFF22C55E),
                      onTap: null,
                    ),
                  ),
                  SizedBox(
                    width: itemWidth,
                    child: _MiniSummary(
                      title: 'Danh mục',
                      value: categoryCount.toString(),
                      icon:
                          showCatalogProducts
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.category_rounded,
                      backgroundColor: const Color(0xFFF5F3FF),
                      iconColor: const Color(0xFF7C3AED),
                      onTap: onCatalogTap,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _MiniSummary extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final VoidCallback? onTap;

  const _MiniSummary({
    required this.title,
    required this.value,
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: const EdgeInsets.fromLTRB(9, 12, 9, 10),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 23),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );

    if (onTap == null) return content;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: content,
      ),
    );
  }
}

class _CatalogDropdownTable extends StatelessWidget {
  final Map<String, Map<String, int>> productsByCategory;

  const _CatalogDropdownTable({required this.productsByCategory});

  @override
  Widget build(BuildContext context) {
    if (productsByCategory.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: _whiteCardDecoration(),
        child: const Text(
          'Chưa có sản phẩm nào trong khoảng thời gian này.',
          style: TextStyle(
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _whiteCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Danh sách sản phẩm theo catalog',
            style: TextStyle(
              fontSize: 15.5,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 10),
          ...productsByCategory.entries.map((entry) {
            final total = entry.value.values.fold<int>(0, (sum, q) => sum + q);

            return ExpansionTile(
              tilePadding: EdgeInsets.zero,
              childrenPadding: const EdgeInsets.only(bottom: 8),
              leading: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F3FF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.folder_rounded,
                  color: Color(0xFF7C3AED),
                  size: 22,
                ),
              ),
              title: Text(
                entry.key,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1F2937),
                ),
              ),
              subtitle: Text(
                '$total lượt bán',
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                  fontSize: 12.5,
                ),
              ),
              children:
                  entry.value.entries.map((product) {
                    return _ProductStatItem(
                      name: product.key,
                      quantity: product.value,
                    );
                  }).toList(),
            );
          }),
        ],
      ),
    );
  }
}

class _CategoryProductGroup extends StatelessWidget {
  final String categoryName;
  final Map<String, int> products;

  const _CategoryProductGroup({
    required this.categoryName,
    required this.products,
  });

  @override
  Widget build(BuildContext context) {
    final totalQuantity = products.values.fold<int>(0, (sum, q) => sum + q);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: _whiteCardDecoration(),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
        childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFFFFF7ED),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.category_rounded, color: Color(0xFFF97316)),
        ),
        title: Text(
          categoryName,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: Color(0xFF1F2937),
          ),
        ),
        subtitle: Text(
          '$totalQuantity lượt bán',
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w600,
          ),
        ),
        children:
            products.entries.map((entry) {
              return _ProductStatItem(name: entry.key, quantity: entry.value);
            }).toList(),
      ),
    );
  }
}

class _ProductStatItem extends StatelessWidget {
  final String name;
  final int quantity;

  const _ProductStatItem({required this.name, required this.quantity});

  @override
  Widget build(BuildContext context) {
    final safeQuantity = quantity <= 0 ? 1 : quantity;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.local_fire_department_rounded,
            color: Color(0xFFF97316),
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 14.5,
                color: Color(0xFF1F2937),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFDCFCE7),
              borderRadius: BorderRadius.circular(99),
            ),
            child: Text(
              '$safeQuantity lượt',
              style: const TextStyle(
                color: Color(0xFF15803D),
                fontWeight: FontWeight.w900,
                fontSize: 12.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: _whiteCardDecoration(),
      child: Column(
        children: [
          Icon(Icons.insights_rounded, size: 42, color: Colors.grey.shade400),
          const SizedBox(height: 10),
          const Text(
            'Chưa có dữ liệu doanh thu',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Dữ liệu sẽ hiển thị khi có đơn hàng hoàn thành trong khoảng thời gian đã chọn.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

BoxDecoration _whiteCardDecoration() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(22),
    border: Border.all(color: const Color(0xFFE2E8F0)),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.035),
        blurRadius: 12,
        offset: const Offset(0, 5),
      ),
    ],
  );
}
