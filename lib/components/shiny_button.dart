import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:tech_terrain_web/core/loading_overlay.dart';
import 'package:tech_terrain_web/utilities/constants.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';

class ShinyButton extends StatefulWidget {
  final String buttonText;
  final VoidCallback onPressed;
  const ShinyButton(this.buttonText, {super.key, required this.onPressed});
  @override
  State<ShinyButton> createState() => _ShinyButtonState();
}

class _ShinyButtonState extends State<ShinyButton>
    with SingleTickerProviderStateMixin {
  bool _hover = false;
  late final AnimationController _ac = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3),
  )..repeat();

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gradient = LinearGradient(
      colors: const [primary_color_light, primary_color],
    );
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: ResponsiveBuilder(
        builder: (context, sizing) {
          final isMobile = sizing.deviceScreenType == DeviceScreenType.mobile;
          final isTablet = sizing.deviceScreenType == DeviceScreenType.tablet;

          return AnimatedScale(
            duration: const Duration(milliseconds: 160),
            scale: _hover ? 1.02 : 1.0,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  isMobile
                      ? 20
                      : isTablet
                      ? 30
                      : 40,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x33678EE0),
                    blurRadius: 24,
                    offset: Offset(0, 12),
                  ),
                ],
              ),
              child: Stack(
                clipBehavior: Clip.hardEdge,
                children: [
                  Positioned.fill(
                    child: AnimatedBuilder(
                      animation: _ac,
                      builder: (context, _) {
                        double stripeWidth =
                            isMobile
                                ? 200
                                : isTablet
                                ? 240
                                : 280;
                        return ShaderMask(
                          shaderCallback: (r) {
                            final t = _ac.value;
                            final dx =
                                (r.width + stripeWidth) * t - stripeWidth;
                            return const LinearGradient(
                              colors: [
                                Colors.transparent,
                                Colors.white24,
                                Colors.transparent,
                              ],
                              stops: [0.45, 0.5, 0.55],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ).createShader(
                              Rect.fromLTWH(dx, 0, stripeWidth, r.height),
                            );
                          },
                          blendMode: BlendMode.srcATop,
                          child: Container(
                            height:
                                isMobile
                                    ? 28
                                    : isTablet
                                    ? 38
                                    : 48,
                            decoration: BoxDecoration(
                              gradient: gradient,
                              borderRadius: BorderRadius.circular(
                                isMobile
                                    ? 20
                                    : isTablet
                                    ? 30
                                    : 40,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4.0,
                      vertical: 4.0,
                    ),
                    child: FilledButton.tonal(
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                        shape: const StadiumBorder(),
                        elevation: 0,
                      ),
                      onPressed: widget.onPressed,
                      // onPressed: () async {
                      //   // final url = Uri.parse('https://techterrain-it.com');
                      //   // if (await canLaunchUrl(url)) launchUrl(url);
                      //   // prevLabel = _selectedLabelFor(widget.path);
                      //   LoadingController.i.flashThenGo(context, widget.path);
                      //   // context.go(widget.path);
                      // },
                      child: Text(
                        widget.buttonText,
                        style: GoogleFonts.beVietnamPro(
                          fontSize:
                              isMobile
                                  ? 14
                                  : isTablet
                                  ? 15
                                  : 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _selectedLabelFor(String path) {
    if (path.startsWith('/about')) {
      return 'About';
    } else if (path.startsWith('/services')) {
      return 'Services';
    } else if (path.startsWith('/career')) {
      return 'Career';
    } else if (path.startsWith('/contact')) {
      return 'Contact';
    } else {
      return 'Home';
    } // other anchors live on home
  }
}
