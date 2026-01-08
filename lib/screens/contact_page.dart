import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:tech_terrain_web/contact_sections/contact_find_us.dart';
import 'package:tech_terrain_web/contact_sections/contact_follow.dart';
import 'package:tech_terrain_web/contact_sections/contact_hero_header.dart';
import 'package:tech_terrain_web/contact_sections/contact_message.dart';
import 'package:tech_terrain_web/header_sections/footer_section.dart';
// import 'package:web_smooth_scroll/web_smooth_scroll.dart';
// import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform;
// import 'package:web/web.dart' as web;

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final _sc = ScrollController();

  @override
  void initState() {
    super.initState();
    // Always start at top
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
          // ---- Hero header
          Stack(
            children: [
              Positioned.fill(
                child: ResponsiveBuilder(
                  builder: (context, sizing) {
                    final isMobile =
                        sizing.deviceScreenType == DeviceScreenType.mobile;

                    return SvgPicture.asset(
                      isMobile
                          ? 'assets/illustrations/contact_hero_bg_variant_b_mobile.svg'
                          : 'assets/illustrations/contact_hero_bg_variant_b.svg',
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                    );
                  },
                ),
              ),
              ContactHeroHeader(),
            ],
          ),

          // ---- Content
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
              ContactMessage(),
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
              ContactFindUs(),
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
              ContactFollow(),
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
