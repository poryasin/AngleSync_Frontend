import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/router/app_router.dart';
import '../../../core/widgets/app_bottom_nav_bar.dart';
import '../../navigation/presentation/home_screen.dart';
import '../../history/presentation/history_screen.dart';

class MainShell extends StatefulWidget {
  final int initialIndex;
  const MainShell({super.key , this.initialIndex = 0});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedNavIndex = 0;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _selectedNavIndex = widget.initialIndex;
    _pages = [
      HomeScreen(onViewAllHistory: () => setState(() => _selectedNavIndex = 2)),
      const HistoryScreen(),
    ];
  }

  int get _pageIndex => _selectedNavIndex == 2 ? 1 : 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
      Offstage(
      offstage: _pageIndex != 0,
      child: _pages[0],
    ),
      Offstage(
      offstage: _pageIndex != 1,
      child: _pages[1],
    ),
  ],
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _selectedNavIndex,
        onTap: (index) {
          if (index == 1) {
            Navigator.pushNamed(context, AppRouter.scan).then((result) {
              setState(() {
    if (result == 2) _selectedNavIndex = 2;
  });
});
            return;
          }
          setState(() => _selectedNavIndex = index);
        },
      ),
    );
  }
}