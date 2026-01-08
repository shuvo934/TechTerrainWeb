import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tech_terrain_web/utilities/constants.dart';

class NavItem extends StatefulWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;
  const NavItem(this.label, {super.key, this.isSelected = false, this.onTap});

  @override
  State<NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<NavItem> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    const primary = primary_color;
    final active = widget.isSelected;
    final borderColor = (active || _hovering) ? primary : Colors.transparent;
    final textColor = (active || _hovering) ? primary : Colors.black87;
    final bgColor =
    active ? primary.withValues(alpha: .08) : Colors.transparent;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovering = true),
        onExit: (_) => setState(() => _hovering = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(150),
            border: Border.all(color: borderColor, width: 1.4),
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              borderRadius: BorderRadius.circular(150),
              hoverColor: Colors.transparent,
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: widget.onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                child: Text(
                  widget.label,
                  style: GoogleFonts.beVietnamPro(
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}