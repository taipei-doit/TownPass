import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class Temple {
  final int id;
  final String city;
  final String district;
  final String name;
  final String attribute;
  final String merit;
  final double latitude;
  final double longitude;
  final String imageUrl;
  final String introduction;

  Temple({
    required this.id,
    required this.city,
    required this.district,
    required this.name,
    required this.attribute,
    required this.merit,
    required this.latitude,
    required this.longitude,
    required this.imageUrl,
    required this.introduction,
  });

  factory Temple.fromJson(Map<String, dynamic> json) {
    return Temple(
      id: json['編號'] ?? 0,
      city: json['縣市'] ?? '',
      district: json['區別'] ?? '',
      name: json['temple_name'] ?? '',
      attribute: json['團體屬性'] ?? '',
      merit: json['績優項目'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      imageUrl: json['src'] ?? '',
      introduction: json['intro'] ?? '',
    );
  }
}

class TemplePage extends StatefulWidget {
  const TemplePage({super.key});

  @override
  State<TemplePage> createState() => _TemplePageState();
}

class _TemplePageState extends State<TemplePage> {
  late Future<List<Temple>> templesFuture;

  @override
  void initState() {
    super.initState();
    templesFuture = _loadTemples();
  }

  Future<List<Temple>> _loadTemples() async {
    final String jsonString = await rootBundle.loadString('assets/temple.json');
    final List<dynamic> jsonData = json.decode(jsonString);

    final temples = jsonData.map((item) => Temple.fromJson(item)).toList();


    return temples;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Temple List')),
      body: FutureBuilder<List<Temple>>(
        future: templesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No data found.'));
          }

          final temples = snapshot.data!;

          return ListView.builder(
            itemCount: temples.length,
            itemBuilder: (context, index) {
              final temple = temples[index];

              return Card(
                margin: const EdgeInsets.all(10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 5,
                child: InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text(temple.name),
                        content: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${temple.city} ${temple.district}",
                                style: const TextStyle(color: Colors.grey),
                              ),
                              const SizedBox(height: 8),
                              const SizedBox(height: 8),
                              if (temple.introduction.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: Text(temple.introduction),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15),
                        ),
                        child: temple.imageUrl.isNotEmpty
                            ? Image.network(
                                temple.imageUrl,
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                height: 200,
                                color: Colors.grey[300],
                                child: const Center(
                                  child: Text('No Image'),
                                ),
                              ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              temple.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "${temple.city} ${temple.district}",
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
