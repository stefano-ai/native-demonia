import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/theme.dart';

class ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onPressed;
  final bool small;

  const ActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    this.onPressed,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null;

    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          vertical: small ? 10 : 14,
          horizontal: small ? 8 : 16,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDisabled
                ? [
                    AppTheme.stoneGray.withOpacity(0.3),
                    AppTheme.stoneGray.withOpacity(0.2),
                  ]
                : [
                    color.withOpacity(0.8),
                    color.withOpacity(0.5),
                  ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDisabled
                ? AppTheme.stoneGray.withOpacity(0.3)
                : color.withOpacity(0.8),
            width: 2,
          ),
          boxShadow: isDisabled
              ? null
              : [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isDisabled ? AppTheme.ashGray : Colors.white,
              size: small ? 16 : 24,
            ),
            if (!small) const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.cinzel(
                color: isDisabled ? AppTheme.ashGray : Colors.white,
                fontSize: small ? 11 : 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
