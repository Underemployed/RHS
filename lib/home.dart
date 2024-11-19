import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Color> colors = [
    Color(0xFFEA5455),
    Color(0xFF0396FF),
    Color(0xFF7367F0),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'FORT POLICE STATION',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            shadows: [
              Shadow(
                blurRadius: 3.0,
                color: Colors.black45,
                offset: Offset(1.0, 1.0),
              ),
            ],
          ),
        ),
        centerTitle: true,
        elevation: 0.0,
        backgroundColor: const Color(0xFF121212), 
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          SizedBox(
            height: 10,
          ),
          _buildListTile('RHS', colors[0], '/rhs'),
          _buildListTile('Wanderer', colors[1], '/wanderer'),
          _buildListTile('Contact Details', colors[2], '/phone'),
        ],
      ),
    );
  }

  Widget _buildListTile(String title, Color color, String route) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[850], 
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
        title: Center(
          child: Text(
            title,
            style: TextStyle(
              color: Colors.white, 
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        tileColor: Colors.transparent, 
        onTap: () {
          Navigator.pushNamed(context, route);
        },
      ),
    );
  }
}
