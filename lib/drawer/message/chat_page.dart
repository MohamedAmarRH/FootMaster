import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';
import 'package:untitled1/drawer/message/person_list_page.dart';
import '../../widgets/custom_drawer.dart';
import 'ChatPage.dart';

class MessagePage extends StatefulWidget {
  const MessagePage({super.key});

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Connectivity _connectivity = Connectivity();
  final BehaviorSubject<bool> _reloadTrigger = BehaviorSubject.seeded(true);

  late Stream<List<Map<String, dynamic>>> _conversationsStream;
  bool isConnected = true;
  String? currentUserEmail;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    currentUserEmail = _auth.currentUser?.email;
    _initConnectivity();
    _conversationsStream = _getConversations();
  }

  Future<void> _initConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    _updateConnectionStatus(result);
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    final newStatus = result != ConnectivityResult.none;
    if (newStatus && !isConnected) {
      _reloadTrigger.add(true);
    }
    setState(() => isConnected = newStatus);
  }

  Stream<List<Map<String, dynamic>>> _getConversations() {
    if (currentUserEmail == null) return const Stream.empty();

    return _reloadTrigger.switchMap((_) {
      final sentMessages = _firestore
          .collection('messages')
          .where('isDeleted', isEqualTo: false)
          .where('sender', isEqualTo: currentUserEmail)
          .orderBy('timestamp', descending: true)
          .snapshots();

      final receivedMessages = _firestore
          .collection('messages')
          .where('isDeleted', isEqualTo: false)
          .where('receiver', isEqualTo: currentUserEmail)
          .orderBy('timestamp', descending: true)
          .snapshots();

      return Rx.combineLatest2(sentMessages, receivedMessages,
              (sentSnapshot, receivedSnapshot) async {
            final allMessages = [...sentSnapshot.docs, ...receivedSnapshot.docs];
            allMessages.sort((a, b) =>
                (b['timestamp'] as Timestamp).compareTo(a['timestamp'] as Timestamp));

            final processedUsers = <String>{};
            final conversations = <Map<String, dynamic>>[];

            for (var doc in allMessages) {
              final data = doc.data() as Map<String, dynamic>;
              final otherEmail = data['sender'] == currentUserEmail
                  ? data['receiver']
                  : data['sender'];

              if (!processedUsers.contains(otherEmail)) {
                processedUsers.add(otherEmail);
                final userSnapshot = await _firestore
                    .collection('users')
                    .where('email', isEqualTo: otherEmail)
                    .limit(1)
                    .get();
                final userData = userSnapshot.docs.isNotEmpty
                    ? userSnapshot.docs.first.data()
                    : {};

                conversations.add({
                  'email': otherEmail,
                  'lastMessage': data['message'] ?? '',
                  'timestamp': data['timestamp'],
                  'userName': "${userData['prenom'] ?? ''} ${userData['nom'] ?? ''}".trim(),
                  'profilePic': userData['imageurl'] ?? '',
                  'isRead': data['isRead'] ?? false,
                });
              }
            }

            return conversations;
          }).asyncExpand((event) => event.asStream());
    });
  }

  Future<void> _deleteMessages(String otherUserEmail) async {
    final userMessages = await _firestore
        .collection('messages')
        .where('sender', isEqualTo: currentUserEmail)
        .where('receiver', isEqualTo: otherUserEmail)
        .get();

    final receiverMessages = await _firestore
        .collection('messages')
        .where('sender', isEqualTo: otherUserEmail)
        .where('receiver', isEqualTo: currentUserEmail)
        .get();

    final batch = _firestore.batch();

    for (var doc in userMessages.docs) {
      batch.update(doc.reference, {'isDeleted': true});
    }

    for (var doc in receiverMessages.docs) {
      batch.update(doc.reference, {'isDeleted': true});
    }

    await batch.commit();
  }

  Future<void> _confirmDeleteMessages(String otherUserEmail) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation de suppression'),
          content: const Text('Êtes-vous sûr de vouloir supprimer cette conversation ?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Ferme la boîte de dialogue
              },
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Ferme la boîte de dialogue
                await _deleteMessages(otherUserEmail); // Supprimer les messages
              },
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, // Couleur dynamique
      appBar: AppBar(
        title: const Text('Messages'),
        backgroundColor: Colors.black38,//Theme.of(context).appBarTheme.backgroundColor, // AppBar dynamique
        elevation: 8,
      ),
      drawer: const CustomDrawer(currentPage: 'message'),

      body: isConnected
          ? StreamBuilder<List<Map<String, dynamic>>>(
        stream: _conversationsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 50),
                  const SizedBox(height: 20),
                  Text('Erreur: ${snapshot.error}'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => _reloadTrigger.add(true),
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          final conversations = snapshot.data ?? [];

          if (conversations.isEmpty) {
            return const Center(
              child: Text("Aucun message pour l'instant"),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _reloadTrigger.add(true),
            child: ListView.builder(
              itemCount: conversations.length,
              itemBuilder: (context, index) {
                final convo = conversations[index];
                final name = convo['userName'].isNotEmpty
                    ? convo['userName']
                    : convo['email'];
                final lastMessage = convo['lastMessage'];
                final profilePic = convo['profilePic'];
                final timestamp = convo['timestamp']?.toDate();
                final isRead = convo['isRead'];

                return GestureDetector(
                  onLongPress: () {
                    _confirmDeleteMessages(convo['email']);
                  },
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: CircleAvatar(
                      radius: 26,
                      backgroundColor: Colors.deepPurple,
                      backgroundImage: (profilePic.isNotEmpty)
                          ? NetworkImage(profilePic)
                          : null,
                      child: (profilePic.isEmpty)
                          ? Text(
                        name.isNotEmpty ? name[0].toUpperCase() : '?',
                        style: TextStyle(
                          color: Theme.of(context).iconTheme.color, // Dynamique en fonction du mode
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                          : null,
                    ),
                    title: Text(
                      name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isRead ? Colors.black : Colors.deepPurple, // Couleur dynamique
                      ),
                    ),
                    subtitle: Text(
                      lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Theme.of(context).iconTheme.color,//isRead ? Colors.grey : Colors.black,
                        fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                      ),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (timestamp != null)
                          Text(
                            DateFormat('HH:mm').format(timestamp),
                            style: TextStyle(
                              fontSize: 12,
                              color: isRead ? Colors.grey : Colors.deepPurple,
                            ),
                          ),
                        const SizedBox(height: 4),
                        if (!isRead)
                          Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatPage(
                            receiverEmail: convo['email'],
                            receiverName: name,
                            receiverProfileImageUrl: profilePic,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
      )
          : _buildNoConnectionView(),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PersonListPage()),
          );
        },
        backgroundColor: Colors.green,//Theme.of(context).floatingActionButtonTheme.backgroundColor, // Couleur dynamique
        elevation: 6,
        splashColor: Colors.white24,
        child: const Icon(
          Icons.message,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }

  Widget _buildNoConnectionView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off, size: 80, color: Colors.redAccent),
          const SizedBox(height: 20),
          const Text(
            "Pas de connexion Internet",
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.redAccent),
          ),
          const SizedBox(height: 10),
          const Text(
            "Veuillez vérifier votre connexion.",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _reloadTrigger.add(true),
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }
}
