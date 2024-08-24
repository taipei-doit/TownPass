import 'package:town_pass/gen/assets.gen.dart';
import 'package:town_pass/util/tp_app_bar.dart';
import 'package:town_pass/util/tp_card.dart';
import 'package:town_pass/util/tp_colors.dart';
import 'package:town_pass/util/tp_text.dart';
import 'package:flutter/material.dart';

class InvoiceReceiptView extends StatelessWidget {
  const InvoiceReceiptView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TPAppBar(
        title: '發票收據',
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: TPCard(
              child: Stack(
                children: [
                  const Positioned(
                    top: -20.0,
                    left: -20.0,
                    child: CircleAvatar(
                      radius: 50.0,
                      backgroundColor: TPColors.primary100,
                    ),
                  ),
                  Positioned(
                    top: 18.0,
                    left: 22.0,
                    child: Assets.svg.iconProtect.svg(),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        const TPText(
                          '發票收據',
                          style: TPTextStyles.h2SemiBold,
                          color: TPColors.primary500,
                        ),
                        const SizedBox(height: 4.0),
                        TPText(
                          '個資使用聲明',
                          style: TPTextStyles.h3Regular,
                          color: TPColors.grayscale700,
                        ),
                        const SizedBox(height: 32.0),
                        TPText(
                          '個資使用聲明可還地？時離地院。'
                          '命人資你別然書城很，是公麼級在！有真得劇那舉'
                          '等道。二一策他一馬才，著好難投集都從；識害興'
                          '水層過院頭大現鄉出石大報量大說，為他然家成長'
                          '球大看兒……顧果下只常進學影然，演強朋查電利景'
                          '，致過吸放情著人趣來受這直可；處教師長。環因'
                          '沒她常，讀場史生火分功帶出子資嚴程們是使是隊'
                          '年會手這作立死散的。升水育的演無言！於施數、'
                          '龍行不國般專新口色。實風選分到英企環行的藥著'
                          '斯國只',
                          style: TPTextStyles.h3Regular,
                          color: TPColors.grayscale700,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
