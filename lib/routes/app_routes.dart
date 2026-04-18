import 'package:flutter/material.dart';
import 'package:ct484tx_project_trangdc24v7x324/screen/cart_page.dart';
import 'package:ct484tx_project_trangdc24v7x324/screen/favourite_page.dart';
import 'package:ct484tx_project_trangdc24v7x324/screen/home_page.dart';
import 'package:ct484tx_project_trangdc24v7x324/screen/orders_page.dart';
import 'package:ct484tx_project_trangdc24v7x324/screen/product_page.dart';
import 'package:ct484tx_project_trangdc24v7x324/screen/profile_page.dart';
import 'package:ct484tx_project_trangdc24v7x324/screen/splash_screen.dart';
import 'package:ct484tx_project_trangdc24v7x324/screen/notifications_page.dart';
import 'package:ct484tx_project_trangdc24v7x324/screen/chat_page.dart';
import 'package:ct484tx_project_trangdc24v7x324/screen/payment_page.dart';

class AppRoutes {
  static const String splash = '/';
  static const String home = '/home';
  static const String product = '/product';
  static const String profile = '/profile';
  static const String favourite = '/favourite';
  static const String cart = '/cart';
  static const String orders = '/orders';
  static const String notifications = '/notifications';
  static const chat = '/chat';
  static const String payment = '/payment';

  static Map<String, WidgetBuilder> get routes => {
    splash: (context) => const SplashScreen(),
    home: (context) => const HomePage(),
    product: (context) => const ProductPage(),
    profile: (context) => const ProfilePage(),
    favourite: (context) => const FavouritePage(),
    cart: (context) => const CartPage(),
    orders: (context) => const OrdersPage(),
    notifications: (context) => const NotificationsPage(),
    chat: (_) => const ChatPage(),
    payment: (context) => const PaymentPage(),
  };
}
