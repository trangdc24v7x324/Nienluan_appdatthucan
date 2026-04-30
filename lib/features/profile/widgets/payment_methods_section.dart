import 'package:ct484tx_project_trangdc24v7x324/models/payment_method_model.dart';
import 'package:flutter/material.dart';

import '../../../shared/widgets/section_card.dart';

class PaymentMethodsSection extends StatelessWidget {
  final List<PaymentMethodModel> methods;
  final bool isEditing;
  final VoidCallback onEdit;
  final Future<void> Function(List<PaymentMethodModel> updatedMethods) onSave;

  const PaymentMethodsSection({
    super.key,
    required this.methods,
    required this.isEditing,
    required this.onEdit,
    required this.onSave,
  });

  IconData _getIcon(String type) {
    switch (type) {
      case 'cash':
        return Icons.payments_outlined;
      case 'momo':
        return Icons.account_balance_wallet_outlined;
      case 'visa':
        return Icons.credit_card;
      default:
        return Icons.payment;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Phương thức thanh toán',
      action: IconButton(
        onPressed: onEdit,
        icon: Icon(
          isEditing ? Icons.check : Icons.edit_outlined,
          color: const Color(0xFFEF2A39),
        ),
      ),
      child:
          methods.isEmpty
              ? const Text(
                'Chưa có phương thức thanh toán',
                style: TextStyle(color: Colors.grey),
              )
              : Column(
                children:
                    methods.map((method) {
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(_getIcon(method.type)),
                        title: Text(
                          method.title,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(method.subtitle),
                        trailing:
                            isEditing
                                ? Radio<String>(
                                  value: method.id,
                                  groupValue:
                                      methods
                                          .firstWhere(
                                            (m) => m.isDefault,
                                            orElse: () => methods.first,
                                          )
                                          .id,
                                  onChanged: (_) async {
                                    final updatedMethods =
                                        methods.map((m) {
                                          return m.copyWith(
                                            isDefault: m.id == method.id,
                                          );
                                        }).toList();

                                    await onSave(updatedMethods);
                                  },
                                )
                                : method.isDefault
                                ? const Text(
                                  'Mặc định',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.w600,
                                  ),
                                )
                                : null,
                      );
                    }).toList(),
              ),
    );
  }
}
