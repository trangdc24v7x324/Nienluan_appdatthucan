import 'package:ct484tx_project_trangdc24v7x324/models/address_model.dart';
import 'package:ct484tx_project_trangdc24v7x324/models/payment_method_model.dart';
import 'package:ct484tx_project_trangdc24v7x324/models/user_profile_model.dart';

class ProfileService {
  Future<UserProfileModel> fetchProfile() async {
    await Future.delayed(const Duration(milliseconds: 300));

    return UserProfileModel(
      fullName: 'Thongvy',
      dateOfBirth: DateTime(2004, 8, 20),
      gender: 'Nam',
      email: 'thongdc24v7x323@dttx.ctu.edu.vn',
      phoneNumber: '0987654321',
      username: 'thongvy',
      passwordMasked: '******',
      addresses: [
        AddressModel(
          id: 'a1',
          receiverName: 'Thongvy',
          phoneNumber: '0987654321',
          fullAddress: '132B27 Nguyễn Văn Cừ, Ninh Kiều, Cần Thơ',
          isDefault: true,
        ),
      ],
      paymentMethods: [
        PaymentMethodModel(
          id: 'p1',
          title: 'Tiền mặt',
          subtitle: 'Thanh toán khi nhận hàng',
          type: 'cash',
          isDefault: true,
        ),
        PaymentMethodModel(
          id: 'p2',
          title: 'MoMo',
          subtitle: 'Ví điện tử',
          type: 'momo',
        ),
        PaymentMethodModel(
          id: 'p3',
          title: 'Visa',
          subtitle: '**** **** **** 1234',
          type: 'visa',
        ),
      ],
    );
  }
}
