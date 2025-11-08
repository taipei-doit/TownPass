import 'package:flutter/material.dart';
import 'package:town_pass/util/tp_colors.dart';

class NightMarketPage extends StatefulWidget {
  const NightMarketPage({super.key});

  @override
  State<NightMarketPage> createState() => _NightMarketPageState();
}

class _NightMarketPageState extends State<NightMarketPage> {
  String? selectedMarket;

  final List<String> mockMarkets = [
    '士林夜市',
    '饒河街夜市',
    '六合夜市',
  ];

  final List<Map<String, String>> unqualifiedList = [
    {'name': '大腸包小腸攤', 'address': '士林夜市12號', 'status': '不合格'},
    {'name': '珍奶王', 'address': '饒河街夜市8號', 'status': '不合格'},
  ];

  final List<Map<String, String>> excellentList = [
    {'name': '烤魷魚達人', 'address': '六合夜市20號', 'status': '優'},
    {'name': '滷味之家', 'address': '士林夜市35號', 'status': '良'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('夜市食安查詢'),
        backgroundColor: TPColors.primary500,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 下拉選單
            DropdownButtonFormField<String>(
              value: selectedMarket,
              hint: const Text('選擇夜市'),
              items: mockMarkets
                  .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                  .toList(),
              onChanged: (val) {
                setState(() => selectedMarket = val);
              },
            ),

            const SizedBox(height: 16),

            if (selectedMarket != null) ...[
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '不合格名單',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  children: unqualifiedList.map((item) {
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        title: Text(item['name']!),
                        subtitle: Text(item['address']!),
                        trailing: Text(
                          item['status']!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '優良名單',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  children: excellentList.map((item) {
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        title: Text(item['name']!),
                        subtitle: Text(item['address']!),
                        trailing: Text(
                          item['status']!,
                          style: TextStyle(
                            color: item['status'] == '優'
                                ? Colors.green
                                : Colors.blue,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
