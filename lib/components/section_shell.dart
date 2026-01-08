import 'package:responsive_builder/responsive_builder.dart';
import 'package:flutter/material.dart';

class SectionShell extends StatelessWidget {
  final Widget Function(SectionConfig) builder;
  const SectionShell({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, sizing) {
        final isMobile = sizing.deviceScreenType == DeviceScreenType.mobile;
        final isTablet = sizing.deviceScreenType == DeviceScreenType.tablet;
        final isDesktop =
            sizing.deviceScreenType == DeviceScreenType.desktop ||
            sizing.deviceScreenType ==
                DeviceScreenType.watch; // treat watch as desktop fallback

        final pad =
            isMobile
                ? const EdgeInsets.symmetric(horizontal: 16, vertical: 32)
                : isTablet
                ? const EdgeInsets.symmetric(horizontal: 20, vertical: 48)
                : const EdgeInsets.symmetric(horizontal: 24, vertical: 120);

        final maxW =
            isMobile
                ? 680.0
                : isTablet
                ? 980.0
                : 1300.0;

        final bh1 =
            isMobile
                ? 35.0
                : isTablet
                ? 44.0
                : 56.0;

        final h1 =
            isMobile
                ? 30.0
                : isTablet
                ? 38.0
                : 48.0;

        final h1_1 =
            isMobile
                ? 20.0
                : isTablet
                ? 25.0
                : 30.0;

        final h2 =
            isMobile
                ? 25.0
                : isTablet
                ? 32.0
                : 40.0;

        final body =
            isMobile
                ? 14.0
                : isTablet
                ? 15.0
                : 16.0;
        final gap =
            isMobile
                ? 12.0
                : isTablet
                ? 14.0
                : 16.0;

        final cfg = SectionConfig(
          sizing: sizing,
          isMobile: isMobile,
          isTablet: isTablet,
          isDesktop: isDesktop,
          padding: pad,
          maxWidth: maxW,
          h1: h1,
          h1_1: h1_1,
          bh1: bh1,
          h2: h2,
          body: body,
          gap: gap,
        );

        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: cfg.maxWidth),
            child: Padding(padding: cfg.padding, child: builder(cfg)),
          ),
        );
      },
    );
  }
}

class SectionConfig {
  final SizingInformation sizing;
  final bool isMobile, isTablet, isDesktop;
  final EdgeInsets padding;
  final double maxWidth, bh1, h1, h2, h1_1, body, gap;
  const SectionConfig({
    required this.sizing,
    required this.isMobile,
    required this.isTablet,
    required this.isDesktop,
    required this.padding,
    required this.maxWidth,
    required this.bh1,
    required this.h1,
    required this.h1_1,
    required this.h2,
    required this.body,
    required this.gap,
  });
}
