import 'package:flutter/material.dart';

class DeveloperPage extends StatelessWidget {
  const DeveloperPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Data pengembang
    final developers = [
      {
        'name': 'ALDEN NAFISA HERMAWAN',
        'nim': '2307411009',
        'image': 'assets/Pengembang/Alden.jpeg',
      },
      {
        'name': 'DHANNY ABDUL QODIR AL JAELANY',
        'nim': '2307411012',
        'image': 'assets/Pengembang/Dhanny.jpeg',
      },
      {
        'name': 'ANHAR PUTRANTO',
        'nim': '2307411027',
        'image': 'assets/Pengembang/Anhar.jpg',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tim Pengembang'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: developers.length,
        itemBuilder: (context, index) {
          final developer = developers[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 80,
                    backgroundImage: AssetImage(developer['image']!),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    developer['name']!,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'NIM: ${developer['nim']}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}