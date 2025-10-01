import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:town_pass/gen/assets.gen.dart';
import 'package:town_pass/util/tp_colors.dart';

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
    this.color = TPColors.white,
    this.borderRadius = 6,
  });

  @override
  Widget build(BuildContext context) {
    return _buildContainer();
  }

  Widget _buildContainer() {
    return Container(
      width: width,
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Container(
          color: color, // 此顏色將作為圓角區域內圖片的背景色
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            httpHeaders: httpHeaders,
            width: double.infinity,
            height: double.infinity,
            fit: fit,
            placeholder: (context, string) =>
                const Center(child: CircularProgressIndicator()),
            errorWidget: (context, string, object) => ColoredBox(
              color: TPColors.grayscale100, // 錯誤狀態下的背景色，也會被 ClipRRect 剪裁
              child: Center(
                child: Assets.svg.logoS.svg(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
