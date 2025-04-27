import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../provider/theme_provider.dart';
import '../screens/login_page2.dart';
import '../service/change_password_page.dart';
import '../service/delete_account_service.dart';
import '../widgets/custom_drawer.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
        backgroundColor: Colors.black38,
        elevation: 10,
      ),
      drawer: const CustomDrawer(currentPage: 'settings'),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Paramètres de l\'application',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: const Text('Mode sombre'),
                        value: themeProvider.isDarkMode,
                        onChanged: (value) => themeProvider.toggleTheme(),
                        secondary: const Icon(Icons.nightlight_round),
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.lock_reset),
                        title: const Text('Changer le mot de passe'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.of(context).push(
                            PageRouteBuilder(
                              pageBuilder: (context, animation, secondaryAnimation) => const ChangePasswordPage(),
                              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                final fade = Tween(begin: 0.0, end: 1.0).animate(animation);
                                final scale = Tween(begin: 0.95, end: 1.0).animate(
                                  CurvedAnimation(parent: animation, curve: Curves.easeInOut),
                                );
                                return FadeTransition(
                                  opacity: fade,
                                  child: ScaleTransition(scale: scale, child: child),
                                );
                              },
                              transitionDuration: const Duration(milliseconds: 500),
                            ),
                          );
                        },

                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.contact_mail_outlined),
                        title: const Text('Nous contacter'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text("Nous contacter"),
                              content: const Text("Envoyez-nous un email à : .com"),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Compte',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Card(
                elevation: 5,
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.delete_forever_outlined),
                      title: const Text('Supprimer votre compte'),
                      textColor: Colors.red,
                      iconColor: Colors.red,
                      onTap: () async {
                        final password = await showDeleteAccountDialog(context);
                        if (password == null || password.isEmpty) return;

                        try {
                          await deleteUserAccount(password);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Compte supprimé avec succès")),
                          );
                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          prefs.setBool('connected', false);
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => LoginPage2()), // Remplacez LoginPage par votre page de connexion
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Erreur : ${e.toString()}")),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
