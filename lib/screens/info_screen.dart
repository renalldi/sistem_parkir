import 'package:flutter/material.dart';
import 'dart:async';

class InfoScreen extends StatefulWidget {
  @override
  _InfoScreenState createState() => _InfoScreenState();
}

class _InfoScreenState extends State<InfoScreen> {
  @override

  void initState() {
    super.initState();
    Timer(Duration(seconds: 2), () {
      Navigator.pushReplacementNamed(context, '/location');
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF1D16A),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.motorcycle_outlined, size: 120),
            SizedBox(height: 15),
            Text('Know before you go', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text('Monitor live parking availability at Fasilkom'),
          ],
        ),
      ),
    );
  }
}