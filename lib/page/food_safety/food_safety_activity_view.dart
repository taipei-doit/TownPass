import 'package:flutter/material.dart';

class FoodSafetyActivityView extends StatelessWidget {
  const FoodSafetyActivityView({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> allNews = [
      {'title': '食安稽查加強中', 'date': '2025-11-01', 'desc': '政府加強餐飲業抽驗，確保食品安全。'},
      {'title': '夜市油品抽驗結果公布', 'date': '2025-10-28', 'desc': '多數油品合格，部分攤販需限期改善。'},
      {'title': '最新防疫餐飲指南', 'date': '2025-10-25', 'desc': '最新防疫措施上路，餐廳需落實實聯制。'},
      {'title': '校園午餐抽驗結果良好', 'date': '2025-10-20', 'desc': '全市學校午餐皆符合安全標準。'},
      {'title': '食材溯源系統升級', 'date': '2025-10-15', 'desc': '消費者可線上查詢食材來源，提升透明度。'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '食品安全活動',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: allNews.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) {
          final news = allNews[index];
          return ListTile(
            title: Text(
              news['title']!,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Text('${news['date']}｜${news['desc']}'),
          );
        },
      ),
    );
  }
}
