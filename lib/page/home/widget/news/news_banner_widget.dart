import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:town_pass/page/home/widget/news/news_banner_widget_controller.dart';
import 'package:town_pass/util/tp_colors.dart';
import 'package:town_pass/util/tp_route.dart';

class NewsBannerWidget extends StatelessWidget {
  const NewsBannerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: Get.put<NewsBannerWidgetController>(NewsBannerWidgetController()),
      builder: (controller) {
        if (controller.isLoading) {
          return Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _BannerRectangle(),
                const SizedBox(height: 8),
                SizedBox(
                  height: 8,
                  child: Center(
                    child: ListView.separated(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemCount: 3,
                      itemBuilder: (_, index) => const _DotIndicator(),
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            CarouselSlider(
              carouselController: controller.controller,
              options: CarouselOptions(
                height: 173.5,
                viewportFraction: 1,
                autoPlay: true,
                onPageChanged: (index, _) => controller.carouselIndex = index,
              ),
              items: controller.list?.data.map<Widget>(
                    (item) {
                      return GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () async => await TPRoute.openUri(uri: item.webUrl),
                        child: Semantics(
                          label: item.title,
                          child: _BannerRectangle(
                            child: CachedNetworkImage(
                              imageUrl: item.imageUrl,
                              height: double.infinity,
                              width: double.infinity,
                              fit: BoxFit.fitWidth,
                              placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator(
                                  color: TPColors.primary500,
                                ),
                              ),
                              errorWidget: (context, url, error) => const Icon(Icons.error),
                            ),
                          ),
                        ),
                      );
                    },
                  ).toList() ??
                  <Widget>[],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 8,
              child: ListView.separated(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemCount: controller.list?.data.length ?? 0,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, index) => _DotIndicator(isSelected: controller.carouselIndex == index),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _BannerRectangle extends StatelessWidget {
  final Widget? child;

  const _BannerRectangle({this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 173.5,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          color: TPColors.white,
        ),
        clipBehavior: Clip.antiAlias,
        child: child,
      ),
    );
  }
}

class _DotIndicator extends StatelessWidget {
  final bool isSelected;

  const _DotIndicator({this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 4,
      backgroundColor: switch (isSelected) {
        true => const Color(0xFF5AB4C5),
        false => const Color(0xFFADB8BE),
      },
    );
  }
}
