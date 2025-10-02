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
    // 原始實作中，borderRadius 僅應用於外部 Container 的 ShapeDecoration，
    // 可能導致圖片本身溢出圓角邊緣。
    // 此處改用 ClipRRect 包裹實際的圖片內容，確保圖片、預載動畫及錯誤圖片
    // 都能正確遵循 borderRadius 進行剪裁。
    // 同時將背景色 (color) 移至 ClipRRect 內的 Container，確保它作為
    // 圓角區域的背景色，而非外部容器的背景，提升邏輯一致性。
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
            placeholder: (context, string) => const Center(child: CircularProgressIndicator()),
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