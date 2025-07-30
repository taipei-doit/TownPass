import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:town_pass/gen/assets.gen.dart';
import 'package:town_pass/page/home/widget/activity_info/activity_info_widget.dart';
import 'package:town_pass/page/home/widget/city_news/city_news_widget.dart';
import 'package:town_pass/page/home/widget/news/news_banner_widget.dart';
import 'package:town_pass/page/home/widget/subscription/subscription_widget.dart';
import 'package:town_pass/util/tp_app_bar.dart';
import 'package:town_pass/util/tp_colors.dart';
import 'package:town_pass/util/tp_route.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TPAppBar(
        showLogo: true,
        title: '首頁',
        leading: IconButton(
          icon: Semantics(
            label: '帳戶',
            child: Assets.svg.iconPerson.svg(),
          ),
          onPressed: () => Get.toNamed(TPRoute.account),
        ),
        backgroundColor: TPColors.white,
      ),
      body: const CustomScrollView(
        slivers: [
          _SliverSizedBox(height: 20),
          SliverToBoxAdapter(child: NewsBannerWidget()),
          _SliverSizedBox(height: 20),
          SliverToBoxAdapter(child: ActivityInfoWidget()),
          _SliverSizedBox(height: 8),
          SliverToBoxAdapter(child: CityNewsWidget()),
          _SliverSizedBox(height: 16),
          SliverToBoxAdapter(child: SubscriptionWidget()),
          _SliverSizedBox(height: 32),
        ],
      ),
    );
  }
}

class _SliverSizedBox extends StatelessWidget {
  const _SliverSizedBox({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(child: SizedBox(height: height));
  }
}
