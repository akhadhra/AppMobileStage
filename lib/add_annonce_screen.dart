import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AjouterAnnonceScreen extends StatefulWidget {
  @override
  _AjouterAnnonceScreenState createState() => _AjouterAnnonceScreenState();
}

class _AjouterAnnonceScreenState extends State<AjouterAnnonceScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titreController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _prixController = TextEditingController();

  List<XFile>? _imageFiles = [];
  Uint8List? _webImage;
  File? _imageFile;
  final picker = ImagePicker();

  Future<void> _pickImages() async {
    final pickedFiles = await picker.pickMultiImage();
    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      setState(() {
        _imageFiles = pickedFiles;
      });
    }
  }

  Future<List<String>> _uploadImages(List<XFile> files) async {
    List<String> downloadUrls = [];
    try {
      for (var file in files) {
        final fileName = DateTime.now().millisecondsSinceEpoch.toString();
        final ref = FirebaseStorage.instance.ref().child('annonces/$fileName.jpg');
        final fileToUpload = File(file.path);
        await ref.putFile(fileToUpload);
        final url = await ref.getDownloadURL();
        downloadUrls.add(url);
      }
    } catch (e) {
      print("Erreur d'upload d'image : $e");
    }
    return downloadUrls;
  }

  void _publierAnnonce() async {
    if (_formKey.currentState!.validate() && _imageFiles != null && _imageFiles!.isNotEmpty) {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final imageUrls = await _uploadImages(_imageFiles!);
      if (imageUrls.isEmpty) return;

      await FirebaseFirestore.instance.collection('annonces').add({
        'titre': _titreController.text.trim(),
        'description': _descriptionController.text.trim(),
        'prix': _prixController.text.trim(),
        'images': imageUrls,
        'auteur': user.displayName ?? user.email,
        'timestamp': FieldValue.serverTimestamp(),
      });

      Navigator.pop(context);
    } else if (_imageFiles == null || _imageFiles!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Veuillez sélectionner au moins une image")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Nouvelle annonce')),
      body: Padding(
        padding: EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _titreController,
                  decoration: InputDecoration(labelText: "Titre"),
                  validator: (value) => value == null || value.isEmpty ? "Titre requis" : null,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(labelText: "Description"),
                  maxLines: 3,
                  validator: (value) => value == null || value.isEmpty ? "Description requise" : null,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _prixController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: "Prix en euros"),
                  validator: (value) => value == null || value.isEmpty ? "Prix requis" : null,
                ),
                SizedBox(height: 16),
                _imageFiles != null && _imageFiles!.isNotEmpty
                    ? SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _imageFiles!.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: kIsWeb
                                  ? Image.network(
                                      _imageFiles![index].path,
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.file(
                                      File(_imageFiles![index].path),
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    ),
                            );
                          },
                        ),
                      )
                    : Text("Aucune image sélectionnée"),
                TextButton.icon(
                  onPressed: _pickImages,
                  icon: Icon(Icons.photo_library),
                  label: Text("Sélectionner des images"),
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _publierAnnonce,
                  child: Text("Publier"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
