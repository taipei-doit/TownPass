import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:town_pass/gen/assets.gen.dart';
import 'package:town_pass/page/game/model/attraction.dart';
import 'package:town_pass/page/game/model/game_question.dart';
import 'package:town_pass/page/game/service/attraction_service.dart';
import 'package:town_pass/page/game/widget/game_landing.dart';
import 'package:town_pass/util/tp_app_bar.dart';
import 'package:town_pass/util/tp_colors.dart';
import 'package:town_pass/util/tp_text.dart';
import 'package:town_pass/util/tp_text_styles.dart';
enum _GamePhase { landing, loading, playing, error }

enum GameLanguage { zh, en }

typedef _StringFormatter = String Function(String value);

class _GameStrings {
  const _GameStrings(this.language);

  final GameLanguage language;

  static const Map<GameLanguage, _GameCopy> _localizedValues = _localizedCopies;

  _GameCopy get _copy => _localizedValues[language]!;

  String get appTitle => _copy.appTitle;
  String get backSemantics => _copy.backSemantics;
  String get infoButtonSemantics => _copy.infoButtonSemantics;
  String get infoDialogTitle => _copy.infoDialogTitle;
  String get infoDialogBody => _copy.infoDialogBody;
  String get infoDialogConfirm => _copy.infoDialogConfirm;
  String get loadingError => _copy.loadingError;
  String get livesLabel => _copy.livesLabel;
  String questionPrompt(String target) => _copy.questionPrompt(target);
  String get challengeSubtitle => _copy.challengeSubtitle;
  String get nextCta => _copy.nextCta;
  String get restartCta => _copy.restartCta;
  String get resultDialogTitleCorrect => _copy.resultDialogTitleCorrect;
  String get resultDialogTitleWrong => _copy.resultDialogTitleWrong;
  String get resultDialogTitleGameOver => _copy.resultDialogTitleGameOver;
  String resultDialogTargetLine(String name) => _copy.resultDialogTargetLine(name);
  String get resultDialogTargetTitle => _copy.resultDialogTargetTitle;
  String optionTitle(int index, {required bool isCorrect, required bool showSelectedTag}) {
    final StringBuffer buffer = StringBuffer('${_copy.optionTitlePrefix} $index');
    if (isCorrect) {
      buffer.write(_copy.optionTagCorrect);
    }
    if (showSelectedTag) {
      buffer.write(_copy.optionTagSelected);
    }
    return buffer.toString();
  }

  String get closeLabel => _copy.closeLabel;
  String get resultBannerTitleCorrect => _copy.resultBannerTitleCorrect;
  String get resultBannerTitleWrong => _copy.resultBannerTitleWrong;
  String get resultBannerTitleGameOver => _copy.resultBannerTitleGameOver;
  String resultBannerSubtitleCorrect(String target) => _copy.resultBannerSubtitleCorrect(target);
  String resultBannerSubtitleWrong(String answer) => _copy.resultBannerSubtitleWrong(answer);
  String get resultBannerFooter => _copy.resultBannerFooter;
  String get reloadLabel => _copy.reloadLabel;
  String get landingTitle => _copy.landingTitle;
  String get landingDescription => _copy.landingDescription;
  List<String> get landingBullets => List.unmodifiable(_copy.landingBullets);
  String get landingStart => _copy.landingStart;
  String get languageToggleLabel => language == GameLanguage.zh ? 'English' : '中文';
}

class _GameCopy {
  const _GameCopy({
    required this.appTitle,
    required this.backSemantics,
    required this.infoButtonSemantics,
    required this.infoDialogTitle,
    required this.infoDialogBody,
    required this.infoDialogConfirm,
    required this.loadingError,
    required this.livesLabel,
    required this.questionPrompt,
    required this.challengeSubtitle,
    required this.nextCta,
    required this.restartCta,
    required this.resultDialogTitleCorrect,
    required this.resultDialogTitleWrong,
    required this.resultDialogTitleGameOver,
    required this.resultDialogTargetLine,
    required this.resultDialogTargetTitle,
    required this.optionTitlePrefix,
    required this.optionTagCorrect,
    required this.optionTagSelected,
    required this.closeLabel,
    required this.resultBannerTitleCorrect,
    required this.resultBannerTitleWrong,
    required this.resultBannerTitleGameOver,
    required this.resultBannerSubtitleCorrect,
    required this.resultBannerSubtitleWrong,
    required this.resultBannerFooter,
    required this.reloadLabel,
    required this.landingTitle,
    required this.landingDescription,
    required this.landingBullets,
    required this.landingStart,
  });

  final String appTitle;
  final String backSemantics;
  final String infoButtonSemantics;
  final String infoDialogTitle;
  final String infoDialogBody;
  final String infoDialogConfirm;
  final String loadingError;
  final String livesLabel;
  final _StringFormatter questionPrompt;
  final String challengeSubtitle;
  final String nextCta;
  final String restartCta;
  final String resultDialogTitleCorrect;
  final String resultDialogTitleWrong;
  final String resultDialogTitleGameOver;
  final _StringFormatter resultDialogTargetLine;
  final String resultDialogTargetTitle;
  final String optionTitlePrefix;
  final String optionTagCorrect;
  final String optionTagSelected;
  final String closeLabel;
  final String resultBannerTitleCorrect;
  final String resultBannerTitleWrong;
  final String resultBannerTitleGameOver;
  final _StringFormatter resultBannerSubtitleCorrect;
  final _StringFormatter resultBannerSubtitleWrong;
  final String resultBannerFooter;
  final String reloadLabel;
  final String landingTitle;
  final String landingDescription;
  final List<String> landingBullets;
  final String landingStart;
}

const Map<GameLanguage, _GameCopy> _localizedCopies = {
  GameLanguage.zh: _GameCopy(
    appTitle: 'Taipei Guessr',
    backSemantics: '返回上一頁',
    infoButtonSemantics: '遊戲介紹',
    infoDialogTitle: 'Taipei Guessr 遊戲說明',
    infoDialogBody:
        '遊戲開始後會出現一張景點圖片，並告訴你該景點的名稱。\n你的任務：從四張圖片中挑出實際距離最接近該景點的位置。'
        '\n\n每局擁有三條命，答錯會扣一條命；命用完就得重新開始。',
    infoDialogConfirm: '了解',
    loadingError: '載入題目時發生問題，請稍後再試。',
    livesLabel: '剩餘生命',
    questionPrompt: _questionPromptZh,
    challengeSubtitle: '挑戰：找出距離最近的景點',
    nextCta: '下一題',
    restartCta: '重新開始',
    resultDialogTitleCorrect: '太厲害！答對了',
    resultDialogTitleWrong: '答錯了，再接再厲',
    resultDialogTitleGameOver: '答錯了，遊戲結束',
    resultDialogTargetLine: _resultDialogTargetLineZh,
    resultDialogTargetTitle: '題目景點',
    optionTitlePrefix: '選項',
    optionTagCorrect: '（正確）',
    optionTagSelected: '（你選擇）',
    closeLabel: '關閉',
    resultBannerTitleCorrect: '答對了！',
    resultBannerTitleWrong: '可惜，再試試看',
    resultBannerTitleGameOver: '三條命用完了',
    resultBannerSubtitleCorrect: _resultBannerSubtitleCorrectZh,
    resultBannerSubtitleWrong: _resultBannerSubtitleWrongZh,
    resultBannerFooter: '按下重新開始，會重置三條命並抽出全新的題組。',
    reloadLabel: '重新載入',
    landingTitle: 'Taipei Guessr',
    landingDescription: '每幅光影，皆有其座標。憑一張臺北的剪影，在記憶的街角，尋訪那最相近的一隅。',
    landingBullets: [
      '觀察上方景點，回想所在區域',
      '推敲下方四圖，判斷相對位置',
      '選出最近鄰居，考驗你對臺北的認識',
    ],
    landingStart: '開始遊戲',
  ),
  GameLanguage.en: _GameCopy(
    appTitle: 'Taipei Guessr',
    backSemantics: 'Go back',
    infoButtonSemantics: 'How to play',
    infoDialogTitle: 'Taipei Guessr - How to Play',
    infoDialogBody:
        'Each round shows a landmark photo along with its name.\nYour mission: pick the option that is physically closest to it.'
        '\n\nYou have three lives per session. Every wrong guess costs one life; lose them all and the game restarts.',
    infoDialogConfirm: 'Got it',
    loadingError: 'We could not load the next question. Please try again later.',
    livesLabel: 'Lives left',
    questionPrompt: _questionPromptEn,
    challengeSubtitle: 'Challenge: find the closest attraction',
    nextCta: 'Next question',
    restartCta: 'Restart',
    resultDialogTitleCorrect: 'Great job! You got it',
    resultDialogTitleWrong: 'Incorrect, try again',
    resultDialogTitleGameOver: 'Wrong answer, game over',
    resultDialogTargetLine: _resultDialogTargetLineEn,
    resultDialogTargetTitle: 'Target attraction',
    optionTitlePrefix: 'Option',
    optionTagCorrect: ' (Correct)',
    optionTagSelected: ' (Your pick)',
    closeLabel: 'Close',
    resultBannerTitleCorrect: 'Correct!',
    resultBannerTitleWrong: 'Close, try again',
    resultBannerTitleGameOver: 'All lives used',
    resultBannerSubtitleCorrect: _resultBannerSubtitleCorrectEn,
    resultBannerSubtitleWrong: _resultBannerSubtitleWrongEn,
    resultBannerFooter: 'Press Restart to reset three lives and draw a fresh set of questions.',
    reloadLabel: 'Reload',
    landingTitle: 'Taipei Guessr',
    landingDescription: 'Every beam of light has its coordinates. With one snapshot of Taipei, rediscover the corner that feels closest.',
    landingBullets: [
      'Study the featured attraction and recall where it is.',
      'Compare the four photos below to judge their relative positions.',
      'Pick the closest neighbor and prove how well you know Taipei.',
    ],
    landingStart: 'Start game',
  ),
};

String _questionPromptZh(String target) => '哪個景點離 $target 最近？';
String _questionPromptEn(String target) => 'Which spot is closest to $target?';
String _resultDialogTargetLineZh(String name) => '題目景點：$name';
String _resultDialogTargetLineEn(String name) => 'Target attraction: $name';
String _resultBannerSubtitleCorrectZh(String target) => '你成功選對最靠近 $target 的景點。';
String _resultBannerSubtitleCorrectEn(String target) => 'You picked the attraction closest to $target.';
String _resultBannerSubtitleWrongZh(String answer) => '正確答案：$answer';
String _resultBannerSubtitleWrongEn(String answer) => 'Correct answer: $answer';

class GameView extends StatefulWidget {
  const GameView({super.key});

  @override
  State<GameView> createState() => _GameViewState();
}
// class _GameViewState extends State<GameView> with WidgetsBindingObserver {
class _GameViewState extends State<GameView> {
  final AttractionService _service = AttractionService();
  late final AudioPlayer _bgmPlayer;
  bool _hasGuessed = false;
  bool _isCorrectGuess = false;
  _GamePhase _phase = _GamePhase.landing;
  GameLanguage _language = GameLanguage.zh;
  GameQuestion? _currentQuestion;
  int _lives = 3;
  int? _selectedIndex;
  String? _errorMessage;

  _GameStrings get _strings => _GameStrings(_language);
  
  @override
  void initState() {
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
    // stop and dispose bgm player when the view is disposed
    try {
      _bgmPlayer.stop();
      _bgmPlayer.dispose();
    } catch (_) {}
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
    final _GameStrings strings = _strings;

    Widget child;
    switch (_phase) {
      case _GamePhase.landing:
        child = GameLanding(
          onStart: _startGame,
          title: strings.landingTitle,
          description: strings.landingDescription,
          bulletPoints: strings.landingBullets,
          startLabel: strings.landingStart,
          languageToggleLabel: strings.languageToggleLabel,
          onToggleLanguage: _toggleLanguage,
        );
        break;
      case _GamePhase.loading:
        child = const Center(child: CircularProgressIndicator());
        break;
      case _GamePhase.error:
        child = _ErrorState(
          message: _errorMessage ?? strings.loadingError,
          actionLabel: strings.reloadLabel,
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
            strings: strings,
          );
        }
        break;
    }

    return Scaffold(
      backgroundColor: TPColors.white,
      appBar: TPAppBar(
        showLogo: true,
        title: strings.appTitle,
        leading: IconButton(
          icon: Semantics(
            label: strings.backSemantics,
            child: Assets.svg.iconRemove.svg(),
          ),
          onPressed: () => Get.back<void>(),
        ),
        actions: [
          if (_phase == _GamePhase.playing)
            IconButton(
              icon: Semantics(
                label: strings.infoButtonSemantics,
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

  void _toggleLanguage() {
    setState(() {
      _language = _language == GameLanguage.zh ? GameLanguage.en : GameLanguage.zh;
    });
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _currentQuestion == null) {
        return;
      }
      _showResultDetailDialog(_currentQuestion!, isCorrect);
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
    final _GameStrings strings = _strings;
  Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: TPText(
          strings.infoDialogTitle,
          style: TPTextStyles.h3SemiBold,
          color: TPColors.grayscale900,
        ),
        content: TPText(
          strings.infoDialogBody,
          color: TPColors.grayscale700,
        ),
        actionsPadding: const EdgeInsets.only(right: 12, bottom: 8),
        actions: [
          TextButton(
            onPressed: () => Get.back<void>(),
            child: TPText(
              strings.infoDialogConfirm,
              style: TPTextStyles.h3SemiBold,
              color: TPColors.primary500,
            ),
          ),
        ],
      ),
    );
  }

  void _showResultDetailDialog(GameQuestion question, bool isCorrect) {
    final _GameStrings strings = _strings;
    final bool gameOver = _lives == 0;
    final String title =
        isCorrect ? strings.resultDialogTitleCorrect : (gameOver ? strings.resultDialogTitleGameOver : strings.resultDialogTitleWrong);
    final Color accentColor = isCorrect ? TPColors.primary500 : (_lives == 0 ? TPColors.red400 : TPColors.orange500);

    final PageController _pageController = PageController();
    int _pageIndex = 0;

    Get.dialog(
      Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.1),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TPText(
                      title,
                      style: TPTextStyles.h3SemiBold,
                      color: accentColor,
                    ),
                    const SizedBox(height: 4),
                    TPText(
                      strings.resultDialogTargetLine(question.target.displayName),
                      style: TPTextStyles.bodyRegular,
                      color: TPColors.grayscale800,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: StatefulBuilder(
                  builder: (context, setState) {
                    final List<Widget> pages = [
                      // Target attraction page (vertically scrollable)
                      SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _AttractionDetailCard(
                              title: strings.resultDialogTargetTitle,
                              attraction: question.target,
                              highlight: accentColor,
                            ),
                            const SizedBox(height: 24),
                            // Additional spacing or future widgets can go here
                          ],
                        ),
                      ),
                      // Option pages (each option occupies one vertically-scrollable page)
                      ...List.generate(
                        question.options.length,
                        (index) {
                          final GameOption option = question.options[index];
                          final bool isOptionCorrect = index == question.correctIndex;
                          final bool isSelected = index == _selectedIndex;
                          return SingleChildScrollView(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _AttractionDetailCard(
                                  title: strings.optionTitle(
                                    index + 1,
                                    isCorrect: isOptionCorrect,
                                    showSelectedTag: isSelected && !isOptionCorrect,
                                  ),
                                  attraction: option.attraction,
                                  highlight: isOptionCorrect ? TPColors.primary500 : TPColors.grayscale300,
                                ),
                                const SizedBox(height: 24),
                                // If the attraction has more fields to show, they can be added below
                              ],
                            ),
                          );
                        },
                      ),
                    ];

                    return Column(
                      children: [
                        Expanded(
                          child: PageView.builder(
                            controller: _pageController,
                            itemCount: pages.length,
                            onPageChanged: (p) => setState(() => _pageIndex = p),
                            itemBuilder: (context, index) => pages[index],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            pages.length,
                            (i) => Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: _pageIndex == i ? 10 : 8,
                              height: _pageIndex == i ? 10 : 8,
                              decoration: BoxDecoration(
                                color: _pageIndex == i ? accentColor : TPColors.grayscale300,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: SizedBox(
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () => Get.back<void>(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                    ),
                    child: TPText(
                      strings.closeLabel,
                      style: TPTextStyles.h3SemiBold,
                      color: TPColors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
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
    required this.strings,
  });

  final GameQuestion question;
  final int lives;
  final bool hasGuessed;
  final bool isCorrect;
  final int? selectedIndex;
  final void Function(int index) onOptionTap;
  final VoidCallback onNext;
  final _GameStrings strings;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _LivesIndicator(
                  lives: lives,
                  label: strings.livesLabel,
                ),
                const SizedBox(height: 16),
                _QuestionCard(
                  question: question,
                  challengeText: strings.challengeSubtitle,
                ),
                const SizedBox(height: 16),
                TPText(
                  strings.questionPrompt(question.target.displayName),
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
                    strings: strings,
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
              lives == 0 ? strings.restartCta : strings.nextCta,
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
  const _LivesIndicator({required this.lives, required this.label});

  final int lives;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        TPText(
          label,
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
  const _QuestionCard({required this.question, required this.challengeText});

  final GameQuestion question;
  final String challengeText;

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
                  TPText(
                    challengeText,
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
          name: option.attraction.displayName,
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
    required this.name,
    required this.isCorrect,
    required this.isSelected,
    required this.showResult,
    required this.onTap,
  });

  final String imageUrl;
  final String name;
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
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(color: TPColors.grayscale100),
                errorWidget: (_, __, ___) => const ColoredBox(color: TPColors.grayscale200),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Color(0xCC000000),
                        Color(0x00000000),
                      ],
                    ),
                  ),
                  child: TPText(
                    name,
                    style: TPTextStyles.bodySemiBold,
                    color: TPColors.white,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
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
    required this.strings,
  });

  final GameQuestion question;
  final bool isCorrect;
  final int livesRemaining;
  final _GameStrings strings;

  @override
  Widget build(BuildContext context) {
    final bool gameOver = !isCorrect && livesRemaining == 0;
    final Color background = isCorrect ? TPColors.primary50 : (gameOver ? TPColors.red50 : TPColors.orange50);
    final Color textColor = isCorrect ? TPColors.primary500 : (gameOver ? TPColors.red400 : TPColors.orange500);
    final IconData icon = isCorrect ? Icons.emoji_events : (gameOver ? Icons.sentiment_dissatisfied : Icons.lightbulb_outline);
    final String title = isCorrect
        ? strings.resultBannerTitleCorrect
        : (gameOver ? strings.resultBannerTitleGameOver : strings.resultBannerTitleWrong);
    final String subtitle = isCorrect
        ? strings.resultBannerSubtitleCorrect(question.target.displayName)
        : strings.resultBannerSubtitleWrong(question.options[question.correctIndex].attraction.displayName);

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
                  TPText(
                    strings.resultBannerFooter,
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
  const _ErrorState({required this.message, required this.onRetry, required this.actionLabel});

  final String message;
  final VoidCallback onRetry;
  final String actionLabel;

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
            child: TPText(
              actionLabel,
              style: TPTextStyles.h3SemiBold,
              color: TPColors.primary500,
            ),
          ),
        ),
      ],
    );
  }
}

class _AttractionDetailCard extends StatelessWidget {
  const _AttractionDetailCard({
    required this.title,
    required this.attraction,
    required this.highlight,
  });

  final String title;
  final Attraction attraction;
  final Color highlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: highlight.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: CachedNetworkImage(
              imageUrl: attraction.imageUrl,
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(height: 160, color: TPColors.grayscale100),
              errorWidget: (_, __, ___) => Container(height: 160, color: TPColors.grayscale200),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TPText(
                  title,
                  style: TPTextStyles.caption,
                  color: highlight,
                ),
                const SizedBox(height: 4),
                TPText(
                  attraction.displayName,
                  style: TPTextStyles.h3SemiBold,
                  color: TPColors.grayscale900,
                ),
                if (attraction.address.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.place_outlined, size: 16, color: TPColors.grayscale600),
                      const SizedBox(width: 4),
                      Expanded(
                        child: TPText(
                          attraction.address,
                          style: TPTextStyles.bodyRegular,
                          color: TPColors.grayscale600,
                        ),
                      ),
                    ],
                  ),
                ],
                if (attraction.description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  TPText(
                    attraction.description,
                    style: TPTextStyles.bodyRegular,
                    color: TPColors.grayscale700,
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
