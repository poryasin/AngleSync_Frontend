import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEEEEEE), width: 1)),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: CupertinoIcons.house_fill,
                outlineIcon: CupertinoIcons.house,
                label: 'Home',
                selected: currentIndex == 0,
                onTap: () => onTap?.call(0),
              ),
              _NavItem(
                icon: CupertinoIcons.viewfinder,
                outlineIcon: CupertinoIcons.viewfinder,
                label: 'Scan',
                selected: currentIndex == 1,
                onTap: () => onTap?.call(1),
              ),
              _NavItem(
                icon: CupertinoIcons.clock_fill,
                outlineIcon: CupertinoIcons.clock,
                label: 'History',
                selected: currentIndex == 2,
                onTap: () => onTap?.call(2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData outlineIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.outlineIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 80,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              selected ? icon : outlineIcon,
              color: selected ? AppTheme.green : AppTheme.textGrey,
              size: 22,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: selected ? AppTheme.green : AppTheme.textGrey,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}