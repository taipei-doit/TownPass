import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:town_pass/gen/assets.gen.dart';
import 'package:town_pass/page/game/widget/game_landing.dart';
import 'package:town_pass/util/tp_app_bar.dart';
import 'package:town_pass/util/tp_colors.dart';
import 'package:town_pass/util/tp_text.dart';

class GameView extends StatefulWidget {
  const GameView({super.key});

  @override
  State<GameView> createState() => _GameViewState();
}

class _GameViewState extends State<GameView> {
  final Random _random = Random();
  late final AudioPlayer _bgmPlayer;
  int _currentIndex = 0;
  bool _hasStartedGame = false;
  bool _hasGuessed = false;
  bool _isCorrect = false;
  String? _selectedOption;

  @override
  void initState() {
    super.initState();
    _currentIndex = _random.nextInt(_locations.length);
    _bgmPlayer = AudioPlayer();
    _startBgm();
    // Log player state changes to help debug emulator audio issues
    _bgmPlayer.onPlayerStateChanged.listen((state) {
      debugPrint('BGM player state: $state');
    });
    _bgmPlayer.onPlayerComplete.listen((_) {
      debugPrint('BGM playback completed');
    });
  }

  Future<void> _startBgm() async {
    try {
      // Quick check: try loading the asset bytes to ensure it's packaged
      try {
        final data = await rootBundle.load('audio/bgm.mp3');
        debugPrint('BGM asset loaded, size=${data.lengthInBytes} bytes');
      } catch (err) {
        debugPrint('BGM asset load failed: $err');
      }
      // Loop the background music
      await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
  // Play asset. Path must match pubspec asset entry (no leading slash).
  // The asset is declared as `lib/page/game/audio/` in pubspec.yaml
      debugPrint('Attempting to play BGM asset...');
      await _bgmPlayer.play(AssetSource('audio/bgm.mp3'), volume: 0.6);
      debugPrint('BGM play() awaited without exception');
    } catch (e) {
      // ignore audio errors silently for now
      debugPrint('BGM play error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final _GeoLocation current = _locations[_currentIndex];
    return Scaffold(
      backgroundColor: TPColors.white,
      appBar: TPAppBar(
        showLogo: true,
        title: 'Taipei Guessr',
        leading: IconButton(
          icon: Semantics(
            label: '返回上一頁',
            child: Assets.svg.iconRemove.svg(),
          ),
          onPressed: () => Get.back<void>(),
        ),
        actions: [
          if (_hasStartedGame)
            IconButton(
              icon: Semantics(
                label: '遊戲介紹',
                child: const Icon(
                  Icons.info_outline,
                  size: 26,
                  color: TPColors.grayscale700,
                ),
              ),
              onPressed: _showGameInfo,
            )
          else
            const SizedBox(width: 56),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
        child: _hasStartedGame
            ? _GameBoard(
                current: current,
                hasGuessed: _hasGuessed,
                isCorrect: _isCorrect,
                selectedOption: _selectedOption,
                onOptionSelected: _onOptionSelected,
                onNextRound: _nextRound,
              )
            : GameLanding(onStart: _startGame),
      ),
    );
  }

  void _startGame() {
    setState(() {
      _hasStartedGame = true;
    });
  }

  void _onOptionSelected(String option) {
    if (_hasGuessed) {
      return;
    }
    final bool correct = option == _locations[_currentIndex].name;
    setState(() {
      _selectedOption = option;
      _hasGuessed = true;
      _isCorrect = correct;
    });
  }

  void _nextRound() {
    setState(() {
      _currentIndex = _random.nextInt(_locations.length);
      _selectedOption = null;
      _hasGuessed = false;
      _isCorrect = false;
    });
  }

  void _showGameInfo() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const TPText(
          'Taipei Guessr 遊戲說明',
          style: TPTextStyles.h3SemiBold,
          color: TPColors.grayscale900,
        ),
        content: const TPText(
          '遊戲會顯示一張臺北景點的圖片。\n你的任務是從下方四張圖片中，判斷哪一個景點的「實際地理位置」與上方景點最為接近。\n點擊你認為最接近的答案，看看你對台北了解多少！\n',
          color: TPColors.grayscale700,
        ),
        actionsPadding: const EdgeInsets.only(right: 12, bottom: 8),
        actions: [
          TextButton(
            onPressed: () => Get.back<void>(),
            child: const TPText(
              '開始玩',
              style: TPTextStyles.h3SemiBold,
              color: TPColors.primary500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _bgmPlayer.dispose();
    super.dispose();
  }

  static const List<_GeoLocation> _locations = [
    _GeoLocation(
      name: '台北101',
      district: '信義區',
      clue: '在高空觀景台就能欣賞整個信義計畫區夜景，附近緊鄰市府與百貨商圈。',
      options: ['台北101', '士林官邸', '大稻埕碼頭'],
    ),
    _GeoLocation(
      name: '大稻埕碼頭',
      district: '大同區',
      clue: '沿著淡水河畔騎車欣賞夕陽，附近有貨櫃市集與復古商店。',
      options: ['西門紅樓', '大稻埕碼頭', '松山文創園區'],
    ),
    _GeoLocation(
      name: '貓空纜車',
      district: '文山區',
      clue: '透明車廂讓你俯瞰茶園，終點可以品茶看夜景。',
      options: ['象山步道', '貓空纜車', '北投溫泉'],
    ),
    _GeoLocation(
      name: '北投溫泉博物館',
      district: '北投區',
      clue: '洋式紅磚建築改建而成的溫泉展館，周邊瀰漫著硫磺氣味。',
      options: ['北投溫泉博物館', '剝皮寮老街', '松菸誠品'],
    ),
  ];
}

class _GeoLocation {
  const _GeoLocation({
    required this.name,
    required this.district,
    required this.clue,
    required this.options,
  });

  final String name;
  final String district;
  final String clue;
  final List<String> options;
}

class _GameBoard extends StatelessWidget {
  const _GameBoard({
    required this.current,
    required this.hasGuessed,
    required this.isCorrect,
    required this.selectedOption,
    required this.onOptionSelected,
    required this.onNextRound,
  });

  final _GeoLocation current;
  final bool hasGuessed;
  final bool isCorrect;
  final String? selectedOption;
  final void Function(String option) onOptionSelected;
  final VoidCallback onNextRound;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _GeoGuessPreview(location: current),
        const SizedBox(height: 16),
        _GameClue(location: current),
        const SizedBox(height: 24),
        TPText(
          '猜你在哪裡？',
          style: TPTextStyles.h3SemiBold,
          color: TPColors.grayscale900,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: current.options
              .map(
                (option) => _GuessChip(
                  label: option,
                  selected: selectedOption == option,
                  disabled: hasGuessed,
                  isCorrectOption: option == current.name,
                  showResult: hasGuessed,
                  onTap: () => onOptionSelected(option),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 24),
        if (hasGuessed)
          _ResultBanner(
            isCorrect: isCorrect,
            correctAnswer: current.name,
          ),
        const Spacer(),
        SizedBox(
          height: 48,
          child: ElevatedButton(
            onPressed: hasGuessed ? onNextRound : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: TPColors.primary500,
              disabledBackgroundColor: TPColors.grayscale200,
            ),
            child: TPText(
              hasGuessed ? '換一個地點' : '先選擇一個地點',
              style: TPTextStyles.h3SemiBold,
              color: TPColors.white,
            ),
          ),
        ),
      ],
    );
  }
}

class _GeoGuessPreview extends StatelessWidget {
  const _GeoGuessPreview({required this.location});

  final _GeoLocation location;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [Color(0xFF16374F), Color(0xFF0D1F2C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: 0.1,
                child: Assets.svg.iconMunicipalNavigation.svg(),
              ),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.explore, color: TPColors.white, size: 48),
                  const SizedBox(height: 12),
                  TPText(
                    location.district,
                    style: TPTextStyles.h3SemiBold,
                    color: TPColors.white,
                  ),
                  const SizedBox(height: 4),
                  const TPText(
                    '猜猜這是哪個地點',
                    style: TPTextStyles.bodyRegular,
                    color: TPColors.white,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GameClue extends StatelessWidget {
  const _GameClue({required this.location});

  final _GeoLocation location;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TPColors.grayscale50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.lightbulb_outline, color: TPColors.primary500),
              SizedBox(width: 8),
              TPText(
                '線索',
                style: TPTextStyles.h3SemiBold,
                color: TPColors.grayscale900,
              ),
            ],
          ),
          const SizedBox(height: 8),
          TPText(
            location.clue,
            style: TPTextStyles.bodyRegular,
            color: TPColors.grayscale700,
          ),
        ],
      ),
    );
  }
}

class _GuessChip extends StatelessWidget {
  const _GuessChip({
    required this.label,
    required this.selected,
    required this.disabled,
    required this.isCorrectOption,
    required this.showResult,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool disabled;
  final bool isCorrectOption;
  final bool showResult;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool highlightCorrect = showResult && isCorrectOption;
    final bool highlightWrong = showResult && selected && !isCorrectOption;

    Color borderColor = TPColors.grayscale200;
    Color background = TPColors.white;
    Color textColor = TPColors.grayscale900;

    if (selected && !showResult) {
      borderColor = TPColors.primary500;
      background = TPColors.primary50;
      textColor = TPColors.primary500;
    } else if (highlightCorrect) {
      borderColor = TPColors.primary500;
      background = TPColors.primary50;
      textColor = TPColors.primary500;
    } else if (highlightWrong) {
      borderColor = TPColors.red500;
      background = TPColors.red50;
      textColor = TPColors.red500;
    }

    return GestureDetector(
      onTap: disabled ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: borderColor),
        ),
        child: TPText(
          label,
          style: TPTextStyles.bodySemiBold,
          color: textColor,
        ),
      ),
    );
  }
}

class _ResultBanner extends StatelessWidget {
  const _ResultBanner({required this.isCorrect, required this.correctAnswer});

  final bool isCorrect;
  final String correctAnswer;

  @override
  Widget build(BuildContext context) {
    final Color background = isCorrect ? TPColors.primary50 : TPColors.red50;
    final Color textColor = isCorrect ? TPColors.primary500 : TPColors.red500;
    final IconData icon = isCorrect ? Icons.emoji_events : Icons.close;
    final String title = isCorrect ? '答對了！' : '再接再厲';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: textColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TPText(
                  title,
                  style: TPTextStyles.h3SemiBold,
                  color: textColor,
                ),
                const SizedBox(height: 4),
                TPText(
                  '正確答案：$correctAnswer',
                  style: TPTextStyles.bodyRegular,
                  color: textColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
