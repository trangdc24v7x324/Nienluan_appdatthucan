import 'package:ct484tx_project_trangdc24v7x324/features/profile/widgets/account_info_section.dart';
import 'package:ct484tx_project_trangdc24v7x324/features/profile/widgets/address_section.dart';
import 'package:ct484tx_project_trangdc24v7x324/features/profile/widgets/general_info_section.dart';
import 'package:ct484tx_project_trangdc24v7x324/features/profile/widgets/payment_methods_section.dart';
import 'package:ct484tx_project_trangdc24v7x324/features/profile/widgets/profile_header.dart';
import 'package:ct484tx_project_trangdc24v7x324/providers/order_provider.dart';
import 'package:ct484tx_project_trangdc24v7x324/providers/profile_provider.dart';
import 'package:ct484tx_project_trangdc24v7x324/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<ProfileProvider>().loadProfile(forceReload: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff8e1f16),
      body: Consumer<ProfileProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.profile == null) {
            return Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.login,
                    (route) => false,
                  );
                },
                child: const Text('Đăng nhập lại'),
              ),
            );
          }

          final profile = provider.profile!;
          context.watch<OrderProvider>().orders.take(3).toList();

          return SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: 28),
                    padding: const EdgeInsets.fromLTRB(16, 54, 16, 20),
                    decoration: const BoxDecoration(
                      color: Color(0xfff7f7f7),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(32),
                      ),
                    ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned(
                          top: -110,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: ProfileHeader(
                              name: profile.fullName,
                              email: profile.email,
                              avatarUrl: profile.avatarUrl,
                            ),
                          ),
                        ),
                        ListView(
                          children: [
                            const SizedBox(height: 30),

                            GeneralInfoSection(
                              profile: profile,
                              isEditing: provider.isEditingGeneralInfo,
                              onEdit: provider.toggleGeneralInfoEdit,
                              onSave: ({
                                required fullName,
                                required email,
                                required phoneNumber,
                                required gender,
                                required dateOfBirth,
                              }) {
                                provider.updateGeneralInfo(
                                  fullName: fullName,
                                  email: email,
                                  phoneNumber: phoneNumber,
                                  gender: gender,
                                  dateOfBirth: dateOfBirth,
                                );
                              },
                            ),

                            AccountInfoSection(
                              profile: profile,
                              onChangePassword: () {
                                _showChangePasswordDialog(context);
                              },
                            ),

                            AddressSection(
                              addresses: profile.addresses,
                              isEditing: provider.isEditingAddress,
                              onEdit: provider.toggleAddressEdit,
                              onSave: (updatedAddresses) async {
                                await provider.updateAddresses(
                                  updatedAddresses,
                                );
                              },
                            ),

                            PaymentMethodsSection(
                              methods: profile.paymentMethods,
                              isEditing: provider.isEditingPaymentMethods,
                              onEdit: provider.togglePaymentMethodsEdit,
                              onSave: (updatedMethods) async {
                                await provider.updatePaymentMethods(
                                  updatedMethods,
                                );
                              },
                            ),

                            GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(context, AppRoutes.orders);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                margin: const EdgeInsets.only(top: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                                child: const Row(
                                  children: [
                                    Icon(
                                      Icons.receipt_long_outlined,
                                      color: Color(0xFFEF2A39),
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'Lịch sử mua hàng',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    Icon(Icons.chevron_right),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 12),

                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: () async {
                                  final shouldLogout = await showDialog<bool>(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        title: Row(
                                          children: const [
                                            Icon(
                                              Icons.warning,
                                              color: Colors.red,
                                            ),
                                            SizedBox(width: 8),
                                            Text('Xác nhận'),
                                          ],
                                        ),
                                        content: const Text(
                                          'Bạn có chắc chắn muốn đăng xuất không?',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed:
                                                () => Navigator.pop(
                                                  context,
                                                  false,
                                                ),
                                            child: const Text('Hủy'),
                                          ),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                            ),
                                            onPressed:
                                                () => Navigator.pop(
                                                  context,
                                                  true,
                                                ),
                                            child: const Text('Đăng xuất'),
                                          ),
                                        ],
                                      );
                                    },
                                  );

                                  if (shouldLogout == true) {
                                    provider.logout(context);
                                  }
                                },
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                    color: Color(0xFF8E1F16),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                ),
                                child: const Text(
                                  'Đăng xuất',
                                  style: TextStyle(
                                    color: Color(0xFF8E1F16),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 12),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Consumer<ProfileProvider>(
          builder: (context, provider, _) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text('Đổi mật khẩu'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: oldPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Mật khẩu cũ'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: newPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Mật khẩu mới',
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: confirmPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Xác nhận mật khẩu',
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed:
                      provider.isChangingPassword
                          ? null
                          : () => Navigator.pop(context),
                  child: const Text('Hủy'),
                ),
                ElevatedButton(
                  onPressed:
                      provider.isChangingPassword
                          ? null
                          : () async {
                            final oldPass = oldPasswordController.text.trim();
                            final newPass = newPasswordController.text.trim();
                            final confirmPass =
                                confirmPasswordController.text.trim();

                            // ✅ Validate đầy đủ
                            if (oldPass.isEmpty ||
                                newPass.isEmpty ||
                                confirmPass.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Vui lòng nhập đầy đủ thông tin',
                                  ),
                                ),
                              );
                              return;
                            }

                            if (newPass.length < 6) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Mật khẩu mới phải ít nhất 6 ký tự',
                                  ),
                                ),
                              );
                              return;
                            }

                            if (newPass != confirmPass) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Mật khẩu xác nhận không khớp'),
                                ),
                              );
                              return;
                            }

                            try {
                              await context
                                  .read<ProfileProvider>()
                                  .changePassword(
                                    oldPassword: oldPass,
                                    newPassword: newPass,
                                  );

                              Navigator.pop(context);

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Đổi mật khẩu thành công'),
                                ),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(e.toString())),
                              );
                            }
                          },
                  child:
                      provider.isChangingPassword
                          ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                          : const Text('Lưu'),
                ),
              ],
            );
          },
        );
      },
    ).then((_) {
      oldPasswordController.dispose();
      newPasswordController.dispose();
      confirmPasswordController.dispose();
    });
  }
}
