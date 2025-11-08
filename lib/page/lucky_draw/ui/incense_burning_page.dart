import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/route_manager.dart'; // 如果你使用 GetX 進行導航
import 'package:town_pass/util/tp_app_bar.dart';
import 'package:town_pass/util/tp_colors.dart';
import 'package:sensors_plus/sensors_plus.dart';


class IncenseBurningPage extends StatefulWidget {
  const IncenseBurningPage({super.key});

  @override
  State<IncenseBurningPage> createState() => _IncenseBurningPageState();
}

class _IncenseBurningPageState extends State<IncenseBurningPage>
    with SingleTickerProviderStateMixin {
  final _streamSubscription = <StreamSubscription<dynamic>>[];

  // 狀態變數
  bool _incenseInserted = false; // 紀錄香是否已插入 (用於切換香爐圖片)
  bool _isAnimating = false; // 判斷是否正在動畫中，避免重複點擊
  bool _handIsFolding = false; // 紀錄手部是否已切換為雙手合十
  bool _isAnimationSequenceCompleted = false; // 紀錄整個動畫序列是否已完成 (手已回到初始位置)


  // 動畫相關
  late AnimationController _animationController;
  late Animation<Offset> _handMovementAnimation; // 手的移動動畫
  get _shakingThreshold => Platform.isIOS ? 10.0 : 4.0;
  void _listenShaking() {
    final threshold = _shakingThreshold;

    _streamSubscription.add(
      userAccelerometerEventStream().listen((event) {
        final shakingValue = event.z.abs();
        final isShook = shakingValue > threshold;

        if (isShook) {
          _onActionButtonPressed();
        }
      }),
    );
  }
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700), // 單向動畫持續時間
    );

    // 定義手從起始位置移動到中間（香爐上方）的動畫
    _handMovementAnimation = Tween<Offset>(
      begin: const Offset(0, -0.5), // 起始位置 (下方)
      end: const Offset(0, -1.5), // 結束位置 (香爐中心略上方) - 根據UI調整
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic, // 更平滑自然的曲線
    ));

    // 監聽動畫狀態變化
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // 動畫到達終點（手在香爐上方），切換圖片，然後反向移動
        setState(() {
          _incenseInserted = true; // 香已插入，切換香爐圖片
          _handIsFolding = true; // 手部切換為雙手合十
        });
        Future.delayed(const Duration(milliseconds: 300), () {
          // 短暫延遲後，讓手移動回初始位置
          _animationController.reverse();
        });
      } else if (status == AnimationStatus.dismissed) {
        // 動畫回到起始點（手已回到下方）
        setState(() {
          _isAnimating = false; // 動畫結束
          _isAnimationSequenceCompleted = true; // 標記整個動畫序列已完成
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('誠心奉香儀式已完成！'),
            backgroundColor: Colors.blueGrey,
          ),
        );
      }
    });
  }

  void _onActionButtonPressed() {
    if (_isAnimating) return; // 動畫中禁用按鈕

    if (!_isAnimationSequenceCompleted) {
      // 執行插香和拜拜動畫
      setState(() {
        _isAnimating = true; // 啟動動畫標誌
      });
      _animationController.forward(); // 啟動手部移動動畫
    } else {
      // 動畫已完成，現在按鈕是「完成並返回」，點擊後離開頁面
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('功德圓滿，返回上一頁。'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context); // 返回上一頁
      // 如果使用 GetX: Get.back();
    }
  }

  @override
  void dispose() {
    _animationController.dispose(); // 釋放動畫控制器
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TPAppBar(
        title: '城心誠靈 - 誠心奉香',
        backgroundColor: TPColors.secondary50,
      ),
      backgroundColor: TPColors.secondary50,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),

                    // 說明文字
                    Text(
                      _isAnimationSequenceCompleted
                          ? "奉香儀式已完成"
                          : (_isAnimating
                              ? (_incenseInserted ? "雙手合十，誠心拜拜" : "誠心插香")
                              : "點擊按鈕，將香插入爐中"),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        color: Color(0xFF4D3A2A),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _isAnimationSequenceCompleted
                          ? "點擊下方按鈕，返回抽籤頁面"
                          : (_isAnimating
                              ? (_incenseInserted ? "雙手合十，完成儀式" : "香將插入香爐")
                              : "一次點擊完成奉香動畫"),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF4D3A2A),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // 香爐圖片 (根據狀態切換)
                    Image.asset(
                      _incenseInserted
                          ? 'assets/image/burner.png' // 有插香的香爐
                          : 'assets/image/emptyburner.png', // 空的香爐
                      width: 350,
                      height: 350,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 350,
                        height: 350,
                        color: Colors.grey,
                        child: const Center(child: Text('香爐圖片載入失敗')),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // 手部圖片及動畫
                    AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return Transform.translate(
                          // 如果動畫序列已完成，手部保持在原始位置 (下方)
                          // 否則，手部根據動畫進度移動
                          offset: _isAnimationSequenceCompleted
                              ? const Offset(0, -0.5) * 200 // 固定在下方
                              : _handMovementAnimation.value * 200, // 動畫移動
                          child: Opacity(
                            opacity: _isAnimating ? 1.0 : 1.0, // 動畫時和靜止時都顯示
                            child: Image.asset(
                              _handIsFolding
                                  ? 'assets/image/foldinghand.png' // 雙手合十
                                  : 'assets/image/holding.png', // 手拿香
                              width: 250,
                              height: 250,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                width: 250,
                                height: 250,
                                color: Colors.grey,
                                child: const Center(child: Text('手部圖片載入失敗')),
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // 底部操作按鈕
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed:
                      _isAnimating ? null : _onActionButtonPressed, // 動畫中禁用按鈕
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isAnimating
                        ? Colors.grey // 動畫中變灰色
                        : (_isAnimationSequenceCompleted
                            ? const Color(0xFFD6A565) // 完成後的顏色
                            : const Color(0xFFB54F43)), // 初始按鈕顏色
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: Text(
                    _isAnimating
                        ? "儀式進行中..."
                        : (_isAnimationSequenceCompleted ? "完成並返回" : "誠心奉香"),
                    style: const TextStyle(fontSize: 18, color: Colors.white),
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
