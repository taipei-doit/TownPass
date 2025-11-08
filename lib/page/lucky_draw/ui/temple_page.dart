import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Temple {
  final String name;
  final String address;
  final String introduction;
  final String? officialSite;
  final List<String> images;

  Temple({
    required this.name,
    required this.address,
    required this.introduction,
    this.officialSite,
    required this.images,
  });
}

class TemplePage extends StatelessWidget {
  const TemplePage({super.key});

  Future<List<Temple>> _loadTemples() async {
    return [
      Temple(
        name: 'Longshan Temple',
        address: 'No. 211, Guangzhou St, Wanhua District, Taipei',
        introduction:
            'Built in 1738, Longshan Temple is one of Taiwan’s most famous temples, dedicated to the Buddhist Goddess of Mercy, Guanyin.',
        officialSite: 'https://english.lungshan.org.tw/',
        images: [
          'https://upload.wikimedia.org/wikipedia/commons/6/6e/Lungshan_Temple_Taipei_2016.jpg'
        ],
      ),
      Temple(
        name: 'Baoan Temple',
        address: 'No. 61, Hami St, Datong District, Taipei',
        introduction:
            'A Taoist temple dedicated to Baosheng Dadi, the God of Medicine, known for its exquisite wood carvings and cultural heritage.',
        officialSite: 'https://www.baoan.org.tw/',
        images: [
          'https://upload.wikimedia.org/wikipedia/commons/d/d8/Taipei_Baoan_Temple_main_entrance_20160709.jpg'
        ],
      ),
      Temple(
        name: 'Confucius Temple',
        address: 'No. 275, Dalong St, Datong District, Taipei',
        introduction:
            'Built in 1925, this Confucian temple showcases Southern Fujian architectural style and honors Confucius, the great Chinese philosopher.',
        officialSite: 'https://temple.gov.taipei/',
        images: [],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Famous Temples in Taiwan')),
      body: FutureBuilder<List<Temple>>(
        future: _loadTemples(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No temples found.'));
          }

          final temples = snapshot.data!;

          return ListView.builder(
            itemCount: temples.length,
            itemBuilder: (context, index) {
              final temple = temples[index];
              final coverImage =
                  temple.images.isNotEmpty ? temple.images.first : null;

              return Card(
                margin: const EdgeInsets.all(10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                elevation: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: Text(temple.name),
                            content: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(temple.introduction),
                                  const SizedBox(height: 10),
                                  if (temple.officialSite != null &&
                                      temple.officialSite!.isNotEmpty)
                                    GestureDetector(
                                      onTap: () async {
                                        final url =
                                            Uri.parse(temple.officialSite!);
                                        if (await canLaunchUrl(url)) {
                                          await launchUrl(url);
                                        }
                                      },
                                      child: const Text(
                                        'Official Website',
                                        style: TextStyle(
                                          color: Colors.blue,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Close'),
                              ),
                            ],
                          ),
                        );
                      },
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15),
                        ),
                        child: coverImage != null
                            ? Image.network(
                                coverImage,
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                height: 200,
                                width: double.infinity,
                                color: Colors.grey[300],
                                child: const Center(child: Text('No Image')),
                              ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            temple.name,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            temple.address,
                            style: const TextStyle(
                                fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
