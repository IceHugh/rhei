
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class GlassTile extends StatelessWidget {
  final Widget leading;
  final Widget title;
  final Widget? trailing;
  final Widget? additionalInfo;
  final VoidCallback? onTap;

  const GlassTile({
    super.key,
    required this.leading,
    required this.title,
    this.trailing,
    this.additionalInfo,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = CupertinoTheme.brightnessOf(context) == Brightness.dark;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            leading,
            const SizedBox(width: 12),
            Expanded(
              child: DefaultTextStyle(
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: isDarkMode ? CupertinoColors.white : CupertinoColors.label.resolveFrom(context),
                ),
                child: title,
              ),
            ),
            if (additionalInfo != null) ...[
              const SizedBox(width: 8),
              DefaultTextStyle(
                style: TextStyle(
                  color: isDarkMode ? CupertinoColors.systemGrey2 : CupertinoColors.secondaryLabel.resolveFrom(context),
                  fontSize: 13,
                ),
                child: additionalInfo!,
              ),
            ],
            if (trailing != null) ...[
              const SizedBox(width: 8),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}

class SettingsIcon extends StatelessWidget {
  final IconData icon;
  final Color color;

  const SettingsIcon({
    super.key,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(7),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(icon, color: CupertinoColors.white, size: 16),
    );
  }
}
