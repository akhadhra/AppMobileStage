import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'add_annonce_screen.dart';
import 'welcome_screen.dart';
import 'annonce_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => WelcomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text("Bonjour - ${user?.displayName ?? " et bienvenue"}"),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AjouterAnnonceScreen()),
              );
            },
            icon: Icon(Icons.add),
            tooltip: "Ajouter une annonce",
          ),
          IconButton(
            onPressed: () => _signOut(context),
            icon: Icon(Icons.logout),
            tooltip: "Déconnexion",
          ),
        ],
      ),
      body: Padding(
  padding: const EdgeInsets.all(12.0),
  child: StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance.collection('annonces').orderBy('timestamp', descending: true).snapshots(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Center(child: CircularProgressIndicator());
      }
      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
        return Center(child: Text("Aucune annonce disponible."));
      }

      final annonces = snapshot.data!.docs;

      return GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.8,
        ),
        itemCount: annonces.length,
        itemBuilder: (context, index) {
          final data = annonces[index];
          final List images = data['images'] ?? [];
          final titre = data['titre'] ?? '';

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AnnonceDetailScreen(annonce: data.data() as Map<String, dynamic>)),
              );
            },
            child: Card(
              elevation: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    flex: 6,
                    child: images.isNotEmpty
                        ? Image.network(images[0], fit: BoxFit.cover)
                        : Container(
                            color: Colors.grey[300],
                            child: Icon(Icons.image_not_supported, size: 40, color: Colors.grey[600]),
                          ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        titre,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
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
),
    );
  }
}
