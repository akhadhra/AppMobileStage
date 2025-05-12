import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'add_annonce_screen.dart';
import 'welcome_screen.dart';

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
      body: StreamBuilder<QuerySnapshot>(
  stream: FirebaseFirestore.instance
      .collection('annonces')
      .orderBy('timestamp', descending: true)
      .snapshots(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return Center(child: CircularProgressIndicator());
    }

    final annonces = snapshot.data!.docs;

    if (annonces.isEmpty) {
      return Center(child: Text("Aucune annonce pour l’instant"));
    }

    return ListView.builder(
      itemCount: annonces.length,
      itemBuilder: (context, index) {
        final data = annonces[index].data() as Map<String, dynamic>;
        return ListTile(
          title: Text(data['titre'] ?? ''),
          subtitle: Text(data['description'] ?? ''),
          trailing: Text(data['auteur'] ?? ''),
        );
      },
    );
  },
),
    );
  }
}
