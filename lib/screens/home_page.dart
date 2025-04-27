import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../classes/user.dart';
import '../classes/user_data.dart';
import '../widgets/custom_drawer.dart';

UserData? utilisateur0000;

class HomePage extends StatefulWidget{
  const HomePage({super.key});
  @override
  _MyHomePage createState() => _MyHomePage();
}
class _MyHomePage extends State<HomePage> {

  final UserService _userService = UserService();
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }
  Future<void> _loadUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      utilisateur0000 = await _userService.getUserData(user.uid);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accueil'),
        backgroundColor: Colors.black38,
        elevation: 10,
      ),
      drawer: const CustomDrawer(currentPage: 'home'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Bienvenue dans votre application",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      "Dernières activités",
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 10),
                    ListTile(
                      leading: const Icon(Icons.message),
                      title: const Text("Nouveau message reçu"),
                      subtitle: const Text("Il y a 2 heures"),
                      onTap: () {},
                    ),
                    ListTile(
                      leading: const Icon(Icons.group),
                      title: const Text("Invitation à un groupe"),
                      subtitle: const Text("Il y a 1 jour"),
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}