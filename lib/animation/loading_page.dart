import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../classes/user.dart';
import '../drawer/equipe.dart';
import '../drawer/message/chat_page.dart';
import '../drawer/new_group_page.dart';
import '../drawer/profile_page.dart';
import '../drawer/saved_messages_page.dart';
import '../drawer/settings_page.dart';
import '../provider/theme_provider.dart';
import '../provider/user_provider.dart';
import '../screens/home_page.dart';
import '../screens/login_page2.dart';
import '../service/local_user_service.dart';


class MyLoadingPage extends StatefulWidget {
  const MyLoadingPage({super.key, required this.title});

  final String title;

  @override
  State<MyLoadingPage> createState() => _MyLoadingPageState();
}
class _MyLoadingPageState extends State<MyLoadingPage>{

  final FirebaseAuth _auth = FirebaseAuth.instance;

  UserData? utilisateur;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    loadAnimation();
  }

  Future<Timer> loadAnimation() async {
    return Timer(
      const Duration(seconds: 10),
      onLoaded
    );
  }


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
  Future<UserData?> getCurrentUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      return await getUserData(user.uid);
    }
    return null; // Aucun utilisateur connecté
  }


  Future<void> _loadUserData() async {
    // essayer de charger depuis Firebase
    UserData? data = await getCurrentUserData();

    if (data != null) {
      await saveUserDataLocally(data); // si connecté, on sauvegarde en local
    } else {
      data = await loadUserDataLocally(); // sinon on essaie de charger en local
    }

    Provider.of<UserProvider>(context, listen: false).setUserData(data);

  }

  onLoaded() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? connected = prefs.getBool('connected') ?? false;
    if(connected == false){
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => LoginPage2(),
          )
      );
      return;
    }
    if(connected == true){
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => MaterialApp(
            debugShowCheckedModeBanner: false,
            themeMode: Provider.of<ThemeProvider>(context, listen: false).isDarkMode
                ? ThemeMode.dark
                : ThemeMode.light,
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
            ),
            darkTheme: ThemeData.dark(),
            initialRoute: '/home',
            routes: {
              '/home': (context) => const HomePage(),
              '/profile': (context) => ProfilePage(),
              '/equipe': (context) => EquipePage(),
              '/message': (context) => const MessagePage(),
              //'/training': (context) => const TrainingListPage(),
              //'/match': (context) => const MatchPage(),
              '/saved': (context) => const SavedMessagesPage(),
              '/group': (context) => const NewGroupPage(),
              '/settings': (context) => const SettingsPage(),
            },
          ),
        ),
      );
      return;
    }
  }


  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Lottie.asset(
            "assets/lotties/animation.json",
          repeat: false,
        ),
      ),
    );
  }
}

