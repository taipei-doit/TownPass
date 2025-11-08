import 'package:flutter/material.dart';
import 'package:town_pass/models/attraction.dart';
import 'package:town_pass/service/attraction_service.dart';

import 'package:url_launcher/url_launcher.dart';

class AttractionListPage extends StatelessWidget {
  const AttractionListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final service = AttractionService();

    return Scaffold(
      appBar: AppBar(title: const Text('Nearby Attractions')),
      body: FutureBuilder<ApiResponse>(
        future: service.fetchAttractions(
          nlat: 25.058972,
          elong: 121.513278,
          page: 1,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.data.isEmpty) {
            return const Center(child: Text('No attractions found.'));
          }

          final attractions = snapshot.data!.data;

          return ListView.builder(
            itemCount: attractions.length,
            itemBuilder: (context, index) {
              final attraction = attractions[index];
              final coverImage = attraction.images.length > 0
                  ? attraction.images.first.src
                  : null;

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
                            title: Text(attraction.name),
                            content: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(attraction.introduction),
                                  const SizedBox(height: 10),
                                  if (attraction.officialSite!.isNotEmpty)
                                    GestureDetector(
                                      onTap: () async {
                                        final url =
                                            Uri.parse(attraction.officialSite!);
                                        if (await canLaunchUrl(url)) {
                                          await launchUrl(url);
                                        }
                                      },
                                      child: const Text(
                                        'Official Page',
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
                        child: coverImage != null ? Image.network(
                          coverImage,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ) : Container(
                          height: 200,
                          width: double.infinity,
                          color: Colors.grey[300],
                          child: const Center(
                            child: Text(
                              '',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
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
                            attraction.name,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            attraction.address,
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
