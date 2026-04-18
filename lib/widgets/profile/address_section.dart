import 'package:flutter/material.dart';
import 'package:ct484tx_project_trangdc24v7x324/models/address_model.dart';
import 'section_card.dart';

class AddressSection extends StatelessWidget {
  final List<AddressModel> addresses;

  const AddressSection({super.key, required this.addresses});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Địa chỉ giao hàng',
      child: Column(
        children: addresses.map((address) {
          return Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xfff7f7f7),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      address.receiverName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    if (address.isDefault)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Mặc định',
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(address.phoneNumber),
                const SizedBox(height: 4),
                Text(address.fullAddress),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
