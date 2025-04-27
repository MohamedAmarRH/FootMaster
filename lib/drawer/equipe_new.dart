import 'package:flutter/material.dart';
import '../classes/PlayerStorageService.dart';
import '../classes/player.dart';

class CreatePlayerPage extends StatefulWidget {
  const CreatePlayerPage({super.key});

  @override
  State<CreatePlayerPage> createState() => _CreatePlayerPageState();
}

final PlayerStorageService _storageService = PlayerStorageService();
List<Player> playerList = [];

class _CreatePlayerPageState extends State<CreatePlayerPage> {
  final _formKey = GlobalKey<FormState>();

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final birthdateController = TextEditingController();
  final addressController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final arrivalDateController = TextEditingController();

  String position = 'Goalkeeper';
  String preferredFoot = 'Right';

  bool showPreview = false;

  InputDecoration _inputDecoration(String label, IconData icon) {
    final theme = Theme.of(context);
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: theme.iconTheme.color),
      filled: true,
      fillColor: theme.inputDecorationTheme.fillColor,
      labelStyle: theme.textTheme.bodyLarge,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: theme.colorScheme.secondary, width: 2),
      ),
    );
  }

  void _savePlayer() async {
    if (_formKey.currentState!.validate()) {
      final newPlayer = Player(
        firstName: firstNameController.text,
        lastName: lastNameController.text,
        birthdate: birthdateController.text,
        address: addressController.text,
        phone: phoneController.text,
        email: emailController.text,
        arrivalDate: arrivalDateController.text,
        position: position,
        preferredFoot: preferredFoot,
      );

      List<Player> existingPlayers = await _storageService.getPlayers();
      existingPlayers.add(newPlayer);
      await _storageService.savePlayers(existingPlayers);

      showPreview = false;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.greenAccent.shade400,
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text("Joueur créé avec succès !", style: TextStyle(color: Colors.white)),
            ],
          ),
          duration: const Duration(seconds: 2),
        ),
      );

      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pop(context);
      });
    }
  }

  Widget _buildPreviewCard() {
    final theme = Theme.of(context);
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 500),
      opacity: showPreview ? 1.0 : 0.0,
      child: Card(
        color: theme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 6,
        margin: const EdgeInsets.symmetric(vertical: 16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("👤 ${firstNameController.text} ${lastNameController.text}", style: theme.textTheme.titleMedium),
              const SizedBox(height: 4),
              Text("🎂 Naissance: ${birthdateController.text}", style: theme.textTheme.bodyMedium),
              Text("🏠 Adresse: ${addressController.text}", style: theme.textTheme.bodyMedium),
              Text("📞 Téléphone: ${phoneController.text}", style: theme.textTheme.bodyMedium),
              Text("📧 Email: ${emailController.text}", style: theme.textTheme.bodyMedium),
              Text("📅 Arrivée: ${arrivalDateController.text}", style: theme.textTheme.bodyMedium),
              Text("🎯 Position: $position", style: theme.textTheme.bodyMedium),
              Text("🦶 Pied préféré: $preferredFoot", style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.black38,
        title: const Text("Créer un joueur", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            onChanged: () => setState(() => showPreview = true),
            child: Column(
              children: [
                const SizedBox(height: 10),
                TextFormField(
                  controller: firstNameController,
                  style: theme.textTheme.bodyLarge,
                  decoration: _inputDecoration("Prénom", Icons.person_outline),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: lastNameController,
                  style: theme.textTheme.bodyLarge,
                  decoration: _inputDecoration("Nom", Icons.person),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: birthdateController,
                  style: theme.textTheme.bodyLarge,
                  decoration: _inputDecoration("Date de naissance", Icons.cake),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: addressController,
                  style: theme.textTheme.bodyLarge,
                  decoration: _inputDecoration("Adresse", Icons.home),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: phoneController,
                  style: theme.textTheme.bodyLarge,
                  decoration: _inputDecoration("Téléphone", Icons.phone),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: emailController,
                  style: theme.textTheme.bodyLarge,
                  decoration: _inputDecoration("Email", Icons.email),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: arrivalDateController,
                  style: theme.textTheme.bodyLarge,
                  decoration: _inputDecoration("Date d'arrivée", Icons.event),
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  dropdownColor: theme.dialogBackgroundColor,
                  value: position,
                  decoration: _inputDecoration("Position", Icons.sports_soccer),
                  style: theme.textTheme.bodyLarge,
                  items: ['Goalkeeper', 'Defender', 'Midfielder', 'Forward']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (value) => setState(() => position = value!),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  dropdownColor: theme.dialogBackgroundColor,
                  value: preferredFoot,
                  decoration: _inputDecoration("Pied préféré", Icons.directions_walk),
                  style: theme.textTheme.bodyLarge,
                  items: ['Right', 'Left', 'Both']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (value) => setState(() => preferredFoot = value!),
                ),
                if (showPreview) _buildPreviewCard(),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _savePlayer,
        label: const Text("Sauvegarder"),
        icon: const Icon(Icons.check),
        backgroundColor: Colors.orange,
        elevation: 6,
      ),
    );
  }
}
