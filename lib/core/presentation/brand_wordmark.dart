import 'package:flutter/cupertino.dart';

/// Founder-supplied horizontal logo, with a spoken Mongolian brand name.
class BrandWordmark extends StatelessWidget {
  const BrandWordmark({super.key});
  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Хадгалъя',
    image: true,
    child: ExcludeSemantics(
      child: Image.asset(
        'assets/brand/hadgaly-wordmark.png',
        key: const Key('brandWordmark'),
        height: 32,
        width: 120,
        fit: BoxFit.contain,
      ),
    ),
  );
}
