import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tech_terrain_web/components/nav_item.dart';
import 'package:tech_terrain_web/core/loading_overlay.dart';
import 'package:tech_terrain_web/utilities/constants.dart';

const _navItems = <String>['Home', 'About', 'Services', 'Career', 'Contact'];

class SiteAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String currentPath; // 👈 add
  final String selectedLabel;
  final void Function(String, {bool skipDelay}) onNav; // 👈 add
  final VoidCallback onOpenDrawer; // 👈 add
  final double height;

  const SiteAppBar({
    super.key,
    required this.currentPath,
    required this.selectedLabel,
    required this.onNav,
    required this.onOpenDrawer,
    this.height = 72,
  });

  @override
  State<SiteAppBar> createState() => _SiteAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(height);
}

class _SiteAppBarState extends State<SiteAppBar> {
  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: widget.preferredSize,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Color(0x11000000),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: ResponsiveBuilder(
          builder: (context, sizing) {
            final isDesktop =
                sizing.deviceScreenType == DeviceScreenType.desktop;
            final maxW = isDesktop ? 1300.0 : (sizing.isTablet ? 980.0 : 680.0);

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxW),
                child: SizedBox(
                  height: widget.height,
                  child: Row(
                    children: [
                      SizedBox(width: 16),

                      // Logo + Brand
                      SvgPicture.asset(
                        'assets/illustrations/ttit_logo.svg',
                        width: 46,
                      ),
                      const SizedBox(width: 10),
                      Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: GestureDetector(
                          onTap:
                              () =>
                                  LoadingController.i.flashThenGo(context, '/'),
                          child: Text(
                            'TECH TERRAIN IT LTD',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: primary_color,
                            ),
                          ),
                        ),
                      ),

                      const Spacer(),

                      // Desktop nav items
                      if (isDesktop) ...[
                        for (final label in _navItems)
                          NavItem(
                            label,
                            isSelected: label == widget.selectedLabel,
                            onTap: () {
                              bool b = false;
                              if (label == prevLabel) b = true;
                              // prevLabel = label;
                              widget.onNav(label, skipDelay: b);
                            },
                          ),
                        const SizedBox(width: 16),
                      ] else ...[
                        IconButton(
                          icon: const Icon(Icons.menu_rounded),
                          onPressed: widget.onOpenDrawer,
                        ),
                      ],

                      if (!isDesktop) const SizedBox(width: 8),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
