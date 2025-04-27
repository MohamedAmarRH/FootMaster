import 'package:flutter/material.dart';
import '../widgets/custom_drawer.dart';

class NewGroupPage extends StatelessWidget {
  const NewGroupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouveau groupe'),
        backgroundColor: Colors.black38,
        elevation: 10,
      ),
      drawer: const CustomDrawer(currentPage: 'group'),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Nom du groupe',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.group),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Sélectionnez des membres',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: 15,
                itemBuilder: (context, index) {
                  return CheckboxListTile(
                    title: Text("Contact ${index + 1}"),
                    subtitle: Text("contact${index + 1}@example.com"),
                    value: index % 3 == 0,
                    onChanged: (bool? value) {},
                    secondary: const CircleAvatar(
                      child: Icon(Icons.person),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Créer le groupe'),
            ),
          ],
        ),
      ),
    );
  }
}