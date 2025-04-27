import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../provider/theme_provider.dart';
import '../screens/home_page.dart';
import '../screens/login_page2.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:async';



Future<void> setConnected(bool b) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool('connected', b);
}

Future<bool> isConnectedToInternet() async {
  var connectivityResult = await Connectivity().checkConnectivity();

  if (connectivityResult == ConnectivityResult.mobile ||
      connectivityResult == ConnectivityResult.wifi) {
    return true;
  } else {
    return false;
  }
}

class CustomDrawer extends StatelessWidget {
  final String currentPage;


  Future<void> _saveProfile() async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'connected': false,
        });
      }
  }

  const CustomDrawer({super.key, required this.currentPage});

  @override
  Widget build(BuildContext context) {

    final themeProvider = Provider.of<ThemeProvider>(context);

    Future<void> saveUserData2(bool connected) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('connected', connected ?? false);
    }

    return Drawer(
      child: Column(
        children: [
          Stack(
            children: [
              UserAccountsDrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                ),
                accountName: Text(
                  "${utilisateur0000?.nom ?? "Nom inconnu"} ${utilisateur0000?.prenom ?? "Prénom inconnu"}",
                  overflow: TextOverflow.ellipsis,  // Troncature du texte
                  maxLines: 1,  // Limiter le texte à une seule ligne
                  style: TextStyle(fontSize: 18),
                ),
                accountEmail: Text(
                  utilisateur0000?.email  ?? "Email inconnu",
                  overflow: TextOverflow.ellipsis,  // Troncature du texte
                  maxLines: 1,  // Limiter le texte à une seule ligne
                  style: TextStyle(fontSize: 14),
                ),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Text(
                    (utilisateur0000?.nom?.isNotEmpty ?? false)
                        ? utilisateur0000!.nom![0]
                        : " ",
                    style: TextStyle(fontSize: 24),
                  ),
                ),
              ),
              Positioned(
                top: 30,
                right: 10,
                child: IconButton(
                  icon: Icon(
                    themeProvider.isDarkMode
                        ? Icons.nightlight_round
                        : Icons.wb_sunny,
                    color: Colors.white,
                  ),
                  onPressed: () => themeProvider.toggleTheme(),
                ),
              ),
            ],
          ),
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  leading: Icon(Icons.home),
                  title: Text("Accueil"),
                  selected: currentPage == 'home',
                  selectedTileColor: Colors.orange.withOpacity(0.2), // Couleur de fond quand sélectionné
                  selectedColor: Colors.orange, // Couleur du texte et icône quand sélectionné
                  onTap: () {
                    if (currentPage != 'home') {
                      Navigator.pop(context);
                      Navigator.pushReplacementNamed(context, '/home');
                    } else {
                      Navigator.pop(context);
                    }
                  },
                ),
                ListTile(
                  leading: Icon(Icons.person),
                  title: Text("Mon profil"),
                  selected: currentPage == 'profile',
                  selectedTileColor: Colors.orange.withOpacity(0.2), // Couleur de fond quand sélectionné
                  selectedColor: Colors.orange, // Couleur du texte et icône quand sélectionné
                  onTap: () {
                    if (currentPage != 'profile') {
                      Navigator.pop(context);
                      Navigator.pushReplacementNamed(context, '/profile');
                    } else {
                      Navigator.pop(context);
                    }
                  },
                ),
                ListTile(
                  leading: FaIcon(FontAwesomeIcons.shirt),
                  title: Text("Equipe"),
                  selected: currentPage == 'equipe',
                  selectedTileColor: Colors.orange.withOpacity(0.2), // Couleur de fond quand sélectionné
                  selectedColor: Colors.orange, // Couleur du texte et icône quand sélectionné
                  onTap: () {
                    if (currentPage != 'equipe') {
                      Navigator.pop(context);
                      Navigator.pushReplacementNamed(context, '/equipe');
                    } else {
                      Navigator.pop(context);
                    }
                  },
                ),
                ListTile(
                  leading: Icon(Icons.message_outlined),
                  title: Text("Messages"),
                  selected: currentPage == 'message',
                  selectedTileColor: Colors.orange.withOpacity(0.2), // Couleur de fond quand sélectionné
                  selectedColor: Colors.orange, // Couleur du texte et icône quand sélectionné
                  onTap: () {
                    if (currentPage != 'message') {
                      Navigator.pop(context);
                      Navigator.pushReplacementNamed(context, '/message');
                    } else {
                      Navigator.pop(context);
                    }
                  },
                ),
                ListTile(
                  leading: Icon(Icons.accessibility_outlined),
                  title: Text("Training"),
                  selected: currentPage == 'training',
                  selectedTileColor: Colors.orange.withOpacity(0.2), // Couleur de fond quand sélectionné
                  selectedColor: Colors.orange, // Couleur du texte et icône quand sélectionné
                  onTap: () {
                    if (currentPage != 'training') {
                      Navigator.pop(context);
                      Navigator.pushReplacementNamed(context, '/training');
                    } else {
                      Navigator.pop(context);
                    }
                  },
                ),
                ListTile(
                  leading: Icon(Icons.assistant_photo_rounded),
                  title: Text("Match"),
                  selected: currentPage == 'match',
                  selectedTileColor: Colors.orange.withOpacity(0.2), // Couleur de fond quand sélectionné
                  selectedColor: Colors.orange, // Couleur du texte et icône quand sélectionné
                  onTap: () {
                    if (currentPage != 'match') {
                      Navigator.pop(context);
                      Navigator.pushReplacementNamed(context, '/match');
                    } else {
                      Navigator.pop(context);
                    }
                  },
                ),
                ListTile(
                  leading: Icon(Icons.insert_chart),
                  title: Text("Statistiques"),
                  selected: currentPage == '',
                  selectedTileColor: Colors.orange.withOpacity(0.2), // Couleur de fond quand sélectionné
                  selectedColor: Colors.orange, // Couleur du texte et icône quand sélectionné
                  onTap: () {
                    if (currentPage != '') {
                      Navigator.pop(context);
                      Navigator.pushReplacementNamed(context, '');
                    } else {
                      Navigator.pop(context);
                    }
                  },
                ),
                ListTile(
                  leading: Icon(Icons.settings),
                  title: Text("Paramètres"),
                  selected: currentPage == 'settings',
                  selectedTileColor: Colors.orange.withOpacity(0.2), // Couleur de fond quand sélectionné
                  selectedColor: Colors.orange, // Couleur du texte et icône quand sélectionné
                  onTap: () {
                    if (currentPage != 'settings') {
                      Navigator.pop(context);
                      Navigator.pushReplacementNamed(context, '/settings');
                    } else {
                      Navigator.pop(context);
                    }
                  },
                ),


                Column(
                  children: [
                    Divider(thickness: 1),
                    ListTile(
                      leading: Icon(Icons.logout_rounded),
                      title: Text("Log out"),
                      selectedColor: Colors.red,
                      textColor: Colors.red,
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              title: Row(
                                children: const [
                                  Icon(Icons.logout_rounded, color: Colors.red),
                                  SizedBox(width: 10),
                                  Text("Déconnexion"),
                                ],
                              ),
                              content: const Text(
                                "Voulez-vous vraiment vous déconnecter ?",
                                style: TextStyle(fontSize: 16),
                              ),
                              actionsPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                              actions: [
                                TextButton(
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.grey[600],
                                  ),
                                  child: const Text("Annuler"),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.check),
                                  label: const Text("Oui, déconnecter"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  onPressed: () async {
                                    bool isConnected = await isConnectedToInternet();

                                    if (isConnected) {
                                      print("✅ Connecté à Internet");
                                      saveUserData2(false);
                                      await FirebaseAuth.instance.signOut();
                                      _saveProfile();
                                      Navigator.of(context).pop();
                                      setConnected(false);
                                      // Rediriger directement vers LoginPage2 sans passer par la route définie
                                      Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(builder: (context) => LoginPage2()),
                                            (Route<dynamic> route) => false,  // Ferme toutes les pages précédentes
                                      );
                                    } else {
                                      ScaffoldMessenger.of("Pas de connexion Internet" as BuildContext).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            "Pas de connexion Internet",
                                          ),
                                        ),
                                      );
                                      print(" Pas de connexion Internet");
                                    }
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },

                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
