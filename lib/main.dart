import 'package:flutter/material.dart';

void main() {
  runApp(const HabitApp());
}

class HabitApp extends StatelessWidget {
  const HabitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const HabitHomeScreen(),
    );
  }
}

class HabitHomeScreen extends StatelessWidget {
  const HabitHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Habits'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          HabitTile(title: 'Morning run'),
          HabitTile(title: 'Read 10 pages'),
          HabitTile(title: 'Meditate'),
        ],
      ),
    );
  }
}

class HabitTile extends StatelessWidget {
  final String title;

  const HabitTile({required this.title, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}

