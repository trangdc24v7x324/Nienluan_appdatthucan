import 'package:flutter/material.dart';

import 'package:ct484tx_project_trangdc24v7x324/features/product/screens/cart_page.dart';
import 'package:ct484tx_project_trangdc24v7x324/features/product/screens/favourite_page.dart';
import 'package:ct484tx_project_trangdc24v7x324/features/product/screens/home_page.dart';
import 'package:ct484tx_project_trangdc24v7x324/features/product/screens/orders_page.dart';
import 'package:ct484tx_project_trangdc24v7x324/features/product/screens/product_page.dart';
import 'package:ct484tx_project_trangdc24v7x324/features/profile/screens/profile_page.dart';
import 'package:ct484tx_project_trangdc24v7x324/features/auth/screens/splash_screen.dart';
import 'package:ct484tx_project_trangdc24v7x324/features/notification/notification_page.dart';
import 'package:ct484tx_project_trangdc24v7x324/features/product/screens/payment_page.dart';
import 'package:ct484tx_project_trangdc24v7x324/features/auth/screens/login_page.dart';
import 'package:ct484tx_project_trangdc24v7x324/features/auth/screens/register_page.dart';

import 'package:ct484tx_project_trangdc24v7x324/features/manager/screens/manager_home_page.dart';
import 'package:ct484tx_project_trangdc24v7x324/features/manager/screens/manager_orders_page.dart';
import 'package:ct484tx_project_trangdc24v7x324/features/manager/screens/manager_revenue_page.dart';
import 'package:ct484tx_project_trangdc24v7x324/features/manager/screens/manager_categories_page.dart';
import 'package:ct484tx_project_trangdc24v7x324/features/chat/screens/manager_chat_list_page.dart';
import 'package:ct484tx_project_trangdc24v7x324/features/notification/manager_notifications_page.dart';

class AppRoutes {
  static const String splash = '/';
  static const String home = '/home';
  static const String product = '/product';
  static const String profile = '/profile';
  static const String favourite = '/favourite';
  static const String cart = '/cart';
  static const String orders = '/orders';
  static const String notifications = '/notifications';
  static const String payment = '/payment';
  static const String login = '/login';
  static const String register = '/register';

  static const String managerHome = '/manager-home';
  static const String managerOrders = '/manager-orders';
  static const String managerRevenue = '/manager-revenue';
  static const String managerCategories = '/manager-categories';
  static const String managerChat = '/manager-chat';
  static const String managerNotifications = '/manager-notifications';

  static Map<String, WidgetBuilder> get routes => {
    splash: (context) => const SplashScreen(),
    login: (context) => const LoginPage(),
    register: (context) => const RegisterPage(),

    home: (context) => const HomePage(),
    product: (context) => const ProductPage(),
    profile: (context) => const ProfilePage(),
    favourite: (context) => const FavouritePage(),
    cart: (context) => const CartPage(),
    orders: (context) => const OrdersPage(),
    notifications: (context) => const NotificationsPage(),
    payment: (context) => const PaymentPage(),

    managerHome: (context) => const ManagerHomePage(),
    managerOrders: (context) => const ManagerOrdersPage(),
    managerRevenue: (context) => const ManagerRevenuePage(),
    managerCategories: (context) => const ManagerCategoriesPage(),
    managerChat: (context) => const ManagerChatListPage(),
    managerNotifications: (context) => const ManagerNotificationsPage(),
  };
}
