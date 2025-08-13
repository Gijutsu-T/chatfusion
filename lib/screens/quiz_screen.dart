import 'package:flutter/material.dart';

class QuizScreen extends StatefulWidget { 
  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentQuestionIndex = 0;
  int _incorrectAnswers = 0;

  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'What is the main purpose of this app?',
      'answers': ['Chatting with friends', 'Ordering food', 'Playing games'],
      'correctAnswerIndex': 0,
    },
    {
      'question': 'Where can you find information about how your data is used?',
      'answers': ['In the app settings', 'In the Privacy Policy', 'On a billboard'],
      'correctAnswerIndex': 1,
    },
  ];

  void _answerQuestion(int selectedAnswerIndex) {
    if (selectedAnswerIndex == _questions[_currentQuestionIndex]['correctAnswerIndex']) {
      if (_currentQuestionIndex < _questions.length - 1) {
        setState(() {
          _currentQuestionIndex++;
        });
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SuccessScreen()), // Navigating to a placeholder
        );
      }
    } else {
      _incorrectAnswers++;
      if (_incorrectAnswers >= 2) {
        Navigator.pushReplacement( // Navigating to a placeholder
          context,
          MaterialPageRoute(builder: (context) => PositiveReinforcementScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => TermsScreen()), // Navigating to a placeholder
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quick Quiz!'),
        automaticallyImplyLeading: false, // Disable back button
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _questions[_currentQuestionIndex]['question'],
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              ...(_questions[_currentQuestionIndex]['answers'] as List<String>).asMap().entries.map((entry) {
                int index = entry.key;
                String answer = entry.value;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ElevatedButton(
                    onPressed: () => _answerQuestion(index),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Text(answer),
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }
}

// Placeholder screens (create these files separately)
class SuccessScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Success!')),
      body: Center(child: Text('Quiz Passed! Welcome to the app!')),
    );
  }
}

class TermsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Terms and Policies')),
      body: Center(child: Text('Placeholder for Terms and Policies Screen')),
    );
  }
}

class PositiveReinforcementScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Great Effort!')),
      body: Center(child: Text('Placeholder for Positive Reinforcement Screen')),
    );
  }
}