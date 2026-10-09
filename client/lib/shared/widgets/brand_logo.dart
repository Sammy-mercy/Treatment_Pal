// shared/widgets/brand_logo.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BrandLogo extends StatelessWidget {
  final double? width;
  final double? height;
  final Color? color;
  final BoxFit fit;

  const BrandLogo({
    super.key,
    this.width = 44,
    this.height = 44,
    this.color,
    this.fit = BoxFit.contain,
  });

  static const String assetPath =
      'assets/Treatment_Regimen_logo-Primary_color-cropped.svg';

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      assetPath,
      width: width,
      height: height,
      fit: fit,
      colorFilter: color != null
          ? ColorFilter.mode(color!, BlendMode.srcIn)
          : null,
    );
  }
}
