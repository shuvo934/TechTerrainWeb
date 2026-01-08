import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tech_terrain_web/components/section_shell.dart';
import 'package:tech_terrain_web/utilities/constants.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

enum _EmailOption { defaultApp, gmail, outlook, copy }

class ContactMessage extends StatefulWidget {
  const ContactMessage({super.key});

  @override
  State<ContactMessage> createState() => _ContactMessageState();
}

class _ContactMessageState extends State<ContactMessage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ac = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );
  late final Animation<double> _fadeTitle = CurvedAnimation(
    parent: _ac,
    curve: const Interval(.00, .45, curve: Curves.easeOut),
  );
  late final Animation<Offset> _slideTitle = Tween<Offset>(
    begin: const Offset(0, .10),
    end: Offset.zero,
  ).animate(
    CurvedAnimation(
      parent: _ac,
      curve: const Interval(.00, .45, curve: Curves.easeOut),
    ),
  );

  late final Animation<double> _fadeBody = CurvedAnimation(
    parent: _ac,
    curve: const Interval(.12, .70, curve: Curves.easeOut),
  );
  late final Animation<Offset> _slideBody = Tween<Offset>(
    begin: const Offset(0, .08),
    end: Offset.zero,
  ).animate(
    CurvedAnimation(
      parent: _ac,
      curve: const Interval(.12, .70, curve: Curves.easeOut),
    ),
  );

  // Illustration
  late final Animation<double> _fadeIllu = CurvedAnimation(
    parent: _ac,
    curve: const Interval(.15, .75, curve: Curves.easeOut),
  );
  late final Animation<Offset> _slideIllu = Tween<Offset>(
    begin: const Offset(0, .06),
    end: Offset.zero,
  ).animate(
    CurvedAnimation(
      parent: _ac,
      curve: const Interval(.15, .75, curve: Curves.easeOut),
    ),
  );
  late final Animation<double> _scaleIllu = Tween<double>(
        begin: 0.985,
        end: 1.0,
      )
      .chain(CurveTween(curve: const Interval(.15, .75, curve: Curves.easeOut)))
      .animate(_ac);

  final _visKey = UniqueKey();
  bool _shown = false;

  bool _disposed = false; // 👈 add
  bool get _alive => mounted && !_disposed; // 👈 helper

  void _safeForward({double? from}) {
    if (!_alive) return;
    if (from != null) {
      _ac.forward(from: from);
    } else {
      _ac.forward();
    }
  }

  void _safeReverse() {
    if (!_alive) return;
    _ac.reverse();
  }

  // void _safeSetState(VoidCallback fn) {
  //   if (!_alive) return;
  //   setState(fn);
  // }

  Timer? _visDebounce;
  void _onVisibility(VisibilityInfo info) {
    if (!_alive) return;
    _visDebounce?.cancel();
    _visDebounce = Timer(const Duration(milliseconds: 60), () {
      final v = info.visibleFraction;

      if (v >= 0.30 && !_shown) {
        _shown = true;
        _safeForward(from: 0.0);
      } else if (v <= 0.15 && _shown) {
        _shown = false;
        _safeReverse();
      }
    });
  }

  // Form
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _company = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _message = TextEditingController();

  Future<_EmailOption?> _chooseEmailProvider(BuildContext context) {
    return showDialog<_EmailOption>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Send your message via',
              style: GoogleFonts.beVietnamPro(),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.email_rounded,
                    color: primary_color,
                  ),
                  title: const Text('Mail app (default)'),
                  subtitle: const Text('Open your installed email client'),
                  onTap:
                      () => Navigator.of(context).pop(_EmailOption.defaultApp),
                ),
                const Divider(height: 0),
                ListTile(
                  leading: const Icon(
                    Icons.mark_email_unread_rounded,
                    color: Colors.redAccent,
                  ),
                  title: const Text('Gmail (web)'),
                  onTap: () => Navigator.of(context).pop(_EmailOption.gmail),
                ),
                ListTile(
                  leading: const Icon(
                    Icons.alternate_email_rounded,
                    color: Color(0xFF0F6CBD),
                  ),
                  title: const Text('Outlook (web)'),
                  onTap: () => Navigator.of(context).pop(_EmailOption.outlook),
                ),
                const Divider(height: 0),
                ListTile(
                  leading: const Icon(Icons.copy_rounded),
                  title: const Text('Copy email address'),
                  onTap: () => Navigator.of(context).pop(_EmailOption.copy),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(null),
                child: const Text('Cancel'),
              ),
            ],
          ),
    );
  }

  String _enc(String s) => Uri.encodeComponent(s);

  Uri _mailtoUri(String to, String subject, String body) =>
      Uri.parse('mailto:$to?subject=${_enc(subject)}&body=${_enc(body)}');

  Uri _gmailUri(String to, String subject, String body) => Uri.parse(
    'https://mail.google.com/mail/?view=cm&fs=1&to=${_enc(to)}&su=${_enc(subject)}&body=${_enc(body)}',
  );

  Uri _outlookUri(String to, String subject, String body) => Uri.parse(
    'https://outlook.office.com/mail/deeplink/compose?to=${_enc(to)}&subject=${_enc(subject)}&body=${_enc(body)}',
  );

  Future<bool> _tryLaunch(Uri uri, {LaunchMode? mode}) async {
    try {
      return await launchUrl(uri, mode: mode ?? LaunchMode.platformDefault);
    } catch (_) {
      return false;
    }
  }

  Future<void> _sendEmail() async {
    if (!_formKey.currentState!.validate()) return;

    final to = 'info@techterrain-it.com';
    final subject =
        'Website Inquiry – ${_name.text.trim()} (${_company.text.trim()})';
    final body = [
      'Name: ${_name.text.trim()}',
      'Company: ${_company.text.trim()}',
      'Email: ${_email.text.trim()}',
      'Phone: ${_phone.text.trim()}',
      '',
      'Message:',
      _message.text.trim(),
    ].join('\n');

    final choice = await _chooseEmailProvider(context);
    if (choice == null) return;

    switch (choice) {
      case _EmailOption.defaultApp:
        {
          // On mobile/desktop, prefer external app; on web, platform default.
          final mode =
              kIsWeb
                  ? LaunchMode.platformDefault
                  : LaunchMode.externalApplication;
          final ok = await _tryLaunch(
            _mailtoUri(to, subject, body),
            mode: mode,
          );
          if (!ok && mounted) {
            _toast("Couldn't open your mail app. Try Gmail or Outlook.");
          } else {
            _toast('Opening your email app…');
          }
          break;
        }
      case _EmailOption.gmail:
        {
          final ok = await _tryLaunch(_gmailUri(to, subject, body));
          if (!ok && mounted) {
            _toast("Couldn't open Gmail.");
          } else {
            _toast('Opening Gmail…');
          }
          break;
        }

      case _EmailOption.outlook:
        {
          final ok = await _tryLaunch(_outlookUri(to, subject, body));
          if (!ok && mounted) {
            _toast("Couldn't open Outlook.");
          } else {
            _toast('Opening Outlook…');
          }
          break;
        }

      case _EmailOption.copy:
        {
          await Clipboard.setData(ClipboardData(text: to));
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Address copied. Paste it in your mail app & send us your message',
              ),
            ),
          );
          break;
        }
    }
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void dispose() {
    _disposed = true;
    _visDebounce?.cancel();
    _ac.dispose();
    _name.dispose();
    _company.dispose();
    _email.dispose();
    _phone.dispose();
    _message.dispose();
    VisibilityDetectorController.instance.forget(_visKey);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: _visKey,
      onVisibilityChanged: _onVisibility,
      child: Center(
        child: AnimatedBuilder(
          animation: _ac,
          builder:
              (context, child) =>
                  IgnorePointer(ignoring: _ac.value < 0.05, child: child),
          child: SectionShell(
            builder: (cfg) {
              final illu = FadeTransition(
                opacity: _fadeIllu,
                child: SlideTransition(
                  position: _slideIllu,
                  child: ScaleTransition(
                    scale: _scaleIllu,
                    child: AspectRatio(
                      aspectRatio: cfg.isMobile ? 4 / 3 : 5 / 4,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                          cfg.isMobile ? 20 : 28,
                        ),
                        child: SvgPicture.asset(
                          'assets/illustrations/send_message.svg',
                          fit: BoxFit.contain,
                          // duration: const Duration(
                          //   milliseconds: 1500,
                          // ), // tweak if you like
                          // curve: Curves.easeOutCubic,
                        ),
                      ),
                    ),
                  ),
                ),
              );

              final title = FadeTransition(
                opacity: _fadeTitle,
                child: SlideTransition(
                  position: _slideTitle,
                  child: Text(
                    'SEND US A MESSAGE',
                    style: GoogleFonts.poppins(
                      fontSize: cfg.h2,
                      fontWeight: FontWeight.w600,
                      color: primary_color,
                      height: 1.06,
                    ),
                  ),
                ),
              );

              final bodyText = FadeTransition(
                opacity: _fadeBody,
                child: SlideTransition(
                  position: _slideBody,
                  child: _RightFormBlock(
                    formKey: _formKey,
                    name: _name,
                    company: _company,
                    email: _email,
                    phone: _phone,
                    message: _message,
                    onSend: _sendEmail,
                  ),
                ),
              );

              if (cfg.isMobile) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    illu,
                    const SizedBox(height: 25),
                    title,
                    const SizedBox(height: 12),
                    bodyText,
                  ],
                );
              } else {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(flex: 6, child: illu),
                    const SizedBox(width: 60),

                    // Content
                    Expanded(
                      flex: 6,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [title, const SizedBox(height: 25), bodyText],
                      ),
                    ),
                  ],
                );
              }
            },
          ),
        ),
      ),
    );
  }
}

// ---------- RIGHT: Contact Form ----------

class _RightFormBlock extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController name, company, email, phone, message;
  final VoidCallback onSend;

  const _RightFormBlock({
    required this.formKey,
    required this.name,
    required this.company,
    required this.email,
    required this.phone,
    required this.message,
    required this.onSend,
  });

  @override
  State<_RightFormBlock> createState() => _RightFormBlockState();
}

class _RightFormBlockState extends State<_RightFormBlock> {
  bool _sendingHover = false;

  String? _req(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Required' : null;
  String? _emailV(String? v) {
    if (v == null || v.trim().isEmpty) return 'Required';
    final ok = RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(v.trim());
    return ok ? null : 'Invalid email';
  }

  String? _phoneV(String? v) {
    if (v == null || v.trim().isEmpty) return 'Required';
    final only = v.replaceAll(RegExp(r'[^0-9+]'), '');
    return only.length < 6 ? 'Invalid phone' : null;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _FField(
            controller: widget.name,
            label: 'Name',
            validator: _req,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 10),
          _FField(
            controller: widget.company,
            label: 'Company',
            validator: _req,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 10),
          _FField(
            controller: widget.email,
            label: 'Email',
            validator: _emailV,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 10),
          _FField(
            controller: widget.phone,
            label: 'Phone',
            validator: _phoneV,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 10),
          _FField(
            controller: widget.message,
            label: 'Message',
            validator: _req,
            maxLines: 6,
            keyboardType: TextInputType.multiline,
          ),
          const SizedBox(height: 14),

          MouseRegion(
            onEnter: (_) => setState(() => _sendingHover = true),
            onExit: (_) => setState(() => _sendingHover = false),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4), // ← your radius
                ),
                backgroundColor:
                    _sendingHover ? primary_color : primary_color_light,
                foregroundColor: Colors.white,
              ),
              onPressed: widget.onSend,
              child: Text(
                'SEND',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final int maxLines;

  const _FField({
    required this.controller,
    required this.label,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      style: GoogleFonts.beVietnamPro(fontWeight: FontWeight.w500),
      maxLines: maxLines,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: label,
        hintStyle: GoogleFonts.beVietnamPro(fontWeight: FontWeight.w500),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: Colors.white, width: 1.6),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: primary_color, width: 1.6),
        ),
        isDense: true,
        contentPadding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
      ),
    );
  }
}
