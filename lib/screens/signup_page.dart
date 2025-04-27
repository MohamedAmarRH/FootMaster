import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_page2.dart';
import 'verification.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

String codeverification = "";
late UserCredential userCredential1;
late String nom_user = "";
late String prenom_user = "";
late String email_user = "";

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();

  final List<String> optionpied = ['Gauche','Droit','Les deux'];
  String? piedchoisi = 'Droit';

  String? _nameError, _surnameError, _addressError, _phoneError, _emailError, _passwordError, _confirmPasswordError, _dobError;
  bool _isLoading = false;

  String _countryDialCode = '';
  String _nationalNumber = '';
  String _fullPhoneNumber = '';

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _validateForm() {
    bool isValid = true;

    setState(() {
      _nameError = _nameController.text.isEmpty ? "Veuillez entrer votre nom" : null;
      _surnameError = _surnameController.text.isEmpty ? "Veuillez entrer votre prénom" : null;
      _addressError = _addressController.text.isEmpty ? "Veuillez entrer votre adresse" : null;
      _phoneError = _nationalNumber.isEmpty ? "Veuillez entrer votre téléphone" : null;
      _emailError = _emailController.text.isEmpty
          ? "Veuillez entrer votre email"
          : (!_emailController.text.contains('@') ? "Email invalide" : null);
      _passwordError = _passwordController.text.isEmpty
          ? "Veuillez entrer un mot de passe"
          : (_passwordController.text.length < 6 ? "Minimum 6 caractères" : null);
      _confirmPasswordError = _confirmPasswordController.text.isEmpty
          ? "Veuillez confirmer votre mot de passe"
          : (_confirmPasswordController.text != _passwordController.text
          ? "Les mots de passe ne correspondent pas"
          : null);
      _dobError = _dobController.text.isEmpty ? "Veuillez entrer votre date de naissance" : null;
    });

    isValid &= _nameController.text.isNotEmpty;
    isValid &= _surnameController.text.isNotEmpty;
    isValid &= _addressController.text.isNotEmpty;
    isValid &= _nationalNumber.isNotEmpty;
    isValid &= _emailController.text.isNotEmpty && _emailController.text.contains('@');
    isValid &= _passwordController.text.isNotEmpty && _passwordController.text.length >= 6;
    isValid &= _confirmPasswordController.text == _passwordController.text;
    isValid &= _dobController.text.isNotEmpty;

    return isValid;
  }


  Future<void> _registerUser() async {
    if (!_validateForm()) return;

    setState(() => _isLoading = true);

    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      userCredential1 = userCredential;

      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String uid = user.uid;
        final hashed = BCrypt.hashpw(uid, BCrypt.gensalt());
        codeverification = hashed[11] + hashed[13] + hashed[15] + hashed[18] + hashed[23] + hashed[10] + hashed[25] + hashed[30];
        await user.updateDisplayName("${_nameController.text.trim()}, here is your code: $codeverification");
      }
      nom_user = _nameController.text.trim();
      prenom_user = _surnameController.text.trim();
      email_user = _emailController.text.trim();

      final Map<String, dynamic> userData = {
        'nom': _nameController.text.trim(),
        'prenom': _surnameController.text.trim(),
        'date_naissance': _dobController.text.trim(),
        'adresse': _addressController.text.trim(),
        'indicatif': _countryDialCode,
        'numero': _nationalNumber,
        'telephone_complet': _fullPhoneNumber,
        'email': _emailController.text.trim(),
        'password': _passwordController.text.trim(),
        'emailVerified': false,
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'pending_verification',
        'pied': piedchoisi,
        'connected': false,
        'imageURL' : ""
      };

      await user?.sendEmailVerification();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => EmailVerificationPage(
            email: _emailController.text.trim(),
            userData: userData,
            userId: user?.uid,
          ),
        ),
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage = "Erreur lors de l'inscription";
      switch (e.message) {
        case 'email-already-in-use':
          errorMessage = "Cet email est déjà utilisé";
          break;
        case 'invalid-email':
          errorMessage = "Email invalide";
          break;
        case 'operation-not-allowed':
          errorMessage = "Opération non autorisée";
          break;
        case 'weak-password':
          errorMessage = "Mot de passe trop faible";
          break;
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur inattendue: ${e.toString()}")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (selectedDate != null) {
      setState(() {
        _dobController.text = "${selectedDate.day.toString().padLeft(2, '0')}/"
            "${selectedDate.month.toString().padLeft(2, '0')}/"
            "${selectedDate.year}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              colors: [
                Colors.green[900]!,
                Colors.green[800]!,
                Colors.green[400]!
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: 50),
              Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text("Inscription", style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    Text("Créez votre compte", style: TextStyle(color: Colors.white, fontSize: 18))
                  ],
                ),
              ),
              SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(60), topRight: Radius.circular(60)),
                ),
                child: Padding(
                  padding: EdgeInsets.all(30),
                  child: Column(
                    children: <Widget>[
                      SizedBox(height: 30),
                      _buildInputField(_nameController, "Nom", Icons.person, errorText: _nameError),
                      SizedBox(height: 10),
                      _buildInputField(_surnameController, "Prénom", Icons.person_outline, errorText: _surnameError),
                      SizedBox(height: 10),
                      GestureDetector(
                        onTap: () => _selectDate(context),
                        child: AbsorbPointer(
                          child: _buildInputField(_dobController, "Date de naissance", Icons.calendar_today, errorText: _dobError),
                        ),
                      ),
                      SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Pied préféré',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.green[800]!),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        value: "Droit",
                        hint: Text('Sélectionnez un pied'),
                        items: optionpied.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            piedchoisi = newValue;
                          });
                        },
                      ),
                      SizedBox(height: 10),
                      _buildInputField(_addressController, "Adresse", Icons.home, errorText: _addressError),
                      SizedBox(height: 10),
                      IntlPhoneField(
                        decoration: InputDecoration(
                          labelText: 'Téléphone',
                          prefixIcon: Icon(Icons.phone, color: Colors.green[800]),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          errorText: _phoneError,
                        ),
                        onChanged: (phone) {
                          setState(() {
                            _countryDialCode = phone.countryCode;
                            _nationalNumber = phone.number;
                            _fullPhoneNumber = phone.completeNumber;
                          });
                        },
                        initialCountryCode: 'TN',
                      ),
                      _buildInputField(_emailController, "Email", Icons.email, keyboardType: TextInputType.emailAddress, errorText: _emailError),
                      SizedBox(height: 10),
                      _buildInputField(_passwordController, "Mot de passe", Icons.lock, obscureText: true, errorText: _passwordError),
                      SizedBox(height: 10),
                      _buildInputField(_confirmPasswordController, "Confirmer mot de passe", Icons.lock, obscureText: true, errorText: _confirmPasswordError),
                      SizedBox(height: 30),
                      _buildSignupButton(),
                      SizedBox(height: 20),
                      _buildLoginButton(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(TextEditingController controller, String label, IconData icon, {bool obscureText = false, TextInputType? keyboardType, String? errorText}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.green[800]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.green[800]!),
          borderRadius: BorderRadius.circular(10),
        ),
        errorText: errorText,
      ),
    );
  }

  Widget _buildSignupButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _registerUser,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green[800],
          padding: EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        child: _isLoading
            ? CircularProgressIndicator(color: Colors.white)
            : Text("S'INSCRIRE", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildLoginButton() {
    return TextButton(
      onPressed: () {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage2()));
      },
      child: RichText(
        text: TextSpan(
          text: "Vous avez déjà un compte? ",
          style: TextStyle(color: Colors.grey),
          children: [
            TextSpan(
              text: "Connectez-vous",
              style: TextStyle(color: Colors.orange[800], fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
