import 'package:flutter/material.dart';
import 'package:town_pass/util/tp_colors.dart';

class StorePage extends StatefulWidget {
  const StorePage({super.key});

  @override
  State<StorePage> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  final TextEditingController _searchController = TextEditingController();

  final List<String> filters = ['限期改善', '合格', '優良'];
  final Map<String, bool> selectedFilters = {};

  final List<Map<String, String>> mockStores = [
    {'name': '阿明小吃', 'address': '台北市信義區松高路12號', 'status': '合格'},
    {'name': '幸福滷味', 'address': '台北市中正區忠孝西路1號', 'status': '限期改善'},
    {'name': '安心便當', 'address': '台北市大安區復興南路200號', 'status': '優良'},
  ];

  @override
  void initState() {
    super.initState();
    for (var f in filters) {
      selectedFilters[f] = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('店家查詢'),
        backgroundColor: TPColors.primary500,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 搜尋框
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '搜尋店家名稱',
                prefixIcon: const Icon(Icons.search),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
            const SizedBox(height: 16),

            // 過濾條件
            Wrap(
              spacing: 8,
              children: filters.map((f) {
                return FilterChip(
                  label: Text(f),
                  selected: selectedFilters[f]!,
                  onSelected: (val) {
                    setState(() => selectedFilters[f] = val);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // 清單
            Expanded(
              child: ListView.builder(
                itemCount: mockStores.length,
                itemBuilder: (context, index) {
                  final store = mockStores[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(store['name']!),
                      subtitle: Text(store['address']!),
                      trailing: Text(
                        store['status']!,
                        style: TextStyle(
                          color: store['status'] == '限期改善'
                              ? Colors.red
                              : store['status'] == '優良'
                                  ? Colors.green
                                  : Colors.orange,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
