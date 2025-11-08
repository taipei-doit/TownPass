import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:town_pass/page/lucky_draw/data/lot_poems.dart';
import 'package:town_pass/page/lucky_draw/ui/lucky_draw_app_bar.dart';
import 'package:town_pass/util/tp_colors.dart';

class DrawResultPage extends StatefulWidget {
  final List<Map<String, String>>? poems;
  const DrawResultPage({super.key, this.poems});

  @override
  State<DrawResultPage> createState() => _DrawResultPageState();
}

class _DrawResultPageState extends State<DrawResultPage> {
  int selectedTab = 0; // 0 = 解籤, 1 = 白話文, 2 = 指引

  late int drawNumber;
  late Map<String, String> drawItem;

  @override
  void initState() {
    super.initState();
    _pickRandomDraw();
  }

  void _pickRandomDraw() {
    final rnd = Random();
    drawNumber = rnd.nextInt(60) + 1; // 1..60

    if (LotPoems.lotPoemsList.isNotEmpty) {
      final match = LotPoems.lotPoemsList.firstWhere(
        (p) => p.lot_number == drawNumber,
        orElse: () => LotPoems
            .lotPoemsList[(drawNumber - 1) % LotPoems.lotPoemsList.length],
      );
      drawItem = _mapFromLotPoems(match);
      return;
    }

    // fallback
    drawItem = _generateDrawItem(drawNumber);
  }

  Map<String, String> _mapFromLotPoems(LotPoems p) {
    return {
      'title': '第${p.lot_number}籤 ${p.sexagenary_cycle}',
      'grade': p.overall_score,
      'poem': p.oracle_poetry,
      'white_text': p.modern_white_text,
      'explanation': p.core_interpretation,
      'guide': p.action_advice,
    };
  }

  Map<String, String> _generateDrawItem(int n) {
    final grades = ['上上籤', '上籤', '中籤', '下籤'];
    final grade = grades[n % grades.length];
    final title = '第$n籤';
    final poem = '（籤詩 $n）花開今已結果，富貴榮華終到老，\n君子小人相會合，萬事清吉莫煩惱。';
    final shengYi = '聖意：此籤第 $n 節錄的詳解，可在此顯示具體聖意說明。';
    final guide = '指引：對應第 $n 節的建議與提醒。';

    return {
      'title': title,
      'grade': grade,
      'poem': poem,
      'shengyi': shengYi,
      'guide': guide,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const LuckyDrawAppBar(title: '解籤'),
      backgroundColor: TPColors.secondary50,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// --- TOP CARD ---
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: TPColors.secondary200,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              drawItem['title'] ?? '',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: TPColors.secondary800,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: TPColors.secondary700,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                drawItem['grade'] ?? '',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(
                          drawItem['poem'] ?? '',
                          style: const TextStyle(
                            fontSize: 18,
                            height: 1.6,
                            color: TPColors.secondary800,
                          ),
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  /// --- TABS ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildTabButton("解籤", 0),
                      _buildTabButton("白話文", 1),
                      _buildTabButton("指引", 2),
                    ],
                  ),

                  const SizedBox(height: 20),

                  /// --- TAB CONTENT ---
                  _buildTabContent(),
                ],
              ),
            ),
          ),

          /// Bottom button
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Get.toNamed('/lucky_draw/attractions'),
                style: TextButton.styleFrom(
                  backgroundColor: TPColors.secondary200,
                  foregroundColor: TPColors.secondary800,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    '前往宮廟進香參拜',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, int index) {
    bool isSelected = selectedTab == index;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        setState(() => selectedTab = index);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color:
                    isSelected ? TPColors.secondary700 : TPColors.grayscale400,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            const SizedBox(height: 6),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isSelected ? 40 : 0,
              height: 3,
              decoration: BoxDecoration(
                color: TPColors.secondary700,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (selectedTab) {
      case 1:
        return _buildWhiteText();
      case 2:
        return _buildGuideText();
      default:
        return _buildExplanationText();
    }
  }

  Widget _buildExplanationText() {
    return Text(
      drawItem['explanation'] ?? '',
      style: const TextStyle(
        fontSize: 16,
        height: 1.6,
        color: TPColors.secondary900,
      ),
    );
  }

  Widget _buildWhiteText() {
    return Text(
      drawItem['white_text'] ?? '',
      style: const TextStyle(
        fontSize: 16,
        height: 1.6,
        color: TPColors.secondary900,
      ),
    );
  }

  Widget _buildGuideText() {
    return Text(
      drawItem['guide'] ?? '',
      style: const TextStyle(
        fontSize: 16,
        height: 1.6,
        color: TPColors.secondary900,
      ),
    );
  }
}
