import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
// import 'package:google_fonts/google_fonts.dart';
import 'package:tech_terrain_web/core/loading_overlay.dart';
import 'package:tech_terrain_web/header_sections/about_section.dart';
import 'package:tech_terrain_web/header_sections/contact_us_section.dart';
import 'package:tech_terrain_web/header_sections/excellence_section.dart';
import 'package:tech_terrain_web/header_sections/footer_section.dart';
import 'package:tech_terrain_web/header_sections/hero_section.dart';
import 'package:tech_terrain_web/header_sections/mission_vision_section.dart';
import 'package:tech_terrain_web/header_sections/partners_section.dart';
import 'package:tech_terrain_web/header_sections/service_section.dart';
import 'package:tech_terrain_web/header_sections/testimonials_section.dart';
import 'package:tech_terrain_web/utilities/constants.dart';
// import 'package:web_smooth_scroll/web_smooth_scroll.dart';
// import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform;
// import 'package:web/web.dart' as web;

class Homepage extends StatefulWidget {
  const Homepage({super.key, this.initialTarget});
  final String? initialTarget;

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final _sc = ScrollController();

  @override
  void initState() {
    super.initState();

    if (firstLoader) {
      Future<void>.delayed(const Duration(milliseconds: 1200)).then((_) {
        if (!mounted) return;
        setState(() => firstLoader = false);
      });
    }
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (firstLoader) {
        LoadingController.i.flashFirstHome(
          duration: const Duration(seconds: 1),
        );
      } else {
        if (_sc.hasClients) _sc.jumpTo(0);
      } // always start at top/hero
      // Optional: scroll to a target if you later use context.go('/', extra: 'services')
      // if (widget.initialTarget != null) { ... }
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
    // print('hello $firstLoader');
    final content = SingleChildScrollView(
      controller: _sc,
      child: Column(
        children: [
          Stack(
            children: [
              Positioned.fill(
                child: SvgPicture.asset(
                  'assets/illustrations/hero_bg_it_company_desktop_1.svg',
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                ),
              ),
              HeroSection(),
            ],
          ),
          // SizedBox(height: 48),
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
              AboutSection(
                illustrationAsset:
                    'assets/illustrations/about_us.svg', // or your own
              ),
            ],
          ),
          // SizedBox(height: 24),
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
              MissionVisionSection(),
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
              ServiceSection(),
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
              PartnersSection(),
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
              ExcellenceSection(),
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
              TestimonialsSection(),
            ],
          ),
          Stack(
            children: [
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFE5ECFA), Color(0xFFE5ECFA)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
              ContactUsSection(),
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

    if (firstLoader) {
      return Scaffold(
        backgroundColor: Color(0xFFF8FAFF),
        body: Center(
          child: SizedBox(),
        ), // a small widget showing your logo + bar
      );
    } else {
      return content;
    }
  }
}
