import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'ChatPage.dart';

class PersonListPage extends StatefulWidget {
  const PersonListPage({Key? key}) : super(key: key);

  @override
  _PersonListPageState createState() => _PersonListPageState();
}

class _PersonListPageState extends State<PersonListPage> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, dynamic>? _foundUser;
  bool _isSearching = false;
  bool _noUserFound = false;
  late AnimationController _particleController;
  late List<Offset> _particles;

  @override
  void initState() {
    super.initState();
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _particles = List.generate(100, (index) => _randomOffset());
  }

  Offset _randomOffset() {
    final rand = Random();
    return Offset(rand.nextDouble(), rand.nextDouble());
  }

  Future<void> _searchUserByEmail() async {
    if (_searchController.text.trim().isEmpty) return;

    setState(() {
      _isSearching = true;
      _noUserFound = false;
      _foundUser = null;
    });

    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: _searchController.text.trim())
          .limit(1)
          .get();

      if (mounted) {
        setState(() {
          _isSearching = false;
          if (querySnapshot.docs.isNotEmpty) {
            _foundUser = {
              ...querySnapshot.docs.first.data(),
              'id': querySnapshot.docs.first.id,
            };
          } else {
            _noUserFound = true;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSearching = false;
          _noUserFound = true;
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur de recherche : $e')),
      );
    }
  }

  @override
  void dispose() {
    _particleController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _showImageDialog(String? imageUrl) {
    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: imageUrl != null && imageUrl.isNotEmpty
              ? InteractiveViewer(child: Image.network(imageUrl))
              : Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.background,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              'Pas d’image disponible',
              style: TextStyle(fontSize: 22, color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('✨ Trouver un utilisateur'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _particleController,
            builder: (context, child) {
              return CustomPaint(
                size: Size.infinite,
                painter: ParticlePainter(_particles, _particleController.value),
              );
            },
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              hintText: 'Entrer l\'email...',
                              filled: true,
                              fillColor: isDarkMode ? Colors.white10 : Colors.white.withOpacity(0.8),
                              prefixIcon: const Icon(Icons.email_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: _searchUserByEmail,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepOrange,
                            padding: const EdgeInsets.all(16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 8,
                          ),
                          child: const Icon(Icons.search),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    if (_isSearching)
                      const CircularProgressIndicator()
                    else if (_noUserFound)
                      Column(
                        children: [
                          const Icon(Icons.person_off, size: 80, color: Colors.redAccent),
                          const SizedBox(height: 16),
                          Text(
                            'Aucun utilisateur trouvé',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      )
                    else if (_foundUser != null)
                        _buildUserCard(isDarkMode)
                      else
                        const Text(
                          '🔎 Recherchez un utilisateur par email',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(bool isDarkMode) {
    return AnimatedScale(
      duration: const Duration(milliseconds: 500),
      scale: 1.0,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 500),
        opacity: 1.0,
        child: Container(
          padding: const EdgeInsets.all(24),
          margin: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.white10 : Colors.white.withOpacity(0.7),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: isDarkMode ? Colors.black26 : Colors.grey.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
            backgroundBlendMode: BlendMode.overlay,
          ),
          child: Column(
            children: [
              GestureDetector(
                onTap: () => _showImageDialog(_foundUser!['imageurl']),
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: _foundUser!['imageurl'] != null &&
                      _foundUser!['imageurl'].toString().isNotEmpty
                      ? NetworkImage(_foundUser!['imageurl'])
                      : null,
                  backgroundColor: Colors.grey.shade300,
                  child: _foundUser!['imageurl'] == null ||
                      _foundUser!['imageurl'].toString().isEmpty
                      ? Text(
                    _foundUser!['nom'][0].toUpperCase(),
                    style: const TextStyle(fontSize: 36, color: Colors.deepOrange),
                  )
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '${_foundUser!['nom']} ${_foundUser!['prenom']}',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                _foundUser!['email'] ?? '',
                style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black54),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  if (_foundUser != null) {
                    final receiverEmail = _foundUser!['email'] ?? '';
                    final receiverName = '${_foundUser!['prenom'] ?? ''} ${_foundUser!['nom'] ?? ''}';
                    final profileUrl = _foundUser!['imageurl'] ?? '';

                    final isValidUrl = profileUrl.startsWith('http');
                    final safeProfileUrl = isValidUrl
                        ? profileUrl
                        : 'https://via.placeholder.com/150';

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatPage(
                          receiverEmail: receiverEmail,
                          receiverName: receiverName,
                          receiverProfileImageUrl: safeProfileUrl,
                        ),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 10,
                ),
                icon: const Icon(Icons.send),
                label: const Text('Contacter'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Painter pour les particules animées
class ParticlePainter extends CustomPainter {
  final List<Offset> particles;
  final double progress;

  ParticlePainter(this.particles, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.3);
    for (var particle in particles) {
      final offset = Offset(
        (particle.dx + progress) % 1.0 * size.width,
        (particle.dy + progress) % 1.0 * size.height,
      );
      canvas.drawCircle(offset, 2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant ParticlePainter oldDelegate) => true;
}
