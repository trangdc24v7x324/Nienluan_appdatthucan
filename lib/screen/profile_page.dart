import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ct484tx_project_trangdc24v7x324/providers/profile_provider.dart';
import 'package:ct484tx_project_trangdc24v7x324/widgets/profile/account_info_section.dart';
import 'package:ct484tx_project_trangdc24v7x324/widgets/profile/address_section.dart';
import 'package:ct484tx_project_trangdc24v7x324/widgets/profile/general_info_section.dart';
import 'package:ct484tx_project_trangdc24v7x324/widgets/profile/payment_methods_section.dart';
import 'package:ct484tx_project_trangdc24v7x324/widgets/profile/profile_header.dart';
import 'package:ct484tx_project_trangdc24v7x324/providers/order_provider.dart';
import 'package:ct484tx_project_trangdc24v7x324/routes/app_routes.dart';

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
      context.read<ProfileProvider>().loadProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff8e1f16),
      body: Consumer<ProfileProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading || provider.profile == null) {
            return const Center(child: CircularProgressIndicator());
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
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Chức năng đổi mật khẩu sẽ làm sau',
                                    ),
                                  ),
                                );
                              },
                            ),

                            AddressSection(
                              addresses: profile.addresses,
                              isEditing: provider.isEditingAddress,
                              onEdit: provider.toggleAddressEdit,
                              onSave: (updatedAddresses) {
                                // tạm thời update local (chưa backend)
                                provider.updateAddresses(updatedAddresses);
                              },
                            ),

                            PaymentMethodsSection(
                              methods: profile.paymentMethods,
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
                                onPressed: () {
                                  provider.logout(context);
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
}
