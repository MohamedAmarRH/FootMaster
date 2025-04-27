import 'package:firebase_auth/firebase_auth.dart';

class UserData {
  final String? adresse;
  final String? date_naissance;
  final String? email;
  final bool? emailVerified;
  final String? nom;
  final String? password;
  final String? prenom;
  final String? pied;
  final String? status;
  final String? telephone_complet;
  final String? indicatif;
  final String? numero;
  final String? imageurl;
  final String? age;
  final bool? connected;
  final String? imageURL;
  final List<String>? selected_positions;


  UserData({
    this.adresse,
    this.date_naissance,
    this.email,
    this.emailVerified,
    this.nom,
    this.password,
    this.pied,
    this.prenom,
    this.status,
    this.telephone_complet,
    this.indicatif,
    this.numero,
    this.imageurl,
    this.age,
    this.connected,
    this.imageURL,
    required this.selected_positions,
  });

  // Méthode pour transformer un Map Firestore en instance Utilisateur
  factory UserData.fromMap(Map<String, dynamic> data) {
    return UserData(
      adresse: data['adresse'],
      age: data['age'],
      date_naissance: data['date_naissance'],
      email: data['email'],
      emailVerified: FirebaseAuth.instance.currentUser?.emailVerified,
      nom: data['nom'],
      password: data['password'], // À éviter de stocker en clair
      pied: data['pied'],
      prenom: data['prenom'],
      status: data['status'],
      telephone_complet: data['telephone_complet'],
      indicatif: data['indicatif'],
      numero: data['numero'],
      imageURL: data['imageURL'],
      selected_positions: (data['selected_positions'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
    );
  }
}
