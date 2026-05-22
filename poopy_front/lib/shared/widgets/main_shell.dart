import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';

import '../../core/theme/app_theme.dart';
import '../../core/utils/app_router.dart';

class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  static const _navItems = [
    _NavItem(icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Accueil', route: AppRoutes.dashboard),
    _NavItem(icon: Icons.medication_outlined, activeIcon: Icons.medication_rounded, label: 'Méds', route: AppRoutes.medications),
    _NavItem(icon: Icons.menu_book_outlined, activeIcon: Icons.menu_book_rounded, label: 'Journal', route: AppRoutes.journal),
    _NavItem(icon: Icons.calendar_month_outlined, activeIcon: Icons.calendar_month_rounded, label: 'Rdv', route: AppRoutes.appointments),
    _NavItem(icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded, label: 'Plus', route: AppRoutes.profile),
  ];

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: Stack(
        children: [
          // Gradient background
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.bgLight, AppColors.bgLight2],
                ),
              ),
            ),
          ),
          // 2. LA BULLE ROSE DU HAUT (Celle du Splash)
          Positioned(
            top: -80, left: -60, right: -60,
            child: Container(
              height: 320,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [AppColors.pink.withOpacity(0.2), Colors.transparent],
                  radius: 0.65,
                ),
              ),
            ),
          ),

          // 3. LA BULLE VIOLETTE DU BAS (Celle du Splash)
          Positioned(
            bottom: -60, right: -80,
            child: Container(
              width: 260, height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [AppColors.poids.withOpacity(0.13), Colors.transparent],
                  radius: 0.7,
                ),
              ),
            ),
          ),
          // Content
          SafeArea(
            child: child,
          ),
          // Floating bottom nav
          Positioned(
            left: 12, right: 12, bottom: 18,
            child: _FloatingNavBar(
              navItems: _navItems,
              currentLocation: location,
            ),
          ),
        ],
      ),
    );
  }
}

class _FloatingNavBar extends StatelessWidget {
  final List<_NavItem> navItems;
  final String currentLocation;

  const _FloatingNavBar({
    required this.navItems,
    required this.currentLocation,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.t;

    return ClipRRect(
      borderRadius: BorderRadius.circular(34),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          height: 68,
          decoration: BoxDecoration(
            color: t.navBg,
            borderRadius: BorderRadius.circular(34),
            border: Border.all(color: t.border, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 30,
                offset: const Offset(0, 12),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: navItems.map((item) {
                final isActive = currentLocation.startsWith(item.route);
                return _NavTab(
                  item: item,
                  isActive: isActive,
                  onTap: () => context.go(item.route),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavTab extends StatelessWidget {
  final _NavItem item;
  final bool isActive;
  final VoidCallback onTap;

  const _NavTab({
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.t;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isActive ? t.pink.withOpacity(0.2) : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                isActive ? item.activeIcon : item.icon,
                size: 22,
                color: isActive ? t.text : t.textDim,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              item.label,
              style: TextStyle(
                fontFamily: 'Quicksand',
                fontSize: 10.5,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? t.text : t.textDim,
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
  });
}
