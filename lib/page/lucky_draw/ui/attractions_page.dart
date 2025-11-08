import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Attraction {
  final String name;
  final String introduction;
  final String officialSite;
  final List<String> images;
  final String address; // New field

  const Attraction({
    required this.name,
    required this.introduction,
    required this.officialSite,
    required this.images,
    required this.address,
  });
}

class AttractionsPage extends StatelessWidget {
  const AttractionsPage({super.key});

  // Hardcoded sample data
  static const List<Attraction> attractions = [
    Attraction(
      name: '甘州街_茶葉街',
      introduction:
          '甘州街俗稱茶葉街，在大稻埕的茶葉歷史上佔了很重要的地位，極盛時期，光是甘州街和鄰近的歸綏街就聚集了十幾家茶行。此外當時貴德街的「錦記茶行」、民生西路的「新芳春茶行」、西寧北路現為全祥茶廠的「南興茶行」、重慶北路的「有記名茶」，也都是茶葉發展開拓的重要功臣。',
      officialSite: 'http://www.taipeitea.org.tw/findtea/t5.html',
      images: [
        'https://www.travel.taipei/image/98635',
      ],
      address: '103 臺北市大同區甘州街',
    ),
  ];

  void _showDetails(BuildContext context, Attraction attraction) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(attraction.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(attraction.introduction),
              const SizedBox(height: 10),
              if (attraction.officialSite.isNotEmpty)
                GestureDetector(
                  onTap: () async {
                    final url = Uri.parse(attraction.officialSite);
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url);
                    }
                  },
                  child: const Text(
                    '官方網站',
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Attractions')),
      body: ListView.builder(
        itemCount: attractions.length,
        itemBuilder: (context, index) {
          final attraction = attractions[index];
          final coverImage = attraction.images.isNotEmpty
              ? attraction.images.first
              : 'https://via.placeholder.com/300';

          return Card(
            margin: const EdgeInsets.all(10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15), // Rounded corners
            ),
            elevation: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => _showDetails(context, attraction),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                    ),
                    child: Image.network(
                      coverImage,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        attraction.name,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        attraction.address, // Display address
                        style:
                            const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
