import 'package:flutter/material.dart';
import 'package:CT466_project_trangdc24v7x324/models/address_model.dart';
import '../../../shared/widgets/section_card.dart';

class AddressSection extends StatefulWidget {
  final List<AddressModel> addresses;
  final bool isEditing;
  final VoidCallback onEdit;
  final Future<void> Function(List<AddressModel> updatedAddresses) onSave;

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
  bool _isSaving = false;

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
    return addresses.map((address) => address.copyWith()).toList();
  }

  void _addNewAddress() {
    setState(() {
      _localAddresses.add(
        AddressModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: '',
          receiverName: '',
          phoneNumber: '',
          addressLine: '',
          note: '',
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
        _localAddresses[0] = _localAddresses[0].copyWith(isDefault: true);
      }
    });
  }

  void _setDefaultAddress(int index) {
    setState(() {
      _localAddresses =
          _localAddresses.asMap().entries.map((entry) {
            return entry.value.copyWith(isDefault: entry.key == index);
          }).toList();
    });
  }

  Future<void> _saveAddresses() async {
    if (_isSaving) return;

    final validAddresses =
        _localAddresses.where((address) {
          return address.receiverName.trim().isNotEmpty &&
              address.phoneNumber.trim().isNotEmpty &&
              address.addressLine.trim().isNotEmpty;
        }).toList();

    if (validAddresses.length != _localAddresses.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập đầy đủ tên, số điện thoại và địa chỉ.'),
        ),
      );
      return;
    }

    final hasDefault = validAddresses.any((address) => address.isDefault);
    final normalizedAddresses =
        validAddresses.asMap().entries.map((entry) {
          final index = entry.key;
          final address = entry.value;
          return address.copyWith(
            isDefault: hasDefault ? address.isDefault : index == 0,
          );
        }).toList();

    setState(() => _isSaving = true);

    try {
      await widget.onSave(normalizedAddresses);
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
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
              Expanded(
                child: Text(
                  address.receiverName.isEmpty
                      ? 'Chưa có tên người nhận'
                      : address.receiverName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
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
          Text(
            address.phoneNumber.isEmpty
                ? 'Chưa có số điện thoại'
                : address.phoneNumber,
          ),
          const SizedBox(height: 4),
          Text(
            address.addressLine.isEmpty
                ? 'Chưa có địa chỉ giao hàng'
                : address.addressLine,
          ),
          if (address.note.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Ghi chú: ${address.note}',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEditItem(int index) {
    final address = _localAddresses[index];

    return Container(
      key: ValueKey(address.id),
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
                onPressed: _isSaving ? null : () => _removeAddress(index),
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
              _localAddresses[index] = _localAddresses[index].copyWith(
                receiverName: value,
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
              _localAddresses[index] = _localAddresses[index].copyWith(
                phoneNumber: value,
              );
            },
          ),
          const SizedBox(height: 10),
          TextFormField(
            initialValue: address.addressLine,
            decoration: const InputDecoration(
              labelText: 'Địa chỉ đầy đủ',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
            onChanged: (value) {
              _localAddresses[index] = _localAddresses[index].copyWith(
                addressLine: value,
              );
            },
          ),
          const SizedBox(height: 10),
          TextFormField(
            initialValue: address.note,
            decoration: const InputDecoration(
              labelText: 'Ghi chú',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
            onChanged: (value) {
              _localAddresses[index] = _localAddresses[index].copyWith(
                note: value,
              );
            },
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Checkbox(
                value: address.isDefault,
                onChanged:
                    _isSaving
                        ? null
                        : (value) {
                          if (value == true) {
                            _setDefaultAddress(index);
                          }
                        },
              ),
              const Expanded(child: Text('Đặt làm địa chỉ mặc định')),
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
        onPressed:
            _isSaving
                ? null
                : () {
                  if (widget.isEditing) {
                    _saveAddresses();
                  } else {
                    widget.onEdit();
                  }
                },
        icon:
            _isSaving
                ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                : Icon(
                  widget.isEditing ? Icons.check : Icons.edit_outlined,
                  color: const Color(0xFF8E1F16),
                ),
      ),
      child: Column(
        children: [
          if (_localAddresses.isEmpty && !widget.isEditing)
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Chưa có địa chỉ giao hàng',
                style: TextStyle(color: Colors.grey),
              ),
            ),
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
                onPressed: _isSaving ? null : _addNewAddress,
                icon: const Icon(Icons.add),
                label: const Text('Thêm địa chỉ'),
              ),
            ),
        ],
      ),
    );
  }
}
