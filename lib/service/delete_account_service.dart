import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

Future<void> deleteUserAccount(String password) async {
  final user = FirebaseAuth.instance.currentUser;
  final email = user?.email;

  if (user == null || email == null) {
    throw Exception("Utilisateur non connecté");
  }

  // Re-authentification
  final credential = EmailAuthProvider.credential(email: email, password: password);
  await user.reauthenticateWithCredential(credential);

  final uid = user.uid;
  final firestore = FirebaseFirestore.instance;

  // Supprimer tous les messages envoyés
  final messages1 = await firestore.collection('messages')
      .where('sender', isEqualTo: email)
      .get();

  for (var doc in messages1.docs) {
    await doc.reference.delete();
  }

  // Supprimer tous les messages reçus
  final messages2 = await firestore.collection('messages')
      .where('receiver', isEqualTo: email)
      .get();

  for (var doc in messages2.docs) {
    await doc.reference.delete();
  }

  // Supprimer l'utilisateur de la collection users
  await firestore.collection('users').doc(uid).delete();

  // Supprimer le compte de Firebase Auth
  await user.delete();
}

Future<String?> showDeleteAccountDialog(BuildContext context) {
  final passwordController = TextEditingController();

  return showGeneralDialog<String>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Supprimer le compte',
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, anim1, anim2) {
      return const SizedBox.shrink();
    },
    transitionBuilder: (context, anim1, anim2, child) {
      return Transform.scale(
        scale: Curves.easeOutBack.transform(anim1.value),
        child: Opacity(
          opacity: anim1.value,
          child: AlertDialog(
            backgroundColor: Colors.grey[900],
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: const [
                Icon(Icons.warning_amber_rounded, color: Colors.red, size: 30),
                SizedBox(width: 10),
                Text("Delete Account", style: TextStyle(color: Colors.white)),
              ],
            ),
            content: SizedBox(
              width: 300, // Limiter la largeur pour une meilleure lisibilité sur mobile
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "⚠️ Cette action est irréversible. Veuillez entrer votre mot de passe pour confirmer.",
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'Mot de passe',
                      hintStyle: const TextStyle(color: Colors.white38),
                      filled: true,
                      fillColor: Colors.white10,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                child: const Text("Annuler", style: TextStyle(color: Colors.white)),
                onPressed: () => Navigator.pop(context, null),
              ),
              TextButton(
                child: const Text("Supprimer", style: TextStyle(color: Colors.red)),
                onPressed: () => Navigator.pop(context, passwordController.text.trim()),
              ),
            ],
          ),
        ),
      );
    },
  );
}
