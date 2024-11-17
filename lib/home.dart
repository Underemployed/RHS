import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'RHS',
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.w500, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('RHS'),
            onTap: () {
              Navigator.pushNamed(context, '/rhs');
            },
          ),
          ListTile(
            title: const Text('Wanderer'),
            onTap: () {
              Navigator.pushNamed(context, '/wanderer');
            },
          ),
          ListTile(
            title: const Text('Phone Number'),
            onTap: () {
              Navigator.pushNamed(context, '/phone');
            },
          ),
        ],
      ),
    );
  }
}
