import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_svg/flutter_svg.dart';

// class FadeInSvgAsset extends StatelessWidget {
//   final String asset;
//   final BoxFit fit;
//   final Duration duration;
//   final Curve curve;
//
//   const FadeInSvgAsset(
//     this.asset, {
//     super.key,
//     this.fit = BoxFit.cover,
//     this.duration = const Duration(milliseconds: 600),
//     this.curve = Curves.easeOut,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<String>(
//       future: rootBundle.loadString(asset),
//       builder: (context, snap) {
//         if (!snap.hasData) {
//           // Optional: show a very light placeholder while loading
//           return const SizedBox.expand();
//         }
//         return TweenAnimationBuilder<double>(
//           tween: Tween(begin: 0, end: 1),
//           duration: duration,
//           curve: curve,
//           builder: (context, t, child) => Opacity(opacity: t, child: child),
//           child: SvgPicture.string(snap.data!, fit: fit),
//         );
//       },
//     );
//   }
// }
