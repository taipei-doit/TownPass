import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:town_pass/gen/assets.gen.dart';
import 'package:town_pass/util/tp_app_bar.dart';
import 'package:town_pass/util/tp_colors.dart';
import 'package:town_pass/util/tp_route.dart';
import 'package:town_pass/util/tp_text.dart';

class GameView extends StatelessWidget {
  const GameView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TPColors.white,
      appBar: TPAppBar(
        showLogo: true,
        title: '遊戲',
        leading: IconButton(
          icon: Semantics(
            label: '返回上一頁',
            child: Assets.svg.iconRemove.svg(),
          ),
          onPressed: () => Get.back<void>(),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
        physics: const BouncingScrollPhysics(),
        itemCount: _gameEntries.length + 1,
        separatorBuilder: (_, index) => index == 0 ? const SizedBox(height: 24) : const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (index == 0) {
            return const TPText(
              '選擇想玩的遊戲，立即開玩！',
              style: TPTextStyles.h3SemiBold,
              color: TPColors.grayscale900,
            );
          }
          final entry = _gameEntries[index - 1];
          return _GameListTile(entry: entry);
        },
      ),
    );
  }

  static const List<_GameEntry> _gameEntries = [
    _GameEntry(
      title: '貪食蛇',
      description: '經典街機玩法，挑戰最高分。',
      icon: Icons.change_history,
      routeName: TPRoute.gameSnake,
    ),
    _GameEntry(
      title: '捷運闖關GO',
      description: '從捷運站解謎闖關，完成任務贏獎勵。',
      icon: Icons.directions_subway_filled,
      routeName: TPRoute.gameMetroChallenge,
    ),
  ];
}

class _GameEntry {
  const _GameEntry({
    required this.title,
    required this.description,
    required this.icon,
    required this.routeName,
  });

  final String title;
  final String description;
  final IconData icon;
  final String routeName;
}

class _GameListTile extends StatelessWidget {
  const _GameListTile({required this.entry});

  final _GameEntry entry;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: TPColors.grayscale50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: () => Get.toNamed(entry.routeName),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: CircleAvatar(
          backgroundColor: TPColors.primary50,
          radius: 24,
          child: Icon(entry.icon, color: TPColors.primary500),
        ),
        title: TPText(
          entry.title,
          style: TPTextStyles.h3SemiBold,
          color: TPColors.grayscale900,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: TPText(
            entry.description,
            style: TPTextStyles.bodyRegular,
            color: TPColors.grayscale700,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 18, color: TPColors.grayscale400),
      ),
    );
  }
}
