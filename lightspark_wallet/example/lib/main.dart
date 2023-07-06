import 'package:flutter/material.dart';
import 'dart:async';

import 'package:lightspark_wallet/lightspark_wallet.dart';
import 'package:lightspark_wallet_example/src/screens/account_screen.dart';
import 'package:lightspark_wallet_example/src/screens/login_screen.dart';
import 'package:provider/provider.dart';

import 'src/model/lightspark_client_notifier.dart';
import 'src/screens/home_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => LightsparkClientNotifier(
        LightsparkWalletClient(
          authProvider: JwtAuthProvider(SharedPreferencesJwtStorage()),
        ),
      ),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isLoggedIn = false;
  int _selectedTabIndex = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final client = Provider.of<LightsparkClientNotifier>(
      context,
      listen: false,
    ).value;
    client.isAuthorized().then((value) {
      setState(() {
        _isLoggedIn = value;
      });
    });
  }

  Future<bool> _loginWithJwt(String accountId, String jwt) async {
    final client = Provider.of<LightsparkClientNotifier>(
      context,
      listen: false,
    ).value;
    final jwtAuthStorage = SharedPreferencesJwtStorage();
    await client.loginWithJwt(
      accountId,
      jwt,
      jwtAuthStorage,
    );
    final loggedIn = await client.isAuthorized();
    setState(() {
      _isLoggedIn = loggedIn;
    });
    return loggedIn;
  }

  Future<void> _logout() async {
    final client = Provider.of<LightsparkClientNotifier>(
      context,
      listen: false,
    ).value;
    final authProvider = JwtAuthProvider(
      SharedPreferencesJwtStorage(),
    );
    await authProvider.logout();
    client.setAuthProvider(authProvider);
    setState(() {
      _isLoggedIn = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.from(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueGrey,
          primary: Colors.black,
        ),
      ).copyWith(
        appBarTheme: const AppBarTheme(
          elevation: 1,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(minimumSize: const Size(105, 45)),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(minimumSize: const Size(105, 45)),
        ),
      ),
      home: _isLoggedIn
          ? _buildHomeScreen()
          : LoginScreen(onLogin: _loginWithJwt),
    );
  }

  Widget _buildHomeScreen() {
    return Scaffold(
      body: [
        HomeScreen(onLogin: _loginWithJwt, onLogout: _logout),
        AccountScreen(onLogin: _loginWithJwt, onLogout: _logout)
      ][_selectedTabIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedTabIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.wallet),
            label: 'Wallet',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Account',
          ),
        ],
        onTap: (index) {
          setState(() {
            _selectedTabIndex = index;
          });
        },
      ),
    );
  }
}
