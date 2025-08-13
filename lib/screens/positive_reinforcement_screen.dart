import 'package:flutter/material.dart';

class PositiveReinforcementScreen extends StatelessWidget {
  const PositiveReinforcementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Well Done!'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Placeholder for a positive animation or image
            // You can replace this with a Lottie animation, an image, etc.
            Icon(
              Icons.star_border,
              size: 100,
              color: Colors.amber,
            ),
            const SizedBox(height: 20),
            const Text(
              'Great effort! Keep going!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                // Navigate back to the TermsScreen to try the quiz again
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: const Text('Try the Quiz Again'),
            ),
          ],
        ),
      ),
    );
  }
}