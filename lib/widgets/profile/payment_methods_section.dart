import 'package:flutter/material.dart';
import 'package:ct484tx_project_trangdc24v7x324/models/payment_method_model.dart';
import 'section_card.dart';

class PaymentMethodsSection extends StatelessWidget {
  final List<PaymentMethodModel> methods;

  const PaymentMethodsSection({super.key, required this.methods});

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
      child: Column(
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
                    method.isDefault
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
