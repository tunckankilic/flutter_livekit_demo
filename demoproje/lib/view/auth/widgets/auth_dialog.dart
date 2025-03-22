import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../view.dart';

class AuthDialog extends StatelessWidget {
  const AuthDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final nameController = TextEditingController();

    return AlertDialog(
      title: const Text('Sign In'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Enter your name to join meetings'),
          const SizedBox(height: 16),
          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Your Name',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
            onSubmitted: (value) {
              if (value.trim().isNotEmpty) {
                authController.signIn(value);
                Get.back();
              }
            },
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            final name = nameController.text.trim();
            if (name.isNotEmpty) {
              authController.signIn(name);
              Get.back();
            }
          },
          child: const Text('Continue'),
        ),
      ],
    );
  }
}
