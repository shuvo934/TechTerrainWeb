import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:tech_terrain_web/about_sections/about_details_section.dart';
import 'package:tech_terrain_web/about_sections/about_hero_header.dart';
import 'package:tech_terrain_web/about_sections/awards_section.dart';
// import 'package:tech_terrain_web/about_sections/experience_section.dart';
import 'package:tech_terrain_web/about_sections/leadership_section.dart';
import 'package:tech_terrain_web/about_sections/value_section.dart';
import 'package:tech_terrain_web/components/shiny_button.dart';
import 'package:tech_terrain_web/core/loading_overlay.dart';
import 'package:tech_terrain_web/header_sections/footer_section.dart';
import 'package:tech_terrain_web/utilities/constants.dart';
// import 'package:web_smooth_scroll/web_smooth_scroll.dart';
// import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform;
// import 'package:web/web.dart' as web;

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  final _sc = ScrollController();

  @override
  void initState() {
    super.initState();
    // Always start the About page at top
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_sc.hasClients) _sc.jumpTo(0);
    });
  }

  @override
  void dispose() {
    _sc.dispose();
    super.dispose();
  }

  // bool get _isTouchWeb {
  //   if (!kIsWeb) return false;
  //   try {
  //     final hasTouch = (web.window.navigator.maxTouchPoints ?? 0) > 0;
  //     final coarse = web.window.matchMedia('(pointer: coarse)').matches;
  //     return hasTouch || coarse;
  //   } catch (_) {
  //     return false;
  //   }
  //   // final m1 = (web.window.navigator.maxTouchPoints ?? 0) > 0;
  //   // final m2 = web.window.matchMedia('(pointer: coarse)').matches;
  //   // return kIsWeb && (m1 || m2);
  // }
  //
  // bool get _enableSmoothScrollDesktop {
  //   if (!_isTouchWeb && kIsWeb) return true; // desktop web
  //   return false;
  // }
  //
  // ScrollPhysics get _platformPhysics {
  //   if (_enableSmoothScrollDesktop) return const NeverScrollableScrollPhysics();
  //   // native scrolling everywhere else
  //   switch (defaultTargetPlatform) {
  //     case TargetPlatform.iOS:
  //     case TargetPlatform.macOS:
  //       return const BouncingScrollPhysics(
  //         parent: AlwaysScrollableScrollPhysics(),
  //       );
  //     default:
  //       return const ClampingScrollPhysics();
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _sc,
      child: Column(
        children: [
          Stack(
            children: [
              Positioned.fill(
                child: ResponsiveBuilder(
                  builder: (context, sizing) {
                    final isMobile =
                        sizing.deviceScreenType == DeviceScreenType.mobile;

                    return SvgPicture.asset(
                      isMobile
                          ? 'assets/illustrations/about_bg.svg'
                          : 'assets/illustrations/about_bg.svg',
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                    );
                  },
                ),
              ),
              AboutHeroHeader(),
            ],
          ),
          Stack(
            children: [
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFF8FAFF), Color(0xFFE5ECFA)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
              AboutDetailsSection(),
            ],
          ),
          Stack(
            children: [
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFE5ECFA), Color(0xFFF8FAFF)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
              ValueSection(),
            ],
          ),
          Stack(
            children: [
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFF8FAFF), Color(0xFFE5ECFA)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
              LeadershipSection(),
            ],
          ),
          Stack(
            children: [
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFE5ECFA), Color(0xFFF8FAFF)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
              AwardsSection(),
            ],
          ),
          // Stack(
          //   children: [
          //     Positioned.fill(
          //       child: Container(
          //         decoration: BoxDecoration(
          //           gradient: LinearGradient(
          //             colors: [Color(0xFFF8FAFF), Color(0xFFE5ECFA)],
          //             begin: Alignment.topCenter,
          //             end: Alignment.bottomCenter,
          //           ),
          //         ),
          //       ),
          //     ),
          //     ExperienceSection(),
          //   ],
          // ),
          Stack(
            children: [
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFF8FAFF), Color(0xFFF8FAFF)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
              _AboutCTA(),
            ],
          ),
          Stack(
            children: [
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.white, Colors.white],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
              FooterSection(),
            ],
          ),
        ],
      ),
    );
  }
}

/// ---------------------- CTA ----------------------
class _AboutCTA extends StatelessWidget {
  const _AboutCTA();

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, sizing) {
        final isMobile = sizing.deviceScreenType == DeviceScreenType.mobile;
        final isTablet = sizing.deviceScreenType == DeviceScreenType.tablet;
        final maxW =
            isMobile
                ? 680.0
                : isTablet
                ? 980.0
                : 1300.0;
        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxW),
            child: Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 80),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white, //const Color(0xFFF6F8FF),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0x11000000)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Ready to build what’s next?',
                        style: GoogleFonts.poppins(
                          fontSize: isMobile ? 18 : 20,
                          fontWeight: FontWeight.w700,
                          color: primary_color,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ShinyButton(
                      'Contact us',
                      onPressed: () async {
                        LoadingController.i.flashThenGo(context, '/contact');
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
