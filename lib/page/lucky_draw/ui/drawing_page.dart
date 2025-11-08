import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:town_pass/util/tp_app_bar.dart';
import 'package:town_pass/util/tp_colors.dart';

class DrawingPage extends StatefulWidget {
  const DrawingPage({super.key});

  @override
  State<DrawingPage> createState() => _DrawingPageState();
}

class _DrawingPageState extends State<DrawingPage> {
  final _streamSubscription = <StreamSubscription<dynamic>>[];

  @override
  void initState() {
    super.initState();
    _shakeListen();
  }

  _shakeListen() {
    const threshold = 10.0;

    _streamSubscription.add(
      userAccelerometerEventStream().listen((event) {
        final shook = event.x.abs() > threshold ||
            event.y.abs() > threshold ||
            event.z.abs() > threshold;

        if (shook) {
          // print("Device shaken!");
          _navigateOnce();
        }
      }),
    );
  }

  bool _navigated = false;

  void _navigateOnce() {
    if (_navigated) return; // avoid repeated navigation
    _navigated = true;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const _StickResultPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TPAppBar(
        title: '城心誠靈 - Draw a Stick',
        backgroundColor: TPColors.secondary50,
      ),
      backgroundColor: TPColors.secondary50,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Image
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: GestureDetector(
                onTap: () {
                  // TODO: handle tap
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/image/lots.png', // your image here
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Title
            const Text(
              "Shake your phone \n or tap the holder to draw",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                color: Color(0xFF4D3A2A),
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 12),

            const Text(
              "搖動手機或點擊籤筒來抽籤",
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF4D3A2A),
              ),
            ),

            const SizedBox(height: 40),

            // Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const _StickResultPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB54F43), // red color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: const Text(
                    "Draw a Stick",
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
}

class _StickResultPage extends StatefulWidget {
  const _StickResultPage();

  @override
  State<_StickResultPage> createState() => _StickResultPageState();
}

class _StickResultPageState extends State<_StickResultPage> {
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
                    /// --- TOP CARD ----------------------------------------------------------
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

                    /// --- TABS: 解籤 / 聖意 / 指引 -----------------------------------------
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildTabButton("解籤", 0),
                        _buildTabButton("聖意", 1),
                        _buildTabButton("指引", 2),
                      ],
                    ),

                    const SizedBox(height: 20),

                    /// --- TAB CONTENT -------------------------------------------------------
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
                    Navigator.pop(context);
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
      behavior:
          HitTestBehavior.translucent, // ✅ catches taps even outside child
      onTap: () {
        setState(() => selectedTab = index);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 12), // ✅ bigger hitbox
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

  /// --- TAB CONTENT BASED ON SELECTED TAB ---
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

  /// Content for lots explanation
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

  /// Content for shengyi
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

  /// Content for guide
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
