import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/route_manager.dart'; // 如果你使用 GetX 進行導航
import 'package:town_pass/page/lucky_draw/ui/animated_light_flow_background.dart';
import 'package:town_pass/page/lucky_draw/ui/lucky_draw_app_bar.dart';
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
    _listenShaking();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700), // 單向動畫持續時間
    );

    // 定義手從起始位置移動到中間（香爐上方）的動畫
    _handMovementAnimation = Tween<Offset>(
      begin: const Offset(0, -0.2), // 起始位置 (下方)
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
      Get.offAllNamed('/lucky_draw/welcome');
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
      appBar: const LuckyDrawAppBar(subtitle: '誠心奉香'),
      backgroundColor: TPColors.secondary50,
      body: AnimatedLightFlowBackground(
        backgroundColor: TPColors.secondary50,
        child: Center(
          child: Column(
            children: [
              GestureDetector(
                onTap: _onActionButtonPressed,
                child: _burnerAnimation,
              ),
              _instructionText,
              const SizedBox(height: 24),
              _nextStepButton,
            ],
          ),
        ),
      ),
    );
  }

  Widget get _burnerAnimation => Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 香爐圖片 (根據狀態切換)
          Image.asset(
            _incenseInserted
                ? 'assets/image/burner.png' // 有插香的香爐
                : 'assets/image/emptyburner.png', // 空的香爐
            height: 300,
            fit: BoxFit.cover,
          ),

          const SizedBox(height: 32),

          // 手部圖片及動畫
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform.translate(
                // 如果動畫序列已完成，手部保持在原始位置 (不偏移)
                // 否則，手部根據動畫進度移動
                offset: _isAnimationSequenceCompleted
                    ? const Offset(0, -0.2) * 200
                    : _handMovementAnimation.value * 200, // 動畫移動
                child: Opacity(
                  opacity: _isAnimating ? 1.0 : 1.0, // 動畫時和靜止時都顯示
                  child: Image.asset(
                    _handIsFolding
                        ? 'assets/image/foldinghand.png' // 雙手合十
                        : 'assets/image/holding.png', // 手拿香
                    height: 250,
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
        ],
      );

  Widget get _instructionText {
    if (_isAnimationSequenceCompleted) {
      return const Text(
        '奉香儀式已完成',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: TPColors.secondary800,
        ),
      );
    }

    if (_isAnimating) {
      return Text(
        _incenseInserted ? '雙手合十，誠心拜拜' : '誠心插香',
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: TPColors.secondary800,
        ),
      );
    }

    return const Text.rich(TextSpan(
      style: TextStyle(
        fontSize: 24,
        color: TPColors.secondary700,
      ),
      children: [
        TextSpan(
          text: '點擊香爐 ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: TPColors.secondary800,
          ),
        ),
        TextSpan(text: '進行奉香儀式'),
      ],
    ));
  }

  Widget get _nextStepButton {
    if (_isAnimating || !_isAnimationSequenceCompleted) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(children: [
        Expanded(
          child: TextButton(
            onPressed: () {},
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
                '前往供奉祭品',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        )
      ]),
    );
  }
}
