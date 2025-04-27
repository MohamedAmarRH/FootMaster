import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';
import 'package:animated_background/animated_background.dart';

class VaultPage extends StatefulWidget {
  const VaultPage({super.key});

  @override
  State<VaultPage> createState() => _VaultPageState();
}

class _VaultPageState extends State<VaultPage> with TickerProviderStateMixin {
  String enteredPassword = '';
  final String correctPassword = '1234';
  final int passwordLength = 4;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fond animé sombre
          AnimatedBackground(
            vsync: this,
            behaviour: RandomParticleBehaviour(
              options: ParticleOptions(
                baseColor: Colors.deepPurple.shade900,
                spawnOpacity: 0.4,
                opacityChangeRate: 0.25,
                minOpacity: 0.2,
                maxOpacity: 0.6,
                spawnMinSpeed: 20.0,
                spawnMaxSpeed: 60.0,
                spawnMinRadius: 5.0,
                spawnMaxRadius: 15.0,
                particleCount: 70,
              ),
            ),
            child: Container(),
          ),

          // Overlay sombre pour contraster le texte
          Container(color: Colors.black.withOpacity(0.5)),

          // Interface
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 40),
                const Icon(Icons.lock_outline, size: 60, color: Colors.white),
                const SizedBox(height: 20),
                const Text(
                  'Entrez votre code secret',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 30),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: Text(
                    enteredPassword.isEmpty
                        ? ''
                        : '•' * enteredPassword.length,
                    key: ValueKey(enteredPassword),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      letterSpacing: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Expanded(
                  child: GridView.count(
                    padding: const EdgeInsets.all(20),
                    crossAxisCount: 3,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 20,
                    childAspectRatio: 1.1,
                    children: List.generate(12, (index) {
                      if (index == 9) return const SizedBox.shrink();
                      if (index == 10) return _buildButton('0');
                      if (index == 11) return _buildBackspaceButton();
                      return _buildButton((index + 1).toString());
                    }),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(String value) {
    return InkWell(
      onTap: () => _onDigitTap(value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackspaceButton() {
    return IconButton(
      onPressed: _onBackspace,
      icon: const Icon(Icons.backspace, size: 28, color: Colors.white70),
    );
  }

  void _onDigitTap(String digit) async {
    if (enteredPassword.length >= passwordLength) return;

    setState(() {
      enteredPassword += digit;
    });

    SystemSound.play(SystemSoundType.click);
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 50);
    }

    if (enteredPassword.length == passwordLength) {
      _validatePassword();
    }
  }

  void _onBackspace() async {
    if (enteredPassword.isEmpty) return;

    setState(() {
      enteredPassword =
          enteredPassword.substring(0, enteredPassword.length - 1);
    });

    SystemSound.play(SystemSoundType.click);
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 30);
    }
  }

  void _validatePassword() async {
    await Future.delayed(const Duration(milliseconds: 300));

    if (enteredPassword == correctPassword) {
      if (await Vibration.hasVibrator() ?? false) {
        Vibration.vibrate(pattern: [100, 50, 100]);
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SuccessPage()),
      );
    } else {
      if (await Vibration.hasVibrator() ?? false) {
        Vibration.vibrate(duration: 500);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Code incorrect'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );

      setState(() => enteredPassword = '');
    }
  }
}

class SuccessPage extends StatelessWidget {
  const SuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.check_circle_outline,
                size: 100, color: Colors.greenAccent),
            SizedBox(height: 20),
            Text(
              'Accès autorisé',
              style: TextStyle(
                color: Colors.greenAccent,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
