import 'package:flutter/material.dart';
import 'package:ct484tx_project_trangdc24v7x324/models/user_profile_model.dart';
import 'section_card.dart';

class GeneralInfoSection extends StatelessWidget {
  final UserProfileModel profile;

  const GeneralInfoSection({super.key, required this.profile});

  String _formatDate(DateTime? date) {
    if (date == null) return 'Chưa cập nhật';
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _item(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Thông tin chung',
      child: Column(
        children: [
          _item('Họ và tên', profile.fullName),
          _item('Ngày sinh', _formatDate(profile.dateOfBirth)),
          _item('Giới tính', profile.gender),
          _item('Email', profile.email),
          _item('Số điện thoại', profile.phoneNumber),
        ],
      ),
    );
  }
}
