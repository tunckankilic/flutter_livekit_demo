import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../view.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final meetingController = Get.find<MeetingController>();
    final meetingIdController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Meet Clone'),
        actions: [
          Obx(
            () =>
                authController.isSignedIn
                    ? IconButton(
                      icon: const Icon(Icons.logout),
                      onPressed: () => authController.signOut(),
                    )
                    : IconButton(
                      icon: const Icon(Icons.login),
                      onPressed: () => _showSignInDialog(context),
                    ),
          ),
          IconButton(
            icon: Icon(Get.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              Get.changeThemeMode(
                Get.isDarkMode ? ThemeMode.light : ThemeMode.dark,
              );
            },
          ),
        ],
      ),
      body: Obx(() {
        if (!authController.isSignedIn) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Sign in to start or join a meeting',
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => _showSignInDialog(context),
                  child: const Text('Sign In'),
                ),
              ],
            ),
          );
        }

        return Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Welcome, ${authController.userName}!',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),
                ElevatedButton.icon(
                  onPressed:
                      () => Get.to(
                        () => PreviewScreen(isNewMeeting: true, meetingId: ''),
                      ),
                  icon: const Icon(Icons.video_call),
                  label: const Text('Start a new meeting'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                  ),
                ),
                const SizedBox(height: 20),
                const Text('OR', style: TextStyle(fontSize: 16)),
                const SizedBox(height: 20),
                TextField(
                  controller: meetingIdController,
                  decoration: const InputDecoration(
                    labelText: 'Enter meeting code',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.keyboard),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: () {
                    final meetingId = meetingIdController.text.trim();
                    if (meetingId.isNotEmpty) {
                      Get.to(
                        () => PreviewScreen(
                          isNewMeeting: false,
                          meetingId: meetingId,
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.login),
                  label: const Text('Join meeting'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  void _showSignInDialog(BuildContext context) {
    showDialog(context: context, builder: (context) => const AuthDialog());
  }
}
