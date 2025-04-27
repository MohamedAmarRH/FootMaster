import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

class ChatPage extends StatefulWidget {
  final String receiverEmail;
  final String receiverName;
  final String receiverProfileImageUrl;

  const ChatPage({
    Key? key,
    required this.receiverEmail,
    required this.receiverName,
    required this.receiverProfileImageUrl,
  }) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ScrollController _scrollController = ScrollController();
  final _scrollDebouncer = Debouncer(milliseconds: 300);

  List<String> selectedMessageIds = [];
  bool isSelectionMode = false;
  bool _shouldAutoScroll = true;
  bool _isFirstLoad = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isFirstLoad) {
        _scrollToBottom(immediate: true);
        _isFirstLoad = false;
      }
    });
  }

  void _handleScroll() {
    if (_scrollController.hasClients) {
      final threshold = 100.0;
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;

      setState(() {
        _shouldAutoScroll = (maxScroll - currentScroll) < threshold;
      });
    }
  }

  void _scrollToBottom({bool immediate = false}) {
    if (_scrollController.hasClients) {
      if (immediate) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      } else {
        _scrollDebouncer.run(() {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        });
      }
    }
  }

  Stream<QuerySnapshot> getMessagesStream() {
    final currentUserEmail = _auth.currentUser?.email;
    if (currentUserEmail == null) return const Stream<QuerySnapshot>.empty();

    return _firestore
        .collection('messages')
        .where('sender', whereIn: [currentUserEmail, widget.receiverEmail])
        .where('receiver', whereIn: [currentUserEmail, widget.receiverEmail])
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    final user = _auth.currentUser;
    if (user?.email == null) return;

    try {
      await _firestore.collection('messages').add({
        'sender': user!.email,
        'receiver': widget.receiverEmail,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
        'isDeleted': false,
      });

      _messageController.clear();
      if (_shouldAutoScroll) _scrollToBottom();
    } catch (e) {
      debugPrint('Error sending message: $e');
    }
  }

  Future<void> deleteSelectedMessages() async {
    if (selectedMessageIds.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Supprimer ${selectedMessageIds.length} message(s)?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final batch = _firestore.batch();
      for (final messageId in selectedMessageIds) {
        final ref = _firestore.collection('messages').doc(messageId);
        batch.update(ref, {
          'message': 'message supprimé',
          'isDeleted': true,
          'deletedAt': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();

      setState(() {
        selectedMessageIds.clear();
        isSelectionMode = false;
      });

      // Ne pas scroll après suppression pour garder la position
    } catch (e) {
      debugPrint('Error deleting messages: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: isSelectionMode
            ? Text('${selectedMessageIds.length} sélectionné(s)')
            : Row(children: [
          CircleAvatar(
            backgroundImage: widget.receiverProfileImageUrl.isNotEmpty
                ? NetworkImage(widget.receiverProfileImageUrl)
                : const AssetImage('assets/default_avatar.png') as ImageProvider,
            radius: 18,
          ),
          const SizedBox(width: 10),
          Text(widget.receiverName),
        ]),
        actions: isSelectionMode
            ? [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: deleteSelectedMessages,
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => setState(() {
              selectedMessageIds.clear();
              isSelectionMode = false;
            }),
          ),
        ]
            : null,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: getMessagesStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_shouldAutoScroll) _scrollToBottom();
                });

                return ListView.builder(
                  controller: _scrollController,
                  reverse: false,
                  padding: const EdgeInsets.all(10),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg['sender'] == _auth.currentUser?.email;
                    final isDeleted = msg['isDeleted'] == true;

                    return GestureDetector(
                      onLongPress: () {
                        if (!isDeleted && isMe) {
                          setState(() {
                            if (selectedMessageIds.contains(msg.id)) {
                              selectedMessageIds.remove(msg.id);
                              isSelectionMode = selectedMessageIds.isNotEmpty;
                            } else {
                              selectedMessageIds.add(msg.id);
                              isSelectionMode = true;
                            }
                          });
                        }
                      },
                      child: MessageBubble(
                        message: isDeleted ? 'message supprimé' : msg['message'],
                        time: DateFormat('HH:mm').format((msg['timestamp'] as Timestamp).toDate()),
                        isMe: isMe,
                        isSelected: selectedMessageIds.contains(msg.id),
                        isDeleted: isDeleted,
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Écrire un message...',
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }
}

class MessageBubble extends StatelessWidget {
  final String message;
  final String time;
  final bool isMe;
  final bool isSelected;
  final bool isDeleted;

  const MessageBubble({
    required this.message,
    required this.time,
    required this.isMe,
    this.isSelected = false,
    this.isDeleted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDeleted
                ? Colors.grey[300]
                : isMe
                ? Colors.blue[100]
                : Colors.grey[200],
            borderRadius: BorderRadius.circular(20),
            border: isSelected
                ? Border.all(color: Colors.blue, width: 2)
                : null,
          ),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.7,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                message,
                style: TextStyle(
                  fontStyle: isDeleted ? FontStyle.italic : FontStyle.normal,
                  color: isDeleted ? Colors.grey[600] : Colors.black,
                ),
              ),
              Text(
                time,
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Debouncer {
  final int milliseconds;
  Timer? _timer;

  Debouncer({required this.milliseconds});

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}