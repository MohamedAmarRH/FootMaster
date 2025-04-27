import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';



class FormationPage2 extends StatefulWidget {
  @override
  _FormationPageState createState() => _FormationPageState();
}

class _FormationPageState extends State<FormationPage2> {
  Set<String> selectedPositions = {};
  String selectedFormation = '4-3-3';

  final Map<String, List<String>> formations = {
    '4-3-3': ['GK', 'LB', 'CB1', 'CB2', 'RB', 'CM1', 'CM2', 'CM3', 'LW', 'RW', 'ST'],
    '4-2-1-3': ['GK', 'LB', 'CB1', 'CB2', 'RB', 'DM1', 'DM2', 'CAM', 'LW', 'RW', 'ST'],
    '3-5-2': ['GK', 'CB4', 'CB5', 'CB3', 'LM', 'RM', 'CM4', 'CM5', 'CAM1', 'ST1', 'ST2'],
  };

  final Map<String, Offset> positionCoordinates = {
    'GK': Offset(0.50, 0.70),
    'LB': Offset(0.20, 0.55),
    'CB1': Offset(0.35, 0.61),
    'CB2': Offset(0.60, 0.61),
    'CB3': Offset(0.50, 0.60),
    'CB4': Offset(0.25, 0.58),
    'CB5': Offset(0.72, 0.58),
    'RB': Offset(0.80, 0.55),
    'DM1': Offset(0.30, 0.46),
    'DM2': Offset(0.67, 0.46),
    'CM1': Offset(0.25, 0.43),
    'CM2': Offset(0.50, 0.43),
    'CM3': Offset(0.72, 0.43),
    'CM4': Offset(0.30, 0.50),
    'CM5': Offset(0.67, 0.50),
    'CAM': Offset(0.50, 0.39),
    'CAM1': Offset(0.50, 0.36),
    'LW': Offset(0.20, 0.25),
    'RW': Offset(0.80, 0.25),
    'LM': Offset(0.20, 0.36),
    'RM': Offset(0.80, 0.36),
    'ST': Offset(0.50, 0.25),
    'ST1': Offset(0.35, 0.20),
    'ST2': Offset(0.63, 0.20),
  };

  @override
  Widget build(BuildContext context) {
    List<String> currentPositions = formations[selectedFormation]!;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return PopScope(
      canPop: false, // Désactive le retour arrière
      child: Scaffold(
        appBar: AppBar(
          title: Text("Formation - $selectedFormation"),
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false, // Cache l'icône de retour
        ),
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            Positioned.fill(child: Container(color: Colors.black)),

            Center(
              child: Container(
                width: screenWidth * 0.95,
                height: screenHeight * 0.8,
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: Image.asset('assets/images/terrain.jpg'),
                ),
              ),
            ),

            // Sélecteur de formation
            Positioned(
              top: 10,
              left: 10,
              right: 10,
              child: SizedBox(
                height: 50,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: formations.keys.map((formation) {
                    final isSelected = formation == selectedFormation;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            selectedFormation = formation;
                            selectedPositions.clear();
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isSelected ? Colors.red : Colors.grey[800],
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          minimumSize: Size(60, 40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          formation,
                          style: TextStyle(fontSize: 14, color: Colors.white),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            // Positions des joueurs
            ...currentPositions.map((posName) {
              final offset = positionCoordinates[posName] ?? Offset(0.5, 0.5);
              final isSelected = selectedPositions.contains(posName);
              final positionSize = screenWidth * 0.08;

              return Positioned(
                top: screenHeight * offset.dy - positionSize,
                left: screenWidth * offset.dx - positionSize,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        selectedPositions.remove(posName);
                      } else {
                        if (selectedPositions.length < 3) {
                          selectedPositions.add(posName);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Vous ne pouvez sélectionner que 3 positions.")),
                          );
                        }
                      }
                    });
                  },
                  child: Container(
                    width: positionSize * 2,
                    height: positionSize * 2,
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.red.withOpacity(0.8) : Colors.grey[800]!.withOpacity(0.8),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 5,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        posName.replaceAll(RegExp(r'[0-9]'), ''),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: positionSize * 0.3,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),

            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: ElevatedButton(
                onPressed: () {
                  if (selectedPositions.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Vous devez choisir au moins 1 position")),
                    );
                  } else {
                    saveSelectedPositions();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Succés de changement de position")),
                    );
                    Navigator.of(context).pop();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[700],
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 5,
                ),
                child: Text(
                  "SAUVEGARDER",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void saveSelectedPositions() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      List<String> selectedPositionsList = selectedPositions.toList();

      await FirebaseFirestore.instance.collection('users')
          .doc(user.uid)
          .update({
        'selected_positions': selectedPositionsList,
      });

      print('Positions sauvegardées : $selectedPositionsList');
    } else {
      print('Aucun utilisateur connecté.');
    }
  }
}
