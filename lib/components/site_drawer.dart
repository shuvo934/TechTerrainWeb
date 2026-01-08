import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tech_terrain_web/utilities/constants.dart';

const _navItems = <String>['Home', 'About', 'Services', 'Career', 'Contact'];

class SiteDrawer extends StatelessWidget {
  final String selected;
  final void Function(String) onSelect;

  const SiteDrawer({super.key, required this.selected, required this.onSelect});

  Icon _iconFor(String label) {
    switch (label) {
      case 'Home':
        return const Icon(Icons.home_rounded);
      case 'About':
        return const Icon(Icons.info_rounded);
      case 'Services':
        return const Icon(Icons.design_services_rounded);
      case 'Career':
        return const Icon(Icons.work_outline_rounded);
      case 'Contact':
        return const Icon(Icons.mail_outline_rounded);
      default:
        return const Icon(Icons.circle_outlined);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              // Header
              // Padding(
              //   padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              //   child: Row(
              //     children: [
              //       SvgPicture.asset(
              //         'assets/illustrations/ttit_logo.svg',
              //         width: 40,
              //       ),
              //       const SizedBox(width: 10),
              //       Text(
              //         'TECH TERRAIN IT LTD',
              //         style: GoogleFonts.poppins(
              //           fontSize: 16,
              //           fontWeight: FontWeight.w700,
              //           color: primary_color,
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
              const Divider(height: 1),

              // Items
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      for (final label in _navItems)
                        ListTile(
                          leading: _iconFor(label),
                          title: Text(
                            label,
                            style: GoogleFonts.beVietnamPro(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color:
                                  selected == label
                                      ? primary_color
                                      : Colors.black87,
                            ),
                          ),
                          selected: selected == label,
                          selectedTileColor: primary_color.withValues(
                            alpha: .06,
                          ),
                          onTap: () {
                            // Navigator.of(context).pop();
                            onSelect(label);
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
