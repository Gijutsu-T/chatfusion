import 'package:flutter/material.dart';

class TermsScreen extends StatefulWidget {
  @override
  _TermsScreenState createState() => _TermsScreenState();
}

class _TermsScreenState extends State<TermsScreen> {
  final ScrollController _termsScrollController = ScrollController();
  final ScrollController _privacyScrollController = ScrollController();
  bool _termsScrolledToBottom = false;
  bool _privacyScrolledToBottom = false;
  bool _agreeButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _termsScrollController.addListener(_checkTermsScroll);
    _privacyScrollController.addListener(_checkPrivacyScroll);
  }

  @override
  void dispose() {
    _termsScrollController.removeListener(_checkTermsScroll);
    _termsScrollController.dispose();
    _privacyScrollController.removeListener(_checkPrivacyScroll);
    _privacyScrollController.dispose();
    super.dispose();
  }

  void _checkTermsScroll() {
    if (_termsScrollController.position.pixels ==
        _termsScrollController.position.maxScrollExtent) {
      setState(() {
        _termsScrolledToBottom = true;
        _checkAllScrolled();
      });
    }
  }

  void _checkPrivacyScroll() {
    if (_privacyScrollController.position.pixels ==
        _privacyScrollController.position.maxScrollExtent) {
      setState(() {
        _privacyScrolledToBottom = true;
        _checkAllScrolled();
      });
    }
  }

  void _checkAllScrolled() {
    if (_termsScrolledToBottom && _privacyScrolledToBottom) {
      setState(() {
        _agreeButtonEnabled = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Terms and Privacy'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                controller: _termsScrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Terms of Service',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.' * 20, // Placeholder text
                    ),
                    SizedBox(height: 16.0),
                    Text(
                      'Privacy Policy',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      'Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt. Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem.' * 20, // Placeholder text
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _agreeButtonEnabled ? () {
                // TODO: Implement navigation to the next screen
              } : null,
              child: Text('I Agree'),
            ),
            SizedBox(height: 8.0),
            Text(
              _agreeButtonEnabled ? "You've read the terms!" : "Scroll to read the terms",
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}