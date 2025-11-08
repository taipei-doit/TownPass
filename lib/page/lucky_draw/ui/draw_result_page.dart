import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';

class DrawResultPage extends StatefulWidget {
  const DrawResultPage();

  @override
  State<DrawResultPage> createState() => _DrawResultPageState();
}

class _DrawResultPageState extends State<DrawResultPage> {
  int selectedTab = 0; // 0 = 解籤, 1 = 聖意, 2 = 指引

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F3EB),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// --- TOP CARD ---
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2EAD4),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "第十五籤",
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF7A6A54),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD6C1A3),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              "上上籤",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            "花開今已結果，富貴榮華終到老，\n君子小人相會合，萬事清吉莫煩惱。",
                            style: TextStyle(
                              fontSize: 20,
                              height: 1.6,
                              color: Color(0xFF4D3A2A),
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
                        _buildTabButton("聖意", 1),
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
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Get.toNamed('/lucky_draw/welcome');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD6A565),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    "解籤",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            )
          ],
        ),
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
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: isSelected ? const Color(0xFFB07A3F) : Colors.grey,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            const SizedBox(height: 6),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isSelected ? 40 : 0,
              height: 3,
              decoration: BoxDecoration(
                color: const Color(0xFFB07A3F),
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
        return _buildShengYiText();
      case 2:
        return _buildGuideText();
      default:
        return _buildExplanationText();
    }
  }

  Widget _buildExplanationText() {
    return const Text(
      "此籤寓意著努力已有成果，未來將會富貴榮華、安享晚年。不論是君子或小人，"
      "都能和睦相處，所有事情都會順利解決，不必過於煩惱。\n\n"
      "這是一個充滿希望和肯定的預示，表示過去的辛勞和付出即將開花結果。生活將進入"
      "一個穩定、富足且和諧的階段。人際關係方面，無論是益友還是普通交往的人，都能夠"
      "和睦共處，這將為您的事業和生活帶來極大的便利和順遂。總體而言，這是一個極佳的徵兆，"
      "鼓勵您放下憂慮，以積極樂觀的心態迎接美好的未來。",
      style: TextStyle(
        fontSize: 16,
        height: 1.6,
        color: Color(0xFF4D3A2A),
      ),
    );
  }

  Widget _buildShengYiText() {
    return const Text(
      "聖意內容可放在這裡 — 依照你的資料填入。",
      style: TextStyle(
        fontSize: 16,
        height: 1.6,
        color: Color(0xFF4D3A2A),
      ),
    );
  }

  Widget _buildGuideText() {
    return const Text(
      "指引內容可放在這裡 — 依照你的資料填入。",
      style: TextStyle(
        fontSize: 16,
        height: 1.6,
        color: Color(0xFF4D3A2A),
      ),
    );
  }
}
