import 'package:flutter/material.dart';
import '../widgets/custom_drawer.dart';

class SavedMessagesPage extends StatelessWidget {
  const SavedMessagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages enregistrés'),
        backgroundColor: Colors.black38,
        elevation: 10,
      ),
      drawer: const CustomDrawer(currentPage: 'saved'),
      body: ListView.builder(
        itemCount: 5,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: ListTile(
              leading: const Icon(Icons.bookmark, color: Colors.orange),
              title: Text("Message important #${index + 1}"),
              subtitle: const Text("Ceci est un message enregistré..."),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {},
              ),
              onTap: () {},
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add),
      ),
    );
  }
}