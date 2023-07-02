import 'package:flutter/material.dart';

class LsTextInput extends StatelessWidget {
  const LsTextInput({
    super.key,
    required String label,
    required TextEditingController controller,
  })  : _controller = controller,
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
