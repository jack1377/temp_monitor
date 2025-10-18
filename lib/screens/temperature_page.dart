// lib/screens/temperature_page.dart
import 'package:flutter/material.dart';

class TemperaturePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Temperature Monitor")),
      body: Center(
        child: Text(
          "Temperature data will appear here",
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
