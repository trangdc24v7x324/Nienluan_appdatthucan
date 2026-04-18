import 'package:flutter/material.dart';
import 'package:ct484tx_project_trangdc24v7x324/models/address_model.dart';
import 'section_card.dart';

class AddressSection extends StatefulWidget {
  final List<AddressModel> addresses;
  final bool isEditing;
  final VoidCallback onEdit;
  final Function(List<AddressModel>) onSave;

  const AddressSection({
    super.key,
    required this.addresses,
    required this.isEditing,
    required this.onEdit,
    required this.onSave,
  });

  @override
  State<AddressSection> createState() => _AddressSectionState();
}

class _AddressSectionState extends State<AddressSection> {
  late List<AddressModel> _localAddresses;

  @override
  void initState() {
    super.initState();
    _localAddresses = _copyAddresses(widget.addresses);
  }

  @override
  void didUpdateWidget(covariant AddressSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.isEditing) {
      _localAddresses = _copyAddresses(widget.addresses);
    }
  }

  List<AddressModel> _copyAddresses(List<AddressModel> addresses) {
    return addresses
        .map(
          (a) => AddressModel(
            id: a.id,
            receiverName: a.receiverName,
            phoneNumber: a.phoneNumber,
            fullAddress: a.fullAddress,
            isDefault: a.isDefault,
          ),
        )
        .toList();
  }

  void _addNewAddress() {
    setState(() {
      _localAddresses.add(
        AddressModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          receiverName: '',
          phoneNumber: '',
          fullAddress: '',
          isDefault: _localAddresses.isEmpty,
        ),
      );
    });
  }

  void _removeAddress(int index) {
    setState(() {
      final wasDefault = _localAddresses[index].isDefault;
      _localAddresses.removeAt(index);

      if (wasDefault && _localAddresses.isNotEmpty) {
        _localAddresses[0] = AddressModel(
          id: _localAddresses[0].id,
          receiverName: _localAddresses[0].receiverName,
          phoneNumber: _localAddresses[0].phoneNumber,
          fullAddress: _localAddresses[0].fullAddress,
          isDefault: true,
        );
      }
    });
  }

  void _setDefaultAddress(int index) {
    setState(() {
      _localAddresses =
          _localAddresses.asMap().entries.map((entry) {
            final i = entry.key;
            final a = entry.value;
            return AddressModel(
              id: a.id,
              receiverName: a.receiverName,
              phoneNumber: a.phoneNumber,
              fullAddress: a.fullAddress,
              isDefault: i == index,
            );
          }).toList();
    });
  }

  Widget _buildViewItem(AddressModel address) {
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
  }

  Widget _buildEditItem(int index) {
    final address = _localAddresses[index];

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xfff7f7f7),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Text(
                'Địa chỉ',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => _removeAddress(index),
                icon: const Icon(Icons.delete_outline, color: Colors.red),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: address.receiverName,
            decoration: const InputDecoration(
              labelText: 'Tên người nhận',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              _localAddresses[index] = AddressModel(
                id: address.id,
                receiverName: value,
                phoneNumber: _localAddresses[index].phoneNumber,
                fullAddress: _localAddresses[index].fullAddress,
                isDefault: _localAddresses[index].isDefault,
              );
            },
          ),
          const SizedBox(height: 10),
          TextFormField(
            initialValue: address.phoneNumber,
            decoration: const InputDecoration(
              labelText: 'Số điện thoại',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.phone,
            onChanged: (value) {
              _localAddresses[index] = AddressModel(
                id: address.id,
                receiverName: _localAddresses[index].receiverName,
                phoneNumber: value,
                fullAddress: _localAddresses[index].fullAddress,
                isDefault: _localAddresses[index].isDefault,
              );
            },
          ),
          const SizedBox(height: 10),
          TextFormField(
            initialValue: address.fullAddress,
            decoration: const InputDecoration(
              labelText: 'Địa chỉ đầy đủ',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
            onChanged: (value) {
              _localAddresses[index] = AddressModel(
                id: address.id,
                receiverName: _localAddresses[index].receiverName,
                phoneNumber: _localAddresses[index].phoneNumber,
                fullAddress: value,
                isDefault: _localAddresses[index].isDefault,
              );
            },
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Checkbox(
                value: address.isDefault,
                onChanged: (value) {
                  if (value == true) {
                    _setDefaultAddress(index);
                  }
                },
              ),
              const Text('Đặt làm địa chỉ mặc định'),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Địa chỉ giao hàng',
      action: IconButton(
        onPressed: () {
          if (widget.isEditing) {
            widget.onSave(_localAddresses);
          } else {
            widget.onEdit();
          }
        },
        icon: Icon(
          widget.isEditing ? Icons.check : Icons.edit_outlined,
          color: const Color(0xFF8E1F16),
        ),
      ),
      child: Column(
        children: [
          ..._localAddresses.asMap().entries.map((entry) {
            final index = entry.key;
            final address = entry.value;
            return widget.isEditing
                ? _buildEditItem(index)
                : _buildViewItem(address);
          }),
          if (widget.isEditing)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _addNewAddress,
                icon: const Icon(Icons.add),
                label: const Text('Thêm địa chỉ'),
              ),
            ),
        ],
      ),
    );
  }
}
