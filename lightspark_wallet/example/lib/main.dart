import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:lightspark_wallet/lightspark_wallet.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  final _lightsparkWalletPlugin = LightsparkWallet();
  final client = LightsparkWalletClient();
  int nonce = getNonce();
  final _accountTextController = TextEditingController();
  final _jwtTextController = TextEditingController();

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

  updateNonce() {
    setState(() {
      nonce = getNonce();
    });
  }

  loginWithJwt() async {
    final jwtAuthStorage = SharedPreferencesJwtStorage();
    await client.loginWithJwt(
      _accountTextController.text,
      _jwtTextController.text,
      jwtAuthStorage,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Lightspark wallet example app'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Running on: $_platformVersion\n'),
              Text('Nonce: $nonce\n'),
              ElevatedButton(
                onPressed: updateNonce,
                child: const Text('Update nonce'),
              ),
              InputText(label: 'Account ID', controller: _accountTextController),
              InputText(label: 'JWT', controller: _jwtTextController),
              ElevatedButton(
                onPressed: loginWithJwt,
                child: const Text('Login with JWT'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class InputText extends StatelessWidget {
  const InputText({
    super.key,
    required String label,
    required TextEditingController controller,
  }) : _controller = controller,
       _label = label;

  final TextEditingController _controller;
  final String _label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: _label,
        ),
        controller: _controller,
      ),
    );
  }
}
