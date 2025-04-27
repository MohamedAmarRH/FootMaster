import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../classes/user_data.dart';
import '../classes/user_session.dart';
import '../drawer/equipe.dart';
import '../drawer/message/chat_page.dart';
import '../drawer/new_group_page.dart';
import '../drawer/profile_page.dart';
import '../drawer/saved_messages_page.dart';
import '../drawer/settings_page.dart';
import '../provider/theme_provider.dart';
import 'home_page.dart';
import 'signup_page.dart';
final database = FirebaseDatabase.instance;


class LoginPage2 extends StatefulWidget {
  @override
  _LoginPage2State createState() => _LoginPage2State();
}

class _LoginPage2State extends State<LoginPage2> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? user = FirebaseAuth.instance.currentUser;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String? emailError;
  String? passwordError;

  bool isValidEmail(String email) {
    final RegExp emailRegex = RegExp(
      r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$",
    );
    return emailRegex.hasMatch(email);
  }

  Future<void> setConnected(bool b) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('connected', b);
  }

  void resetPassword() async {
    String email = emailController.text.trim();

    if (email.isEmpty) {
      setState(() {
        emailError = "Veuillez entrer votre email.";
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Veuillez entrer votre email."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    } else if (!isValidEmail(email)) {
      setState(() {
        emailError = "Veuillez entrer un email valide.";
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Veuillez entrer un email valide."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      emailError = null;
    });

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Email de réinitialisation envoyé !"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erreur : ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void ajouterUtilisateur(String userId, String email, DateTime date) {
    final ref = database.ref("users/$userId");

    ref.set({
      "userId": userId,
      "email": email,
      "LastLogin": date.toIso8601String(),
    }).then((_) {
      print("Utilisateur ajouté !");
    }).catchError((error) {
      print("Erreur : $error");
    });
  }

  Future<void> _saveUserData() async {
    final user = this.user;
    String uid = '';
    if (user != null) {
      uid = user.uid;
    }
    if (user != null && uid != null) {
      try {
        await _firestore.collection('users').doc(uid).set({
          'lastLogin': FieldValue.serverTimestamp(),
          'connected': true,
        }, SetOptions(merge: true));
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Erreur lors de la sauvegarde des données: $e")),
          );
        }
      }
    }
  }

  void loginUser() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        emailError = email.isEmpty ? "Veuillez entrer votre email." : null;
        passwordError = password.isEmpty ? "Veuillez entrer votre mot de passe." : null;
      });
      return;
    }

    if (!isValidEmail(email)) {
      setState(() {
        emailError = "Veuillez entrer un email valide.";
      });
      return;
    }

    setState(() {
      emailError = null;
      passwordError = null;
    });

    try {
      print('avant    b b iiii: ');
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = FirebaseAuth.instance.currentUser;
      print('iiii: ${user!.uid}');
      if (user != null) {
        ajouterUtilisateur(user.uid, email, DateTime.now());
      }
      final userData = await UserService().getCurrentUserData();
      if (userData != null) {
        UserSession().setUser(userData);
      }

      _saveUserData();
      setConnected(true);
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
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erreur de connexion : ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            colors: [
              Colors.black87,
              Colors.black,
              Colors.black54
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 30),
            const Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text("LOGIN", style: TextStyle(color: Colors.white, fontSize: 40)),
                  SizedBox(height: 10),
                  Text("Welcome back", style: TextStyle(color: Colors.white, fontSize: 18)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(60),
                    topRight: Radius.circular(60),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(30),
                  child: SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        const SizedBox(height: 30),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: const [
                              BoxShadow(
                                color: Color.fromRGBO(255, 95, 27, 0.3),
                                blurRadius: 20,
                                offset: Offset(0, 10),
                              )
                            ],
                          ),
                          child: Column(
                            children: <Widget>[
                              Container(
                                padding: const EdgeInsets.all(10),
                                child: TextField(
                                  controller: emailController,
                                  decoration: InputDecoration(
                                    labelText: 'Email',
                                    hintText: "Entrez votre email",
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    prefixIcon: const Icon(Icons.email),
                                    errorText: emailError,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(10),
                                child: TextField(
                                  controller: passwordController,
                                  decoration: InputDecoration(
                                    labelText: 'Mot de passe',
                                    hintText: "Entrez votre mot de passe",
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    prefixIcon: const Icon(Icons.lock),
                                    errorText: passwordError,
                                  ),
                                  obscureText: true,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton(
                            onPressed: resetPassword,
                            child: const Text(
                              "Forgot Password?",
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        GestureDetector(
                          onTap: loginUser,
                          child: Container(
                            height: 45,
                            margin: const EdgeInsets.symmetric(horizontal: 50),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              color: Colors.orange[900],
                            ),
                            child: const Center(
                              child: Text("Login",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 25),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => SignupPage()),
                            );
                          },
                          child: Container(
                            height: 45,
                            margin: const EdgeInsets.symmetric(horizontal: 50),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              color: Colors.green[500],
                            ),
                            child: const Center(
                              child: Text(
                                "Sign Up",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

