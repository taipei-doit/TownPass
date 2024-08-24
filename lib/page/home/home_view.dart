import 'package:town_pass/gen/assets.gen.dart';
import 'package:town_pass/page/home/widget/activity_info/activity_info_widget.dart';
import 'package:town_pass/page/home/widget/city_news/city_news_widget.dart';
import 'package:town_pass/page/home/widget/news/news_banner_widget.dart';
import 'package:town_pass/page/home/widget/subscription/subscription_widget.dart';
import 'package:town_pass/util/tp_app_bar.dart';
import 'package:town_pass/util/tp_colors.dart';
import 'package:town_pass/util/tp_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TPAppBar(
        showLogo: true,
        title: '首頁',
        leading: IconButton(
          icon: Assets.svg.iconPerson.svg(),
          onPressed: () => Get.toNamed(TPRoute.account),
        ),
        backgroundColor: TPColors.white,
      ),
      body: const CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: SizedBox(height: 20)),
          SliverToBoxAdapter(child: NewsBannerWidget()),
          SliverToBoxAdapter(child: SizedBox(height: 20)),
          SliverToBoxAdapter(child: ActivityInfoWidget()),
          SliverToBoxAdapter(child: SizedBox(height: 8)),
          SliverToBoxAdapter(child: CityNewsWidget()),
          SliverToBoxAdapter(child: SizedBox(height: 16)),
          SliverToBoxAdapter(child: SubscriptionWidget()),
        ],
      ),
    );
  }
}
