import 'package:flutter/material.dart';
import 'package:town_pass/util/tp_colors.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final List<Map<String, dynamic>> mockNotifications = [
    {
      'title': '食品安全快訊',
      'content': '最新抽驗結果已公布。',
      'isRead': false,
    },
    {
      'title': '夜市衛生稽查公告',
      'content': '部分攤商需限期改善。',
      'isRead': true,
    },
    {
      'title': '防疫新規提醒',
      'content': '請配合政府防疫規範。',
      'isRead': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('通知中心'),
        backgroundColor: TPColors.primary500,
      ),
      body: ListView.builder(
        itemCount: mockNotifications.length,
        itemBuilder: (context, index) {
          final notif = mockNotifications[index];
          return Card(
            color: notif['isRead']
                ? TPColors.grayscale100
                : Colors.white,
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              leading: Icon(
                notif['isRead']
                    ? Icons.notifications_none
                    : Icons.notifications_active,
                color: notif['isRead']
                    ? TPColors.grayscale600
                    : TPColors.primary500,
              ),
              title: Text(
                notif['title'],
                style: TextStyle(
                  fontWeight:
                      notif['isRead'] ? FontWeight.normal : FontWeight.bold,
                ),
              ),
              subtitle: Text(notif['content']),
              onTap: () {
                setState(() {
                  notif['isRead'] = true;
                });
              },
            ),
          );
        },
      ),
    );
  }
}
