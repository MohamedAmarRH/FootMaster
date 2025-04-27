import 'package:flutter/material.dart';
import '../classes/PlayerStorageService.dart';
import '../classes/player.dart';
import '../widgets/custom_drawer.dart';
import 'equipe_new.dart';

class EquipePage extends StatefulWidget {
  const EquipePage({super.key});

  @override
  _EquipePageState createState() => _EquipePageState();
}

class _EquipePageState extends State<EquipePage> {
  final PlayerStorageService _storageService = PlayerStorageService();
  List<Player> allPlayers = [];
  String searchQuery = '';

  Map<String, (IconData, Color)> _positionStyles = {
    'Goalkeeper': (Icons.sports_handball, Colors.lightBlue),
    'Defender': (Icons.shield, Colors.green),
    'Midfielder': (Icons.sync_alt, Colors.orange),
    'Forward': (Icons.sports_soccer, Colors.red),
  };

  final List<String> categories = ['Goalkeeper', 'Defender', 'Midfielder', 'Forward'];

  @override
  void initState() {
    super.initState();
    _loadPlayers();
  }

  Future<void> _loadPlayers() async {
    final players = await _storageService.loadPlayers();
    setState(() {
      allPlayers = players;
    });
  }

  List<Player> _filterPlayers(String category) {
    return allPlayers.where((p) =>
    p.position == category &&
        "${p.firstName} ${p.lastName}".toLowerCase().contains(searchQuery.toLowerCase())
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Équipe'),
        backgroundColor: Colors.black38,
        actions: [
          IconButton(onPressed: _loadPlayers, icon: const Icon(Icons.refresh)),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreatePlayerPage()),
              ).then((_) => _loadPlayers());
            },
            icon: const Icon(Icons.add),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) => setState(() => searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Rechercher un joueur',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ),
      ),
      drawer: const CustomDrawer(currentPage: 'equipe'),
      body: allPlayers.isEmpty
          ? const Center(child: Text("Aucun joueur pour l'instant 🧐"))
          : ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, index) {
          String category = categories[index];
          List<Player> filtered = _filterPlayers(category);
          if (filtered.isEmpty) return const SizedBox();
          final (icon, color) = _positionStyles[category]!;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Icon(icon, color: color),
                  const SizedBox(width: 8),
                  Text(
                    category,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
                  ),
                ]),
                const SizedBox(height: 10),
                ...filtered.map((player) => Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: Icon(icon, color: color),
                    title: Text("${player.firstName} ${player.lastName}"),
                    subtitle: Text("Pied préféré : ${player.preferredFoot}"),
                    trailing: IconButton(
                      icon: const Icon(Icons.info_outline),
                      onPressed: () => _showPlayerDetails(context, player),
                    ),
                    onLongPress: () => _showPlayerOptions(context, player),
                  ),
                )),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showPlayerDetails(BuildContext context, Player player) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("${player.firstName} ${player.lastName}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text("📅 Naissance:"), Text(player.birthdate),
            ]),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text("🏠 Adresse:"), Text(player.address),
            ]),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text("📞 Téléphone:"), Text(player.phone),
            ]),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text("📧 Email:"), Text(player.email),
            ]),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text("📅 Arrivée:"), Text(player.arrivalDate),
            ]),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text("🦵 Pied préféré:"), Text(player.preferredFoot),
            ]),
          ],
        ),
      ),
    );
  }

  void _showPlayerOptions(BuildContext context, Player player) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Options du joueur"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text("🗑️ Supprimer le joueur"),
              onTap: () {
                Navigator.pop(context);
                _confirmDeletePlayer(context, player);
              },
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
        ],
      ),
    );
  }

  void _confirmDeletePlayer(BuildContext context, Player player) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirmer la suppression"),
        content: Text("Voulez-vous vraiment supprimer ${player.firstName} ${player.lastName} ?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _storageService.deletePlayerByFullName(player.firstName, player.lastName);
              await _loadPlayers();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("✅ ${player.firstName} supprimé"), duration: const Duration(seconds: 2)),
              );
            },
            child: const Text("Supprimer", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
