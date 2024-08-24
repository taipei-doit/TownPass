import 'package:cached_network_image/cached_network_image.dart';
import 'package:town_pass/gen/assets.gen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TPCachedNetworkImage extends StatelessWidget {
  final String imageUrl;
  final Map<String, String>? httpHeaders;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Color? color;
  final double borderRadius;

  const TPCachedNetworkImage({
    super.key,
    required this.imageUrl,
    this.httpHeaders,
    this.width,
    this.height,
    this.fit,
    this.color = const Color(0xFFFFFFFF),
    this.borderRadius = 6,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: ShapeDecoration(
        color: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
      ),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        httpHeaders: httpHeaders,
        width: double.infinity,
        height: double.infinity,
        fit: fit,
        placeholder: (context, string) => const Center(child: CircularProgressIndicator()),
        errorWidget: (context, string, object) => ColoredBox(
          color: const Color(0xFFE3E7E9),
          child: Center(
            // TODO: change this svg
            child: Assets.svg.logoS.svg(),
          ),
        ),
      ),
    );
  }
}
