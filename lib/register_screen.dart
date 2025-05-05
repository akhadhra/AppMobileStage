import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  // Contrôleurs pour récupérer le texte
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Action quand on clique sur le bouton "S'inscrire"
  void _register() {
    if (_formKey.currentState!.validate()) {
      String name = nameController.text.trim();
      String email = emailController.text.trim();
      String password = passwordController.text;

      print("Nom : $name");
      print("Email : $email");
      print("Mot de passe : $password");

      // Ici, plus tard, tu appelleras Firebase
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Créer un compte")),
      body: Padding(
        padding: EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(labelText: "Nom"),
                validator: (value) =>
                    value == null || value.isEmpty ? "Nom requis" : null,
              ),
              SizedBox(height: 16),

              TextFormField(
                controller: emailController,
                decoration: InputDecoration(labelText: "Email"),
                validator: (value) =>
                    value == null || !value.contains("@")
                        ? "Email invalide"
                        : null,
              ),
              SizedBox(height: 16),

              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: "Mot de passe"),
                validator: (value) => value == null || value.length < 6
                    ? "Minimum 6 caractères"
                    : null,
              ),
              SizedBox(height: 32),

              ElevatedButton(
                onPressed: _register,
                child: Text("S'inscrire"),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  backgroundColor: Colors.orange,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
