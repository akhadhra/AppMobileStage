import 'package:flutter/material.dart';

class AnnonceDetailScreen extends StatelessWidget {
  final Map<String, dynamic> annonce;

  const AnnonceDetailScreen({super.key, required this.annonce});

  @override
  Widget build(BuildContext context) {
    final List<dynamic> images = annonce['images'] ?? [];
    final String titre = annonce['titre'] ?? 'Sans titre';
    final String description = annonce['description'] ?? 'Aucune description';
    final String prix = annonce['prix'] ?? '0';

    return Scaffold(
      appBar: AppBar(
        title: Text(titre),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (images.isNotEmpty)
              SizedBox(
                height: 200,
                child: PageView.builder(
                  itemCount: images.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Image.network(
                        images[index],
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                ),
              )
            else
              const Text("Aucune image disponible"),
            const SizedBox(height: 24),
            Text(
              "Description :",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(description),
            const SizedBox(height: 16),
            Text(
              "Prix : $prix €",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
