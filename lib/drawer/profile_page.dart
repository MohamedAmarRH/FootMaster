import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../classes/user.dart';
import '../classes/user_data.dart';
import '../widgets/custom_drawer.dart';
import 'EditProfilePage.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

UserData? utilisateur2;

class _ProfilePageState extends State<ProfilePage> {
  final UserService _userService = UserService();
  UserData? utilisateur;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      utilisateur = await _userService.getUserData(user.uid);
      utilisateur2 = utilisateur;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Profil'),
        backgroundColor: Colors.black38,
        elevation: 10,
      ),
      drawer: const CustomDrawer(currentPage: 'profile'),
      body: utilisateur == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Photo de profil dynamique
            CircleAvatar(
              radius: 70,
              backgroundColor: Colors.orange,
              backgroundImage: utilisateur!.imageurl != null && utilisateur!.imageurl!.isNotEmpty
                  ? NetworkImage(utilisateur!.imageurl!)
                  : null,
              child: utilisateur!.imageurl == null || utilisateur!.imageurl!.isEmpty
                  ? Text(
                utilisateur!.prenom != null && utilisateur!.prenom!.isNotEmpty
                    ? utilisateur!.nom![0]
                    : 'U',
                style: TextStyle(fontSize: 50, color: Colors.white),
              )
                  : null,
            ),
            const SizedBox(height: 20),
            Text(
              utilisateur!.email ?? "Email non disponible",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            // Informations supplémentaires
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Informations du compte",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 15),
                    _buildProfileItem("Nom", utilisateur!.nom ?? "Non défini"),
                    _buildProfileItem("Prenom", utilisateur!.prenom ?? "Non défini"),
                    _buildProfileItem("Pied préféré", utilisateur!.pied ?? "Non défini"),
                    _buildProfileItem("Poste(s)", utilisateur!.selected_positions?.join(', ') ?? "Non défini"),
                    _buildProfileItem("Prenom", utilisateur!.prenom ?? "Non défini"),
                    _buildProfileItem("Date de naissance", utilisateur!.date_naissance ?? "Non défini"),
                    _buildProfileItem("Tel", utilisateur!.telephone_complet ?? "Non défini"),
                    _buildProfileItem("Adresse", utilisateur!.adresse ?? "Non défini"),
                    _buildProfileItem("Statut", utilisateur!.status ?? "Non définie"),
                    _buildProfileItem("Mot de passe", "********"),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Bouton de modification
            ElevatedButton.icon(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditProfilePage(utilisateur: utilisateur!),
                  ),
                );
                _fetchUserData();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.edit),
              label: const Text("Modifier le profil"),
            ),
          ],
        ),
      ),
    );
  }
  bool _loading = true;

  Future<void> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userData = await _userService.getUserData(user.uid);
      setState(() {
        utilisateur = userData;
        _loading = false;
      });
    }
  }

  Widget _buildProfileItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }
}
