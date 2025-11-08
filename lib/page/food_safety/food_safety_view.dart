import 'package:flutter/material.dart';
import 'package:town_pass/util/tp_colors.dart';
import 'package:town_pass/page/food_safety/night_market_page.dart';
import 'package:town_pass/page/food_safety/store_page.dart';
import 'package:town_pass/page/food_safety/notification_page.dart';
import 'package:town_pass/page/food_safety/food_safety_activity_view.dart';

class FoodSafetyInfoSection extends StatefulWidget {
  const FoodSafetyInfoSection({super.key});

  @override
  State<FoodSafetyInfoSection> createState() => _FoodSafetyInfoSectionState();
}

class _FoodSafetyInfoSectionState extends State<FoodSafetyInfoSection> {
  bool isAddressDropdownOpen = false;

  String selectedAddress = '臺北市中正區仁愛路一段1號';
  final List<String> mockAddresses = [
    '臺北市信義區市府路45號',
    '新北市板橋區中山路一段100號',
    '高雄市鼓山區美術東二路25號',
    '新增地址',
  ];

  final List<String> mockNews = [
    '食藥署公布新食品添加物標準',
    '夜市攤販油品抽驗結果',
    '全國食安日活動開跑',
    '餐飲業者衛生講習開課',
    '食品追溯平台正式上線',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TPColors.white,
      appBar: AppBar(
        title: const Text(
          '食品安全',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: TPColors.primary500,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none,
                color: TPColors.grayscale700, size: 20),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.close, color: TPColors.grayscale700, size:20),
            onPressed: () {
              Navigator.pop(context); // 回首頁（主 app）
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ===== 地址區塊 =====
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    selectedAddress,
                    style: const TextStyle(
                      fontSize: 18,
                      color: TPColors.grayscale800,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    isAddressDropdownOpen
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                  ),
                  onPressed: () {
                    setState(() =>
                        isAddressDropdownOpen = !isAddressDropdownOpen);
                  },
                ),
              ],
            ),
            if (isAddressDropdownOpen)
              Container(
                height: MediaQuery.of(context).size.height / 3,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: TPColors.grayscale200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView(
                  children: mockAddresses.map((addr) {
                    if (addr == '新增地址') {
                      return ListTile(
                        leading: const Icon(Icons.add_location_alt_outlined,
                            color: Colors.teal),
                        title: const Text('新增地址'),
                        onTap: () async {
                          final newAddr = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const AddAddressPage()),
                          );
                          if (newAddr != null && newAddr.isNotEmpty) {
                            setState(() {
                              mockAddresses.insert(
                                  mockAddresses.length - 1, newAddr);
                              selectedAddress = newAddr;
                              isAddressDropdownOpen = false;
                            });
                          }
                        },
                      );
                    }
                    return Dismissible(
                      key: ValueKey(addr),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) {
                        setState(() {
                          mockAddresses.remove(addr);
                          if (selectedAddress == addr &&
                              mockAddresses.isNotEmpty) {
                            selectedAddress = mockAddresses.first;
                          }
                        });
                      },
                      child: ListTile(
                        title: Text(addr),
                        onTap: () {
                          setState(() {
                            selectedAddress = addr;
                            isAddressDropdownOpen = false;
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            const SizedBox(height: 16),

            // ===== 地圖區塊 =====
            AspectRatio(
              aspectRatio: 1.0,
              child: Container(
                decoration: BoxDecoration(
                  color: TPColors.grayscale100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text(
                    '地圖（此處可嵌入地圖 API）',
                    style: TextStyle(color: TPColors.grayscale600),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ===== 店家 / 夜市 =====
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const StorePage()),
                      );
                    },
                    child: Container(
                      height: 60,
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: TPColors.primary100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Text(
                          '店家',
                          style: TextStyle(
                            color: TPColors.primary500,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const NightMarketPage()),
                      );
                    },
                    child: Container(
                      height: 60,
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: TPColors.primary100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Text(
                          '夜市',
                          style: TextStyle(
                            color: TPColors.primary500,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ===== 最新消息 =====
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '最新消息',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const FoodSafetyActivityView()),
                    );
                  },
                  child: const Text('更多'),
                ),
              ],
            ),

            // 顯示前三則
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: mockNews.take(3).map((news) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Text('• $news'),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

// ===== 新增地址頁面 =====
class AddAddressPage extends StatefulWidget {
  const AddAddressPage({super.key});

  @override
  State<AddAddressPage> createState() => _AddAddressPageState();
}

class _AddAddressPageState extends State<AddAddressPage> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '新增地址',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: TPColors.primary500,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: '輸入地址',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, _controller.text);
              },
              child: const Text('新增'),
            )
          ],
        ),
      ),
    );
  }
}
