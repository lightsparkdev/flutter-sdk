import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../components/text_input.dart';
import '../model/lightspark_client_notifier.dart';

typedef LoginCallback = Future<bool> Function(String, String);

class AccountScreen extends StatefulWidget {
  final LoginCallback _onLogin;
  final VoidCallback _onLogout;

  const AccountScreen({
    super.key,
    required LoginCallback onLogin,
    required VoidCallback onLogout,
  })  : _onLogin = onLogin,
        _onLogout = onLogout;

  static Route route(LoginCallback onLogin, VoidCallback onLogout) {
    return MaterialPageRoute<void>(
      builder: (_) => AccountScreen(
        onLogin: onLogin,
        onLogout: onLogout,
      ),
      settings: const RouteSettings(name: '/account'),
    );
  }

  @override
  State<StatefulWidget> createState() => AccountScreenState();
}

class AccountScreenState extends State<AccountScreen> {
  final _accountTextController = TextEditingController();
  final _jwtTextController = TextEditingController();
  var _isLoggedIn = false;

  AccountScreenState();

  @override
  void initState() {
    super.initState();
    final client = context.read<LightsparkClientNotifier>().value;
    client.isAuthorized().then((loggedIn) {
      setState(() {
        _isLoggedIn = loggedIn;
      });
    });
  }

  @override
  void dispose() {
    _accountTextController.dispose();
    _jwtTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isLoggedIn) ...[
              Text(
                "You're logged in! If you'd like to log in with a different account, just enter your new credentials below and tap \"Submit\".",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              FilledButton.tonalIcon(
                onPressed: () async {
                  widget._onLogout();
                  setState(() {
                    _isLoggedIn = false;
                  });
                },
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                height: 1,
                color: Colors.black.withOpacity(0.2),
              ),
              const SizedBox(height: 16),
            ],
            LsTextInput(
                label: 'Account ID', controller: _accountTextController),
            LsTextInput(label: 'JWT', controller: _jwtTextController),
            FilledButton(
              onPressed: () async {
                _isLoggedIn = await widget._onLogin(
                  _accountTextController.text,
                  _jwtTextController.text,
                );
              },
              child: const Text('Login with JWT'),
            ),
          ],
        ),
      ),
    );
  }
}
