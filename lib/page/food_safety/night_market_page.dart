import 'package:flutter/material.dart';
import 'package:town_pass/util/tp_colors.dart';

class NightMarketPage extends StatefulWidget {
  const NightMarketPage({super.key});

  @override
  State<NightMarketPage> createState() => _NightMarketPageState();
}

class _NightMarketPageState extends State<NightMarketPage> {
  final List<String> nightMarkets = ['饒河夜市', '士林夜市', '逢甲夜市'];
  String? selectedMarket;

  // mock data
  final Map<String, List<Map<String, String>>> unqualifiedShops = {
    '饒河夜市': [
      {'name': '阿明臭豆腐', 'address': '台北市松山區八德路', 'status': '限期改善'},
      {'name': '小美烤魷魚', 'address': '台北市松山區饒河街', 'status': '不合格'},
    ],
    '士林夜市': [],
    '逢甲夜市': [
      {'name': '阿雄滷味', 'address': '台中市西屯區逢甲路', 'status': '限期改善'},
    ],
  };

  final Map<String, List<Map<String, String>>> goodShops = {
    '饒河夜市': [
      {'name': '小王排骨酥', 'address': '台北市松山區饒河街', 'status': '優'},
      {'name': '黃家胡椒餅', 'address': '台北市松山區八德路', 'status': '良'},
    ],
    '士林夜市': [
      {'name': '大頭雞排', 'address': '台北市士林區文林路', 'status': '優'},
    ],
    '逢甲夜市': [],
  };

  @override
  void initState() {
    super.initState();
    selectedMarket = nightMarkets.first;
  }

  @override
  Widget build(BuildContext context) {
    final selectedUnqualified = unqualifiedShops[selectedMarket] ?? [];
    final selectedGood = goodShops[selectedMarket] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '夜市資訊',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: TPColors.primary500,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 夜市下拉選單
            DropdownButton<String>(
              value: selectedMarket,
              onChanged: (value) {
                setState(() {
                  selectedMarket = value;
                });
              },
              items: nightMarkets
                  .map(
                    (market) => DropdownMenuItem(
                      value: market,
                      child: Text(market),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 不合格名單（若無資料不顯示）
                    if (selectedUnqualified.isNotEmpty) ...[
                      const Text(
                        '不合格名單',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      _buildShopList(selectedUnqualified, Colors.red.shade100),
                      const SizedBox(height: 16),
                    ],

                    // 優良名單（若無資料不顯示）
                    if (selectedGood.isNotEmpty) ...[
                      const Text(
                        '優良名單',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      _buildShopList(selectedGood, Colors.green.shade100),
                    ],

                    if (selectedUnqualified.isEmpty &&
                        selectedGood.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(40.0),
                          child: Text('目前尚無資料'),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShopList(
      List<Map<String, String>> data, Color backgroundColor) {
    return Column(
      children: data.map((shop) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListTile(
            title: Text(
              shop['name']!,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(shop['address']!),
            trailing: Text(
              shop['status']!,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        );
      }).toList(),
    );
  }
}
