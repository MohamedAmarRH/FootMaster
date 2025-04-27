import 'package:shared_preferences/shared_preferences.dart';
import '../classes/user.dart';

Future<void> saveUserDataLocally(UserData user) async {
  final prefs = await SharedPreferences.getInstance();

  await prefs.setString('nom', user.nom ?? 'Empty');
  await prefs.setString('prenom', user.prenom ?? 'Empty');
  await prefs.setString('date_naissance', user.date_naissance ?? 'Empty');
  await prefs.setString('adresse', user.adresse ?? 'Empty');
  await prefs.setString('email', user.email ?? 'Empty');
  await prefs.setString('pied', user.pied ?? 'Empty');
  await prefs.setString('password', user.password ?? 'Empty');
  await prefs.setString('statut', user.status ?? 'Empty');
  await prefs.setString('telephone_complet', user.telephone_complet ?? 'Empty');
  await prefs.setBool('connected', true ?? false);
  await prefs.setString('imageURL', "aucune" ?? "aucune");
  await prefs.setStringList(
    'selected_positions',
    user.selected_positions ?? [],
  );}

Future<UserData?> loadUserDataLocally() async {
  final prefs = await SharedPreferences.getInstance();
  final nom = prefs.getString('nom');
  final prenom = prefs.getString('prenom');
  final date_naissance = prefs.getString('date_naissance');
  final adresse = prefs.getString('adresse');
  final email = prefs.getString('email');
  final pied = prefs.getString('pied');
  final password = prefs.getString('password');
  final statut = prefs.getString('statut');
  final telephone_complet = prefs.getString('telephone_complet');
  final connected = prefs.getBool('connected');
  final selected_positions = prefs.getStringList('selected_positions');
  final imageURL = prefs.getString('imageURL');

  if (nom != null && email != null || prenom != null && date_naissance != null || adresse != null && password != null || telephone_complet != null && connected != null && imageURL != null) {
    return UserData(nom: nom, prenom: prenom,date_naissance: date_naissance, adresse: adresse,email: email, pied: pied, password: password,status: statut, telephone_complet: telephone_complet,connected: connected,imageURL: imageURL,  selected_positions: selected_positions);
  }
  return null;
}
