import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/widgets.dart';
import 'package:web/web.dart' as web;
import 'dart:js_interop';

typedef BackPredicate = FutureOr<bool> Function();

class WebBackListener extends StatefulWidget {
  final Widget child;
  final BackPredicate? onBack;

  const WebBackListener({super.key, required this.child, this.onBack});

  @override
  State<WebBackListener> createState() => _WebBackListenerState();
}

class _WebBackListenerState extends State<WebBackListener> {
  web.EventListener? _listener;
  bool _handling = false;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) return;

    _listener =
        ((web.Event e) {
          if (_handling) return;
          _handling = true;

          // Do async work outside the DOM callback.
          scheduleMicrotask(() async {
            final allow = await (widget.onBack?.call() ?? true);
            _handling = false;

            // If we consumed the back, cancel it by moving history forward again.
            if (!allow) {
              web.window.history.forward();
            }
          });
        }).toJS;

    web.window.addEventListener('popstate', _listener!);
  }

  @override
  void dispose() {
    if (_listener != null) {
      web.window.removeEventListener('popstate', _listener!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
