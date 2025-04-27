import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:untitled1/drawer/profile_page.dart';
import 'dart:async';

import '../animation/formation_page2.dart';
import '../classes/user.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key, required UserData utilisateur});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late TextEditingController _nomController;
  late TextEditingController _prenomController;
  late TextEditingController _telephoneController;
  late TextEditingController _adresseController;
  late TextEditingController _dobController;

  final List<String> optionpied = ['Gauche', 'Droit', 'Les deux'];
  String? piedchoisi;

  String? numero;

  String _countryDialCode = '';
  String _nationalNumber = '';
  String _fullPhoneNumber = '';

  bool _loading = true;

  String? postes = utilisateur2!.selected_positions?.join(', ');

  @override
  void initState() {
    super.initState();
    _nomController = TextEditingController();
    _prenomController = TextEditingController();
    _telephoneController = TextEditingController();
    _adresseController = TextEditingController();
    _dobController = TextEditingController();
    piedchoisi = piedchoisi;
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        _nomController.text = data['nom'] ?? '';
        _prenomController.text = data['prenom'] ?? '';
        _telephoneController.text = data['telephone_complet'] ?? '';
        _adresseController.text = data['adresse'] ?? '';
        _dobController.text = data['date_naissance'] ?? '';
        piedchoisi = data['pied'] ?? "Empty";
        numero = data['numero'] ?? "00000000";
      }
    }
    setState(() {
      _loading = false;
    });
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      if (_nationalNumber.isEmpty) {
        // Affiche une erreur si le numéro est vide
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Le numéro de téléphone est obligatoire")),
        );
        return;
      }

      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'nom': _nomController.text,
          'prenom': _prenomController.text,
          'telephone_complet': _fullPhoneNumber,
          'indicatif': _countryDialCode,
          'numero': _nationalNumber,
          'pied': piedchoisi,
          'adresse': _adresseController.text,
          'date_naissance': _dobController.text,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profil mis à jour avec succès")),
        );
        Navigator.of(context).pop();
      }
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
      appBar: AppBar(
        title: const Text("Modifier le Profil"),
        backgroundColor: Colors.black38,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 600;
          return Center(
            child: Container(
              width: isWide ? 600 : double.infinity,
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    _buildAvatar(),
                    const SizedBox(height: 20),
                    _buildInputField(_nomController, "Nom", Icons.person),
                    SizedBox(height: 10),
                    _buildInputField(_prenomController, "Prénom", Icons.person_outline),
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
                    _buildFakeInputButton(
                      label: "Position préférée(s)",
                      value: "Cliquez pour changer de position",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => FormationPage2()),
                        );
                      },
                    ),
                    SizedBox(height: 10),
                    IntlPhoneField(
                      decoration: InputDecoration(
                        labelText: 'Téléphone',
                        prefixIcon: Icon(Icons.phone, color: Colors.green[800]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        errorText: _nationalNumber.isEmpty ? "Veuillez entrer votre téléphone" : null,
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
                    SizedBox(height: 10),
                    _buildInputField(_adresseController, 'Adresse', Icons.home),
                    SizedBox(height: 10),
                    GestureDetector(
                      onTap: () => _selectDate(context),
                      child: AbsorbPointer(
                        child: _buildInputField(_dobController, "Date de naissance", Icons.calendar_today, errorText: _dobController.text.isEmpty ? "Veuillez entrer votre date de naissance" : null),
                      ),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text("Enregistrer les modifications"),
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAvatar() {
    String nom = _nomController.text;
    return Center(
      child: CircleAvatar(
          radius: 50,
          backgroundColor: Colors.orange,
          child: Text(
            nom.isNotEmpty ? nom[0].toUpperCase() : '?',
            style: const TextStyle(fontSize: 40, color: Colors.white),
          )
      ),
    );
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _telephoneController.dispose();
    _adresseController.dispose();
    _dobController.dispose();
    super.dispose();
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

  Widget _buildFakeInputButton({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[700],
          ),
    ),
        const SizedBox(height: 5),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              value.isNotEmpty ? value : 'Cliquez pour sélectionner',
              style: TextStyle(
                color: value.isNotEmpty ? Colors.black : Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
