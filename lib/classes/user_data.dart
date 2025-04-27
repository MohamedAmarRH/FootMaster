import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'user.dart';

class UserService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Méthode pour récupérer les données d'un utilisateur
  Future<UserData?> getUserData(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();

      if (doc.exists) {
        return UserData.fromMap(doc.data()!);
      } else {
        return null; // L'utilisateur n'existe pas
      }
    } catch (e) {
      print("Erreur de récupération des données utilisateur : $e");
      return null;
    }
  }

  // Optionnel : méthode pour récupérer les données de l'utilisateur actuellement connecté
  Future<UserData?> getCurrentUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      return await getUserData(user.uid);
    }
    return null; // Aucun utilisateur connecté
  }
}
