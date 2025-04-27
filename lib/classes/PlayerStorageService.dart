import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'player.dart'; // ou le chemin correct vers ton modèle Player

class PlayerStorageService {
  static const String _key = 'players';

  /// Sauvegarder la liste de joueurs
  Future<void> savePlayers(List<Player> players) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> playerJsonList =
    players.map((p) => jsonEncode(p.toJson())).toList();
    await prefs.setStringList(_key, playerJsonList);
  }

  /// Charger la liste de joueurs (méthode attendue)
  Future<List<Player>> getPlayers() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? playerJsonList = prefs.getStringList(_key);

    if (playerJsonList == null) return [];

    return playerJsonList
        .map((jsonStr) => Player.fromJson(jsonDecode(jsonStr)))
        .toList();
  }

  // Charger la liste
  Future<List<Player>> loadPlayers() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? playerJsonList = prefs.getStringList(_key);
    if (playerJsonList == null) return [];
    return playerJsonList.map((e) => Player.fromJson(jsonDecode(e))).toList();
  }


  Future<void> deletePlayerByFullName(String firstName, String lastName) async {
    final players = await getPlayers();
    final updatedPlayers = players.where(
            (p) => p.firstName.toLowerCase() != firstName.toLowerCase() || p.lastName.toLowerCase() != lastName.toLowerCase()
    ).toList();
    await savePlayers(updatedPlayers);
  }

}
