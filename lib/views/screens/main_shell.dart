import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import '../../controllers/product_controller.dart';
import 'home_page.dart';
import 'profile_page.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    Get.put(ProductController());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          HomePage(),
          ProfilePage(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              color: Colors.black.withValues(alpha: 0.08),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 20.w,
              vertical: 12.h,
            ),
            child: GNav(
              rippleColor: const Color(0xFF1A5F7A).withValues(alpha: 0.2),
              hoverColor: const Color(0xFF1A5F7A).withValues(alpha: 0.1),
              gap: 8,
              activeColor: Colors.white,
              iconSize: 24.sp,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              duration: const Duration(milliseconds: 300),
              tabBackgroundColor: const Color(0xFF1A5F7A),
              color: Colors.grey.shade600,
              tabs: const [
                GButton(icon: Icons.home_rounded, text: 'Accueil'),
                GButton(icon: Icons.person_rounded, text: 'Profil'),
              ],
              selectedIndex: _currentIndex,
              onTabChange: (index) => setState(() => _currentIndex = index),
            ),
          ),
        ),
      ),
    );
  }
}
