import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/instance_manager.dart';
import 'package:town_pass/page/lucky_draw/ui/animated_light_flow_background.dart';
import 'package:town_pass/page/lucky_draw/ui/lucky_draw_app_bar.dart';
import 'package:town_pass/util/tp_colors.dart';

enum JiaobeiResult {
  shengJiao, // 聖筊 - 一陽一陰
  xiaoJiao, // 笑筊 - 兩陽
  kuJiao, // 哭筊 - 兩陰
}

class JiaobeiThrowingPage extends StatefulWidget {
  const JiaobeiThrowingPage({super.key});

  @override
  State<JiaobeiThrowingPage> createState() => _JiaobeiThrowingPageState();
}

class _JiaobeiThrowingPageState extends State<JiaobeiThrowingPage>
    with TickerProviderStateMixin {
  late AnimationController _leftController;
  late AnimationController _rightController;
  late Animation<double> _leftRotation;
  late Animation<double> _rightRotation;
  late Animation<double> _leftVerticalPosition;
  late Animation<double> _rightVerticalPosition;
  late Animation<double> _leftHorizontalPosition;
  late Animation<double> _rightHorizontalPosition;
  late Animation<double> _leftScale;
  late Animation<double> _rightScale;

  bool _isThrowingLeft = true; // 左邊筊杯是否為陽面
  bool _isThrowingRight = true; // 右邊筊杯是否為陽面
  bool _isAnimating = false;
  JiaobeiResult? _result;

  final Random _random = Random();

  // 用於控制隨機變換的計時器
  int _flipCount = 0;
  static const int _totalFlips = 20; // 總共變換次數
  static const int _flipIntervalMs = 25; // 每次變換間隔（毫秒）

  // 拋物線軌跡參數
  late double _leftThrowAngle;
  late double _rightThrowAngle;

  // 最終靜止時的旋轉角度
  late double _leftFinalRotation;
  late double _rightFinalRotation;

  @override
  void initState() {
    super.initState();

    // 初始化拋物線角度和最終旋轉角度
    _leftThrowAngle = 0;
    _rightThrowAngle = 0;
    _leftFinalRotation = 0;
    _rightFinalRotation = 0;

    // 左邊筊杯動畫控制器
    _leftController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );

    // 右邊筊杯動畫控制器
    _rightController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );

    _initializeAnimations();

    _leftController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // 確保動畫值保持在最終狀態
        _leftController.stop();
        _rightController.stop();
        setState(() {
          _isAnimating = false;
          _calculateResult();
        });
      }
    });
  }

  void _initializeAnimations() {
    // 旋轉動畫 - 更多圈數，並加上最終隨機角度
    _leftRotation = Tween<double>(
      begin: 0,
      end: 10 * pi + _leftFinalRotation,
    ).animate(
      CurvedAnimation(parent: _leftController, curve: Curves.easeOut),
    );

    _rightRotation = Tween<double>(
      begin: 0,
      end: 10 * pi + _rightFinalRotation,
    ).animate(
      CurvedAnimation(parent: _rightController, curve: Curves.easeOut),
    );

    // 垂直位置動畫 - 拋物線效果（向上再落下）
    _leftVerticalPosition = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: -200)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -200, end: 0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 60,
      ),
    ]).animate(_leftController);

    _rightVerticalPosition = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: -220)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -220, end: 0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 60,
      ),
    ]).animate(_rightController);

    // 水平位置動畫 - 左右拋出軌跡
    _leftHorizontalPosition = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: _leftThrowAngle)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: _leftThrowAngle, end: 0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
    ]).animate(_leftController);

    _rightHorizontalPosition = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: _rightThrowAngle)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: _rightThrowAngle, end: 0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
    ]).animate(_rightController);

    // 大小縮放動畫 - 遠近效果
    _leftScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.3)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.3, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 60,
      ),
    ]).animate(_leftController);

    _rightScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.4)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.4, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 60,
      ),
    ]).animate(_rightController);
  }

  @override
  void dispose() {
    _leftController.dispose();
    _rightController.dispose();
    super.dispose();
  }

  void _throwJiaobei() {
    if (_isAnimating || _result != null) return;

    setState(() {
      _isAnimating = true;
      _result = null;
      _flipCount = 0;

      // 隨機生成拋出角度（左邊向左，右邊向右）
      _leftThrowAngle = -30 - _random.nextDouble() * 40; // -30 到 -70
      _rightThrowAngle = 30 + _random.nextDouble() * 40; // 30 到 70

      // 隨機生成最終靜止時的旋轉角度（-30° 到 30°）
      _leftFinalRotation = (_random.nextDouble() - 0.5) * pi / 3; // -π/6 到 π/6
      _rightFinalRotation = (_random.nextDouble() - 0.5) * pi / 3; // -π/6 到 π/6
    });

    // 重新初始化動畫以使用新的拋出角度和最終旋轉角度
    _initializeAnimations();

    _leftController.reset();
    _rightController.reset();
    _leftController.forward();
    _rightController.forward();

    // 開始隨機變換
    _startRandomFlipping();
  }

  void _startRandomFlipping() {
    // 在動畫過程中持續隨機變換正反面
    Future.delayed(const Duration(milliseconds: _flipIntervalMs), () {
      if (_flipCount < _totalFlips && _isAnimating) {
        setState(() {
          _isThrowingLeft = _random.nextBool();
          _isThrowingRight = _random.nextBool();
          _flipCount++;
        });
        _startRandomFlipping();
      } else if (_flipCount >= _totalFlips) {
        // 變換結束，確定最終結果
        setState(() {
          _isThrowingLeft = _random.nextBool();
          _isThrowingRight = _random.nextBool();
        });
      }
    });
  }

  void _calculateResult() {
    if (_isThrowingLeft && !_isThrowingRight) {
      _result = JiaobeiResult.shengJiao; // 一陽一陰
    } else if (!_isThrowingLeft && _isThrowingRight) {
      _result = JiaobeiResult.shengJiao; // 一陽一陰
    } else if (_isThrowingLeft && _isThrowingRight) {
      _result = JiaobeiResult.xiaoJiao; // 兩陽
    } else {
      _result = JiaobeiResult.kuJiao; // 兩陰
    }
  }

  String _getResultText() {
    switch (_result) {
      case JiaobeiResult.shengJiao:
        return '聖筊';
      case JiaobeiResult.xiaoJiao:
        return '笑筊';
      case JiaobeiResult.kuJiao:
        return '哭筊';
      default:
        return '';
    }
  }

  String _getResultDescription() {
    switch (_result) {
      case JiaobeiResult.shengJiao:
        return '一陽一陰，神明同意';
      case JiaobeiResult.xiaoJiao:
        return '兩面皆陽，神明發笑';
      case JiaobeiResult.kuJiao:
        return '兩面皆陰，神明不允';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const LuckyDrawAppBar(subtitle: '搖一搖擲筊'),
      body: AnimatedLightFlowBackground(
        backgroundColor: TPColors.secondary50,
        child: Column(
          children: [
            _jiaobeiAnimation,
            const SizedBox(height: 72),
            _instructionText,
            const SizedBox(height: 24),
            _result != null && !_isAnimating
                ? _nextStepButton
                : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  Widget get _jiaobeiAnimation => Column(children: [
        Padding(
          padding: const EdgeInsets.only(top: 300),
          child: GestureDetector(
            onTap: _throwJiaobei,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 左邊筊杯
                _isAnimating
                    ? AnimatedBuilder(
                        animation: _leftController,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(
                              _leftHorizontalPosition.value,
                              _leftVerticalPosition.value,
                            ),
                            child: Transform.scale(
                              scale: _leftScale.value,
                              child: Transform.rotate(
                                angle: _leftRotation.value,
                                child: SvgPicture.asset(
                                  _isThrowingLeft
                                      ? 'assets/svg/jiaobei/pos_left.svg'
                                      : 'assets/svg/jiaobei/neg_left.svg',
                                  width: 100,
                                  height: 100,
                                ),
                              ),
                            ),
                          );
                        },
                      )
                    : Transform.rotate(
                        angle: _leftFinalRotation,
                        child: SvgPicture.asset(
                          _isThrowingLeft
                              ? 'assets/svg/jiaobei/pos_left.svg'
                              : 'assets/svg/jiaobei/neg_left.svg',
                          width: 100,
                          height: 100,
                        ),
                      ),
                const SizedBox(width: 12),
                // 右邊筊杯
                _isAnimating
                    ? AnimatedBuilder(
                        animation: _rightController,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(
                              _rightHorizontalPosition.value,
                              _rightVerticalPosition.value,
                            ),
                            child: Transform.scale(
                              scale: _rightScale.value,
                              child: Transform.rotate(
                                angle: _rightRotation.value,
                                child: SvgPicture.asset(
                                  _isThrowingRight
                                      ? 'assets/svg/jiaobei/pos_right.svg'
                                      : 'assets/svg/jiaobei/neg_right.svg',
                                  width: 100,
                                  height: 100,
                                ),
                              ),
                            ),
                          );
                        },
                      )
                    : Transform.rotate(
                        angle: _rightFinalRotation,
                        child: SvgPicture.asset(
                          _isThrowingRight
                              ? 'assets/svg/jiaobei/pos_right.svg'
                              : 'assets/svg/jiaobei/neg_right.svg',
                          width: 100,
                          height: 100,
                        ),
                      ),
              ],
            ),
          ),
        ),
      ]);

  Widget get _nextStepButton {
    if (_result == null) {
      return const SizedBox.shrink();
    }

    final isSuccessful = _result == JiaobeiResult.shengJiao;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(children: [
        Expanded(
          child: TextButton(
            onPressed: isSuccessful
                ? () => Get.offAndToNamed('/lucky_draw/draw_result')
                : () => Get.back(),
            style: TextButton.styleFrom(
              backgroundColor: TPColors.secondary200,
              foregroundColor: TPColors.secondary800,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                isSuccessful ? '前往解籤' : '返回重新求籤',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ),
      ]),
    );
  }

  Widget get _instructionText {
    if (_isAnimating) {
      return const Text(
        '擲筊中...',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: TPColors.secondary800,
        ),
      );
    }

    if (_result != null) {
      return Text.rich(TextSpan(
        style: const TextStyle(
          fontSize: 24,
          color: TPColors.secondary700,
        ),
        children: [
          TextSpan(
            text: _getResultText(),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: TPColors.secondary800,
            ),
          ),
          TextSpan(text: '  ${_getResultDescription()}'),
        ],
      ));
    }

    return const Text.rich(
      TextSpan(
        style: TextStyle(
          fontSize: 24,
          color: TPColors.secondary700,
        ),
        children: [
          TextSpan(
            text: "搖動手機 ",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: TPColors.secondary800,
            ),
          ),
          TextSpan(text: "或"),
          TextSpan(
            text: " 點擊筊杯 ",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: TPColors.secondary800,
            ),
          ),
          TextSpan(text: "開始擲筊\n向神明請示此籤是否為您所求"),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
