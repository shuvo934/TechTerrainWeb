import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:tech_terrain_web/core/loading_overlay.dart';
import 'package:tech_terrain_web/screens/about_page.dart';
import 'package:tech_terrain_web/screens/careers_page.dart';
import 'package:tech_terrain_web/screens/contact_page.dart';

import 'package:tech_terrain_web/screens/homepage.dart';
import 'package:tech_terrain_web/screens/working_screen.dart';
import 'package:tech_terrain_web/utilities/constants.dart';
import 'package:tech_terrain_web/components/site_app_bar.dart';
import 'package:tech_terrain_web/components/site_drawer.dart';

// --- Shell: shared AppBar/Drawer around pages ---
class AppShell extends StatefulWidget {
  final Widget child;
  final String currentPath; // '/','/about', etc.
  const AppShell({super.key, required this.child, required this.currentPath});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    // Right-side drawer, like you used before
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF8FAFF), //Color(0xFFC6D2F0),
      appBar: SiteAppBar(
        currentPath: widget.currentPath,
        selectedLabel: _selectedLabelFor(widget.currentPath),
        onNav: (label, {bool skipDelay = false}) async {
          final r = _routeOf(label);

          if (!skipDelay) {
            await LoadingController.i.flashThenGo(context, r.path);
          }

          // if (r.path == '/') {
          //   LoadingController.i.flashThenGo(context, r.path);
          //   // context.go('/'); // go home; HomePage will scroll to top
          // } else {
          //   LoadingController.i.flashThenGo(context, r.path);
          //   // context.go(r.path); // e.g. /about
          // }
        },
        onOpenDrawer: () => _scaffoldKey.currentState?.openEndDrawer(),
      ),
      endDrawerEnableOpenDragGesture: true,
      drawerEnableOpenDragGesture: false,
      endDrawer: SiteDrawer(
        selected: _selectedLabelFor(widget.currentPath),
        onSelect: (label) async {
          Navigator.of(context).maybePop(); // close drawer
          final r = _routeOf(label);
          if (r.path == '/') {
            await LoadingController.i.flashThenGo(context, r.path);
            // context.go('/');
          } else {
            await LoadingController.i.flashThenGo(context, r.path);
            // context.go(r.path);
          }
        },
      ),
      body: widget.child,
    );
  }

  // Map your menu labels to routes (expand as you add pages)
  _NavRoute _routeOf(String label) {
    switch (label) {
      case 'Home':
        return const _NavRoute('/', 'Home');
      case 'About':
        return const _NavRoute('/about', 'About');
      // For now, other items live on the home one-pager. You can deep-link later.
      case 'Services':
        return const _NavRoute('/services', 'Services');
      case 'Career':
        return const _NavRoute('/career', 'Career');
      case 'Contact':
        return const _NavRoute('/contact', 'Contact');
      default:
        return const _NavRoute('/', 'Home');
    }
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

class _NavRoute {
  final String path;
  final String label;
  const _NavRoute(this.path, this.label);
}

// --- Router ---
final _router = GoRouter(
  initialLocation: '/',
  routes: [
    // GoRoute(path: '/splash', builder: (_, __) => const SplashGate()),
    ShellRoute(
      builder:
          (context, state, child) => AppShell(
            currentPath:
                state.matchedLocation.isNotEmpty
                    ? state.matchedLocation
                    : state.uri.path,
            child: child,
          ),
      routes: [
        GoRoute(
          path: '/',
          name: 'home',
          builder:
              (context, state) =>
              // Optional: pass an anchor target if you later call context.go('/', extra: 'services')
              Homepage(initialTarget: state.extra as String?),
        ),
        GoRoute(
          path: '/about',
          name: 'about',
          builder: (context, state) => const AboutPage(),
        ),
        GoRoute(
          path: '/services',
          name: 'services',
          builder: (context, state) => const WorkingScreen(),
        ),
        GoRoute(
          path: '/career',
          name: 'career',
          builder: (context, state) => const CareersPage(),
        ),
        GoRoute(
          path: '/contact',
          name: 'contact',
          builder: (context, state) => const ContactPage(),
        ),
      ],
    ),
  ],
);

void main() {
  usePathUrlStrategy();
  GoogleFonts.config.allowRuntimeFetching = false;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Tech Terrain IT Ltd.',
      routerConfig: _router,
      scrollBehavior: AppScrollBehavior(),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: primary_color),
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      builder:
          (context, child) => LoadingOverlay(
            child: RepaintBoundary(child: child ?? const SizedBox()),
          ),
    );
  }
}

class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.stylus,
    PointerDeviceKind.unknown,
  };
}
