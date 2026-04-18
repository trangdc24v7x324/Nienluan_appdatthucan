import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ct484tx_project_trangdc24v7x324/providers/profile_provider.dart';
import 'package:ct484tx_project_trangdc24v7x324/widgets/profile/account_info_section.dart';
import 'package:ct484tx_project_trangdc24v7x324/widgets/profile/address_section.dart';
import 'package:ct484tx_project_trangdc24v7x324/widgets/profile/general_info_section.dart';
import 'package:ct484tx_project_trangdc24v7x324/widgets/profile/order_history_section.dart';
import 'package:ct484tx_project_trangdc24v7x324/widgets/profile/payment_methods_section.dart';
import 'package:ct484tx_project_trangdc24v7x324/widgets/profile/profile_action_buttons.dart';
import 'package:ct484tx_project_trangdc24v7x324/widgets/profile/profile_header.dart';

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
                            GeneralInfoSection(profile: profile),
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
                            AddressSection(addresses: profile.addresses),
                            PaymentMethodsSection(
                              methods: profile.paymentMethods,
                            ),
                            OrderHistorySection(
                              orders: profile.orders,
                              onViewAll: () {},
                            ),
                            const SizedBox(height: 8),
                            ProfileActionButtons(
                              isEditing: provider.isEditing,
                              onEdit: provider.toggleEditMode,
                              onSave: () {
                                provider.saveProfile();
                              },
                              onLogout: () {
                                provider.logout(context);
                              },
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
