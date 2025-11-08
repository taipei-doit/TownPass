import 'package:cached_network_image/cached_network_image.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:town_pass/gen/assets.gen.dart';
import 'package:town_pass/page/game/model/game_question.dart';
import 'package:town_pass/page/game/service/attraction_service.dart';
import 'package:town_pass/page/game/widget/game_landing.dart';
import 'package:town_pass/util/tp_app_bar.dart';
import 'package:town_pass/util/tp_colors.dart';
import 'package:town_pass/util/tp_text.dart';
import 'package:town_pass/util/tp_text_styles.dart';

enum _GamePhase { landing, loading, playing, error }

class GameView extends StatefulWidget {
  const GameView({super.key});

  @override
  State<GameView> createState() => _GameViewState();
}

class _GameViewState extends State<GameView> {
  final AttractionService _service = AttractionService();

  _GamePhase _phase = _GamePhase.landing;
  late final AudioPlayer _bgmPlayer;
  GameQuestion? _currentQuestion;
  int _lives = 3;
  bool _hasGuessed = false;
  bool _isCorrectGuess = false;
  int? _selectedIndex;
  String? _errorMessage;

  @override
  void initState(){
    super.initState();
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

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
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
    Widget child;
    switch (_phase) {
      case _GamePhase.landing:
        child = GameLanding(onStart: _startGame);
        break;
      case _GamePhase.loading:
        child = const Center(child: CircularProgressIndicator());
        break;
      case _GamePhase.error:
        child = _ErrorState(
          message: _errorMessage ?? '載入題目時發生問題，請稍後再試。',
          onRetry: () => _loadNextQuestion(),
        );
        break;
      case _GamePhase.playing:
        if (_currentQuestion == null) {
          child = const Center(child: CircularProgressIndicator());
        } else {
          child = _GameBoard(
            question: _currentQuestion!,
            lives: _lives,
            hasGuessed: _hasGuessed,
            isCorrect: _isCorrectGuess,
            selectedIndex: _selectedIndex,
            onOptionTap: _handleOptionSelected,
            onNext: _handleNextPressed,
          );
        }
        break;
    }

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
          if (_phase == _GamePhase.playing)
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
        child: child,
      ),
    );
  }

  void _startGame() {
    _loadNextQuestion(resetLives: true);
  }

  Future<void> _loadNextQuestion({bool resetLives = false}) async {
    if (resetLives) {
      _lives = 3;
    }
    setState(() {
      _phase = _GamePhase.loading;
      _currentQuestion = null;
      _hasGuessed = false;
      _selectedIndex = null;
      _isCorrectGuess = false;
      _errorMessage = null;
    });

    try {
      final GameQuestion question = await _service.fetchQuestion();
      if (!mounted) {
        return;
      }
      setState(() {
        _currentQuestion = question;
        _phase = _GamePhase.playing;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = e.toString();
        _phase = _GamePhase.error;
      });
    }
  }

  void _handleOptionSelected(int index) {
    if (_phase != _GamePhase.playing || _hasGuessed || _currentQuestion == null) {
      return;
    }
    final bool isCorrect = index == _currentQuestion!.correctIndex;
    setState(() {
      _selectedIndex = index;
      _hasGuessed = true;
      _isCorrectGuess = isCorrect;
      if (!isCorrect) {
        _lives = (_lives - 1).clamp(0, 3);
      }
    });
  }

  void _handleNextPressed() {
    if (!_hasGuessed) {
      return;
    }
    if (_lives == 0) {
      setState(() {
        _phase = _GamePhase.landing;
        _currentQuestion = null;
        _hasGuessed = false;
        _selectedIndex = null;
        _isCorrectGuess = false;
      });
    } else {
      _loadNextQuestion();
    }
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
          '遊戲開始後會出現一張景點圖片，並告訴你該景點的名稱。\n你的任務：從四張圖片中挑出實際距離最接近該景點的位置。'
          '\n\n每局擁有三條命，答錯會扣一條命；命用完就得重新開始。',
          color: TPColors.grayscale700,
        ),
        actionsPadding: const EdgeInsets.only(right: 12, bottom: 8),
        actions: [
          TextButton(
            onPressed: () => Get.back<void>(),
            child: const TPText(
              '了解',
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
    required this.question,
    required this.lives,
    required this.hasGuessed,
    required this.isCorrect,
    required this.selectedIndex,
    required this.onOptionTap,
    required this.onNext,
  });

  final GameQuestion question;
  final int lives;
  final bool hasGuessed;
  final bool isCorrect;
  final int? selectedIndex;
  final void Function(int index) onOptionTap;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _LivesIndicator(lives: lives),
                const SizedBox(height: 16),
                _QuestionCard(question: question),
                const SizedBox(height: 16),
                TPText(
                  '哪個景點離 ${question.target.displayName} 最近？',
                  style: TPTextStyles.h3SemiBold,
                  color: TPColors.grayscale900,
                ),
                const SizedBox(height: 12),
                _OptionGrid(
                  question: question,
                  hasGuessed: hasGuessed,
                  selectedIndex: selectedIndex,
                  onTap: onOptionTap,
                ),
                const SizedBox(height: 24),
                if (hasGuessed)
                  _ResultBanner(
                    question: question,
                    isCorrect: isCorrect,
                    livesRemaining: lives,
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 48,
          child: ElevatedButton(
            onPressed: hasGuessed ? onNext : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: TPColors.primary500,
              disabledBackgroundColor: TPColors.grayscale200,
            ),
            child: TPText(
              lives == 0 ? '重新開始' : '下一題',
              style: TPTextStyles.h3SemiBold,
              color: TPColors.white,
            ),
          ),
        ),
      ],
    );
  }
}

class _LivesIndicator extends StatelessWidget {
  const _LivesIndicator({required this.lives});

  final int lives;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const TPText(
          '剩餘生命',
          style: TPTextStyles.h3SemiBold,
          color: TPColors.grayscale900,
        ),
        const SizedBox(width: 12),
        ...List.generate(
          3,
          (index) => Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Icon(
              index < lives ? Icons.favorite : Icons.favorite_border,
              color: index < lives ? TPColors.red400 : TPColors.grayscale300,
            ),
          ),
        ),
      ],
    );
  }
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({required this.question});

  final GameQuestion question;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: CachedNetworkImage(
              imageUrl: question.target.imageUrl,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(color: TPColors.grayscale100),
              errorWidget: (_, __, ___) => const ColoredBox(color: TPColors.grayscale200),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Color(0xCC000000), Color(0x00000000)],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TPText(
                    question.target.displayName,
                    style: TPTextStyles.h2SemiBold,
                    color: TPColors.white,
                  ),
                  const SizedBox(height: 4),
                  const TPText(
                    '挑戰：找出距離最近的景點',
                    style: TPTextStyles.bodyRegular,
                    color: TPColors.white,
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

class _OptionGrid extends StatelessWidget {
  const _OptionGrid({
    required this.question,
    required this.hasGuessed,
    required this.selectedIndex,
    required this.onTap,
  });

  final GameQuestion question;
  final bool hasGuessed;
  final int? selectedIndex;
  final void Function(int index) onTap;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: question.options.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.1,
      ),
      itemBuilder: (context, index) {
        final GameOption option = question.options[index];
        return _OptionTile(
          imageUrl: option.attraction.imageUrl,
          isCorrect: index == question.correctIndex,
          isSelected: selectedIndex == index,
          showResult: hasGuessed,
          onTap: () => onTap(index),
        );
      },
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.imageUrl,
    required this.isCorrect,
    required this.isSelected,
    required this.showResult,
    required this.onTap,
  });

  final String imageUrl;
  final bool isCorrect;
  final bool isSelected;
  final bool showResult;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    Color borderColor = Colors.transparent;
    if (showResult && isCorrect) {
      borderColor = TPColors.primary500;
    } else if (showResult && isSelected && !isCorrect) {
      borderColor = TPColors.red400;
    } else if (!showResult && isSelected) {
      borderColor = TPColors.primary400;
    }

    return GestureDetector(
      onTap: showResult ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: borderColor,
            width: borderColor == Colors.transparent ? 0 : 3,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.cover,
            placeholder: (_, __) => Container(color: TPColors.grayscale100),
            errorWidget: (_, __, ___) => const ColoredBox(color: TPColors.grayscale200),
          ),
        ),
      ),
    );
  }
}

class _ResultBanner extends StatelessWidget {
  const _ResultBanner({
    required this.question,
    required this.isCorrect,
    required this.livesRemaining,
  });

  final GameQuestion question;
  final bool isCorrect;
  final int livesRemaining;

  @override
  Widget build(BuildContext context) {
    final bool gameOver = !isCorrect && livesRemaining == 0;
    final Color background = isCorrect ? TPColors.primary50 : (gameOver ? TPColors.red50 : TPColors.orange50);
    final Color textColor = isCorrect ? TPColors.primary500 : (gameOver ? TPColors.red400 : TPColors.orange500);
    final IconData icon = isCorrect ? Icons.emoji_events : (gameOver ? Icons.sentiment_dissatisfied : Icons.lightbulb_outline);
    final String title = isCorrect
        ? '答對了！'
        : gameOver
            ? '三條命用完了'
            : '可惜，再試試看';
    final String subtitle = isCorrect
        ? '你成功選對最靠近 ${question.target.displayName} 的景點。'
        : '正確答案：${question.options[question.correctIndex].attraction.displayName}';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                  subtitle,
                  style: TPTextStyles.bodyRegular,
                  color: textColor,
                ),
                if (gameOver) ...[
                  const SizedBox(height: 8),
                  const TPText(
                    '按下重新開始，會重置三條命並抽出全新的題組。',
                    style: TPTextStyles.caption,
                    color: TPColors.red400,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Icon(Icons.wifi_off, size: 48, color: TPColors.grayscale400),
        const SizedBox(height: 16),
        TPText(
          message,
          style: TPTextStyles.bodyRegular,
          color: TPColors.grayscale700,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 44,
          child: OutlinedButton(
            onPressed: onRetry,
            child: const TPText(
              '重新載入',
              style: TPTextStyles.h3SemiBold,
              color: TPColors.primary500,
            ),
          ),
        ),
      ],
    );
  }
}
