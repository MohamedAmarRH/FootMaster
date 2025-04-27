import 'dart:async';
import 'package:bcrypt/bcrypt.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled1/screens/signup_page.dart';
import '../animation/OnboardingPage.dart';
import '../classes/user.dart';
import '../classes/user_data.dart';
import 'login_page2.dart';

class EmailVerificationPage extends StatefulWidget {
  final String? email;
  final Map<String, dynamic>? userData;
  final String? userId;

  const EmailVerificationPage({
    required this.userId,
    this.email,
    this.userData,
    Key? key,
  }) : super(key: key);

  @override
  _EmailVerificationPageState createState() => _EmailVerificationPageState();
}

Future<void> setConnected(bool b) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool('connected', b);
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _codeController = TextEditingController();
  bool _isLoading = false;
  bool _isCodeValid = true;
  bool _isVerified = false;

  Timer? _redirectTimer;
  Timer? _countdownTimer;
  Duration _remainingTime = Duration(minutes: 1);

  Future<void> saveUserData2(UserData user, bool connected) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setString('nom', user.nom ?? 'Empty');
    await prefs.setString('prenom', user.prenom ?? 'Empty');
    await prefs.setString('date_naissance', user.date_naissance ?? 'Empty');
    await prefs.setString('adresse', user.adresse ?? 'Empty');
    await prefs.setString('email', user.email ?? 'Empty');
    await prefs.setString('password', user.password ?? 'Empty');
    await prefs.setString('statut', user.status ?? 'Empty');
    await prefs.setString('telephone_complet', user.telephone_complet ?? 'Empty');
    await prefs.setBool('connected', connected ?? false);
  }

  @override
  void initState() {
    super.initState();

    // Timer pour redirection automatique après 1 minute
    _redirectTimer = Timer(_remainingTime, () async {
      if (!_isVerified && mounted) {
        UserCredential userCredential2 = userCredential1;
        await userCredential2.user?.delete();
        Navigator.pop(context); // Retour à la page précédente
      }
    });

    // Timer pour mettre à jour le compte à rebours chaque seconde
    _countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingTime.inSeconds > 0) {
        setState(() {
          _remainingTime -= Duration(seconds: 1);
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _redirectTimer?.cancel();
    _countdownTimer?.cancel();
    _codeController.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${twoDigits(duration.inMinutes)}:${twoDigits(duration.inSeconds.remainder(60))}";
  }

  Future<void> _verifyCode() async {
    setState(() {
      _isLoading = true;
      _isCodeValid = true;
    });

    if (_codeController.text.trim() == codeverification) {
      await _saveUserData();
      setState(() {
        _isVerified = true;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isCodeValid = false;
        _isLoading = false;
      });
    }
  }

  Future<void> _saveUserData() async {
    if (widget.userData != null && widget.userId != null) {
      try {
        await _firestore.collection('users').doc(widget.userId).set({
          ...widget.userData!,
          'emailVerified': true,
          'verifiedAt': FieldValue.serverTimestamp(),
          'status': 'active',
          'lastLogin': FieldValue.serverTimestamp(),
          'connected': true,
          'imageURL': "",
        }, SetOptions(merge: true));
        saveUserData2(UserData.fromMap(widget.userData!), true);
        setConnected(true);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Erreur lors de la sauvegarde des données: $e")),
          );
        }
      }
    }
  }

  Future<void> _redirectToLogin() async {
    UserCredential userCredential2 = userCredential1;
    await userCredential2.user?.delete();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage2()),
    );
  }

  void _redirectToHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => OnboardingPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            colors: [
              Colors.green[900]!,
              Colors.green[800]!,
              Colors.green[400]!,
            ],
          ),
        ),
        child: Center(
          child: Container(
            margin: EdgeInsets.all(20),
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: _isVerified ? _buildVerifiedContent() : _buildCodeInputContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildCodeInputContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.lock, size: 80, color: Colors.green),
        SizedBox(height: 10),
        Text(
          "Temps restant : ${_formatDuration(_remainingTime)}",
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        Text(
          "Entrez le code de vérification",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        Text(
          "Nous avons envoyé un code à votre adresse email :",
          textAlign: TextAlign.center,
        ),
        Text(
          widget.email ?? '',
          style: TextStyle(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 20),
        TextField(
          controller: _codeController,
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
            labelText: "Code de vérification",
            errorText: _isCodeValid ? null : "Code incorrect",
            border: OutlineInputBorder(),
          ),
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: _isLoading ? null : _verifyCode,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green[800],
            minimumSize: Size(200, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: _isLoading
              ? CircularProgressIndicator(color: Colors.white)
              : Text(
            "Vérifier",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
        SizedBox(height: 10),
        TextButton(
          onPressed: _redirectToLogin,
          child: Text("Retour à la connexion"),
        ),
      ],
    );
  }

  Widget _buildVerifiedContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.check_circle, size: 80, color: Colors.green),
        SizedBox(height: 20),
        Text(
          "Email vérifié avec succès!",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 20),
        Text(
          "Votre adresse email a été confirmée. Vous pouvez maintenant accéder à toutes les fonctionnalités.",
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 30),
        ElevatedButton(
          onPressed: _redirectToHome,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green[800],
            minimumSize: Size(200, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: Text(
            "Continuer",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
      ],
    );
  }
}
