import 'package:flutter/material.dart';
import 'dart:async';

class HonestyCheckScreen extends StatefulWidget {
  const HonestyCheckScreen({Key? key}) : super(key: key);

  @override
  _HonestyCheckScreenState createState() => _HonestyCheckScreenState();
}

class _HonestyCheckScreenState extends State<HonestyCheckScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text(
              "Processing information...",
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}