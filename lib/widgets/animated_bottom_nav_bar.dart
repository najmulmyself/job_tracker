import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class AnimatedBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<NavBarItem> items;

  const AnimatedBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          margin: EdgeInsets.fromLTRB(
            20,
            0,
            20,
            bottomPadding > 0 ? bottomPadding : 12,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isSelected = currentIndex == index;

              return GestureDetector(
                onTap: () => onTap(index),
                behavior: HitTestBehavior.opaque,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: isSelected ? 1.0 : 0.0),
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16 + (value * 8),
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.accentOrange
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isSelected ? item.activeIcon : item.icon,
                            size: 22,
                            color: isSelected
                                ? Colors.white
                                : Colors.white.withOpacity(0.6),
                          ),
                          ClipRect(
                            child: AnimatedAlign(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOutCubic,
                              alignment: Alignment.centerLeft,
                              widthFactor: value,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: Text(
                                  item.label,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class NavBarItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const NavBarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
