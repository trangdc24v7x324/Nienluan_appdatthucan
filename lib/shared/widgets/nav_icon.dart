import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NavIcon extends StatelessWidget {
  final int index;
  final int selectedIndex;
  final ValueChanged<int> onTap;
  final int badgeCount;
  const NavIcon({
    super.key,
    required this.index,
    required this.selectedIndex,
    required this.onTap,
    this.badgeCount = 0,
  });
  @override
  Widget build(BuildContext context) {
    IconData icon;
    switch (index) {
      case 0:
        icon = CupertinoIcons.home;
        break;
      case 1:
        icon =
            selectedIndex == 1 ? CupertinoIcons.cart_fill : CupertinoIcons.cart;
        break;
      case 2:
        icon =
            selectedIndex == 2
                ? CupertinoIcons.chat_bubble_fill
                : CupertinoIcons.chat_bubble;
        break;
      case 3:
        icon =
            selectedIndex == 3 ? CupertinoIcons.bell_fill : CupertinoIcons.bell;
        break;
      default:
        icon = CupertinoIcons.circle;
    }
    final iconWidget = Icon(
      icon,
      color: selectedIndex == index ? Colors.white : Colors.white70,
      size: 28,
    );
    return InkWell(
      onTap: () => onTap(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              iconWidget,
              if (index == 1 && badgeCount > 0)
                Positioned(
                  right: -8,
                  top: -8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      badgeCount > 99 ? '99+' : '$badgeCount',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFFEF2A39),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          if (selectedIndex == index)
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}
