import 'package:flutter/material.dart';

class UnlockWalletDialog extends StatefulWidget {
  final Future<void> Function(String) onUnlock;
  const UnlockWalletDialog({Key? key, required this.onUnlock})
      : super(key: key);

  @override
  UnlockWalletDialogState createState() => UnlockWalletDialogState();
}

class UnlockWalletDialogState extends State<UnlockWalletDialog> {
  final _privateKeyTextController = TextEditingController();
  var _isUnlocking = false;

  @override
  void dispose() {
    _privateKeyTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Enter your private key to unlock your node'),
      content: TextField(
        controller: _privateKeyTextController,
        decoration: const InputDecoration(
          hintText: 'Private key',
        ),
        maxLines: 100,
        minLines: 1,
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('cancel'),
        ),
        TextButton(
          onPressed: () {
            setState(() {
              _isUnlocking = true;
            });
            final privateKey = _privateKeyTextController.text;
            widget.onUnlock(privateKey).then((_) {
              Navigator.of(context).pop();
            }).catchError((e) {
              setState(() {
                _isUnlocking = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(e.toString()),
              ));
            });
          },
          child: const Text('unlock'),
        ),
      ],
    );
  }
}
