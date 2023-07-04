import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lightspark_wallet/lightspark_wallet.dart';
import '../components/text_input.dart';

typedef LoginCallback = Future<bool> Function(String, String);

class LoginScreen extends StatefulWidget {
  final LoginCallback? _onLogin;
  const LoginScreen({super.key, LoginCallback? onLogin}) : _onLogin = onLogin;

  @override
  State<StatefulWidget> createState() => LoginScreenState(_onLogin);
}

class LoginScreenState extends State<LoginScreen> {
  String _platformVersion = 'Unknown';
  final _lightsparkWalletPlugin = LightsparkWallet();
  final _accountTextController = TextEditingController();
  final _jwtTextController = TextEditingController();
  final LoginCallback? _onLogin;

  LoginScreenState(this._onLogin);

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  @override
  void dispose() {
    _accountTextController.dispose();
    _jwtTextController.dispose();
    super.dispose();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion = await _lightsparkWalletPlugin.getPlatformVersion() ??
          'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Running on: $_platformVersion\n'),
        LsTextInput(label: 'Account ID', controller: _accountTextController),
        LsTextInput(label: 'JWT', controller: _jwtTextController),
        ElevatedButton(
          onPressed: () async {
            final loggedIn = await _onLogin!(
              _accountTextController.text,
              _jwtTextController.text,
            );
            print('Login result: $loggedIn');
          },
          child: const Text('Login with JWT'),
        ),
      ],
    );
  }
}
