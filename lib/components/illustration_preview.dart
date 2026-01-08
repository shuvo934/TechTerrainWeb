import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class IllustrationPreview extends StatelessWidget {
  const IllustrationPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Preview')),
      body: Center(
        child: SvgPicture.asset('assets/illustrations/programmer_working.svg'),
      ),
    );
  }
}
